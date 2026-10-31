import { describe, expect, it, vi } from 'vitest'
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import ExpensesPage from './ExpensesPage'
import { http, HttpResponse, server } from '../test/server'
import { renderWithApp, signIn } from '../test/render'

const CROPS = [{ id: 7, name: 'Paddy', variety: 'BG 300', status: 'GROWING' }]
const EXPENSES = [
  { id: 1, category: 'FERTILIZER', description: 'Urea 50kg', amount: 4500, expenseDate: '2026-05-10', notes: '' },
  { id: 2, category: 'LABOR', description: 'Transplanting crew', amount: 12000, expenseDate: '2026-05-04', notes: 'Two days' },
]

function mockApi({ onPut, onDelete } = {}) {
  server.use(
    http.get('/api/crops', () => HttpResponse.json(CROPS)),
    http.get('/api/crops/7/expenses', () => HttpResponse.json(EXPENSES)),
    http.put('/api/crops/7/expenses/:id', async ({ params, request }) => {
      const body = await request.json()
      onPut?.(params.id, body)
      return HttpResponse.json({ ...EXPENSES.find((e) => String(e.id) === params.id), ...body })
    }),
    http.delete('/api/crops/7/expenses/:id', ({ params }) => {
      onDelete?.(params.id)
      return new HttpResponse(null, { status: 204 })
    }),
  )
}

describe('ExpensesPage', () => {
  it('lists the selected crop\'s expenses with their total', async () => {
    signIn()
    mockApi()

    renderWithApp(<ExpensesPage />)

    expect(await screen.findByText('Urea 50kg')).toBeInTheDocument()
    expect(screen.getByText('Transplanting crew')).toBeInTheDocument()
    expect(screen.getAllByText('Rs. 16,500').length).toBeGreaterThan(0)
  })

  it('deletes an expense after confirmation', async () => {
    signIn()
    const deleted = []
    mockApi({ onDelete: (id) => deleted.push(id) })
    vi.spyOn(window, 'confirm').mockReturnValue(true)

    renderWithApp(<ExpensesPage />)
    await userEvent.click(await screen.findByRole('button', { name: 'Delete Urea 50kg' }))

    await waitFor(() => expect(screen.queryByText('Urea 50kg')).not.toBeInTheDocument())
    expect(deleted).toEqual(['1'])
  })

  it('keeps the expense when deletion is cancelled', async () => {
    signIn()
    const deleted = []
    mockApi({ onDelete: (id) => deleted.push(id) })
    vi.spyOn(window, 'confirm').mockReturnValue(false)

    renderWithApp(<ExpensesPage />)
    await userEvent.click(await screen.findByRole('button', { name: 'Delete Urea 50kg' }))

    expect(screen.getByText('Urea 50kg')).toBeInTheDocument()
    expect(deleted).toEqual([])
  })

  it('edits an expense through the prefilled form', async () => {
    signIn()
    const updates = []
    mockApi({ onPut: (id, body) => updates.push({ id, body }) })

    renderWithApp(<ExpensesPage />)
    await userEvent.click(await screen.findByRole('button', { name: 'Edit Urea 50kg' }))

    const dialog = screen.getByRole('heading', { name: /Edit Expense/ }).closest('.modal-card')
    const amount = within(dialog).getByPlaceholderText('e.g. 3500')
    expect(amount).toHaveValue(4500)

    await userEvent.clear(amount)
    await userEvent.type(amount, '4750.50')
    await userEvent.click(within(dialog).getByRole('button', { name: 'Save Changes' }))

    await waitFor(() => expect(updates).toHaveLength(1))
    expect(updates[0].id).toBe('1')
    expect(updates[0].body).toMatchObject({ amount: 4750.5, description: 'Urea 50kg', category: 'FERTILIZER' })
  })

  it('shows the server\'s validation message when a save is rejected', async () => {
    signIn()
    mockApi()
    server.use(http.put('/api/crops/7/expenses/:id', () =>
      HttpResponse.json({ message: 'Amount must be greater than zero' }, { status: 400 })))

    renderWithApp(<ExpensesPage />)
    await userEvent.click(await screen.findByRole('button', { name: 'Edit Urea 50kg' }))
    await userEvent.click(screen.getByRole('button', { name: 'Save Changes' }))

    expect(await screen.findByText('Amount must be greater than zero')).toBeInTheDocument()
  })
})
