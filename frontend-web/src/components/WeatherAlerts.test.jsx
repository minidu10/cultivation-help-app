import { describe, expect, it } from 'vitest'
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import DashboardPage from '../pages/DashboardPage'
import { http, HttpResponse, server } from '../test/server'
import { renderWithApp, signIn } from '../test/render'

const EMPTY_SUMMARY = {
  totals: { totalRevenue: 0, totalExpenses: 0, netProfit: 0, activeCrops: 1, totalCrops: 1 },
  crops: [], dueReminders: [], upcomingReminders: [],
}

const WASHOFF = {
  type: 'RAIN_WASHOFF',
  severity: 'HIGH',
  cropId: 7,
  cropName: 'Paddy',
  reminderId: 42,
  reminderTitle: 'Apply urea',
  reminderAt: '2026-10-24T09:00:00',
  location: 'Polonnaruwa, LK',
  date: '2026-10-24',
  rainChancePercent: 85,
  rainMm: 12,
  suggestedAt: '2026-10-25T09:00:00',
  message: 'Rain likely on Sat 24 Oct (85% chance, about 12 mm). "Apply urea" for Paddy may wash off before it soaks in.',
}

const HEAT = {
  type: 'HEAT_STRESS',
  severity: 'MEDIUM',
  cropName: 'Paddy, Chilli',
  reminderId: null,
  location: 'Polonnaruwa, LK',
  date: '2026-10-25',
  maxTempC: 36,
  suggestedAt: null,
  message: 'Up to 36°C at Polonnaruwa, LK on Sun 25 Oct. Water Paddy, Chilli early morning or evening.',
}

function mockDashboard(alerts, { onPut } = {}) {
  let current = alerts
  server.use(
    http.get('/api/dashboard/summary', () => HttpResponse.json(EMPTY_SUMMARY)),
    http.get('/api/alerts', () => HttpResponse.json(current)),
    http.get('/api/reminders/due', () => HttpResponse.json([])),
    http.put('/api/crops/:cropId/reminders/:reminderId', async ({ params, request }) => {
      onPut?.({ ...params, body: await request.json() })
      current = current.filter((a) => String(a.reminderId) !== params.reminderId)
      return HttpResponse.json({ id: Number(params.reminderId) })
    }),
  )
}

describe('weather alerts on the dashboard', () => {
  it('shows each risk with the server\'s explanation', async () => {
    signIn()
    mockDashboard([WASHOFF, HEAT])

    renderWithApp(<DashboardPage />)

    const card = await screen.findByRole('region', { name: 'Weather alerts' })
    expect(within(card).getByText(/Rain may wash it off · Apply urea/)).toBeInTheDocument()
    expect(within(card).getByText(/may wash off before it soaks in/)).toBeInTheDocument()
    expect(within(card).getByText('Heat stress')).toBeInTheDocument()
  })

  it('offers the better time only where the server found one', async () => {
    signIn()
    mockDashboard([WASHOFF, HEAT])

    renderWithApp(<DashboardPage />)

    const card = await screen.findByRole('region', { name: 'Weather alerts' })
    expect(within(card).getAllByRole('button', { name: /Move to/ })).toHaveLength(1)
    expect(within(card).getByRole('button', { name: /Move to Sun 25 Oct, 9:00 AM/ })).toBeInTheDocument()
  })

  it('moving the task reschedules the reminder and clears the alert', async () => {
    signIn()
    const puts = []
    mockDashboard([WASHOFF], { onPut: (put) => puts.push(put) })

    renderWithApp(<DashboardPage />)
    await userEvent.click(await screen.findByRole('button', { name: /Move to/ }))

    await waitFor(() => expect(screen.queryByRole('region', { name: 'Weather alerts' })).not.toBeInTheDocument())
    expect(puts).toEqual([{ cropId: '7', reminderId: '42', body: { reminderAt: '2026-10-25T09:00:00' } }])
  })

  it('stays out of the way when there is nothing to warn about', async () => {
    signIn()
    mockDashboard([])

    renderWithApp(<DashboardPage />)
    await screen.findByText('Harvest Revenue')

    expect(screen.queryByRole('region', { name: 'Weather alerts' })).not.toBeInTheDocument()
  })

  it('an alerts failure does not break the dashboard', async () => {
    signIn()
    mockDashboard([])
    server.use(http.get('/api/alerts', () => HttpResponse.json({ message: 'boom' }, { status: 500 })))

    renderWithApp(<DashboardPage />)

    expect(await screen.findByText('Harvest Revenue')).toBeInTheDocument()
  })
})
