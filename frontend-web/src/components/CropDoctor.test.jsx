import { describe, expect, it, vi } from 'vitest'
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import CropDoctor from './CropDoctor'
import { http, HttpResponse, server } from '../test/server'
import { renderWithApp, signIn } from '../test/render'

const BLAST = {
  id: 11,
  cropId: 7,
  isPlant: true,
  cropGuess: 'Rice',
  condition: 'Rice blast',
  confidence: 0.82,
  severity: 'moderate',
  seeExpert: false,
  symptoms: ['Diamond-shaped grey lesions'],
  treatmentOrganic: ['Remove badly affected leaves'],
  treatmentChemical: ['Tricyclazole, as the label directs'],
  prevention: ['Avoid excess nitrogen'],
  note: null,
  createdAt: '2026-10-24T09:30:00',
  thumbnailUrl: '/api/crops/7/diagnoses/11/thumbnail',
}

const leaf = () => new File([new Uint8Array([0xff, 0xd8, 0xff, 0xe0])], 'leaf.jpg', { type: 'image/jpeg' })

function mockApi({ history = [], answer = BLAST, status = 200, onPost, onDelete } = {}) {
  server.use(
    http.get('/api/crops/7/diagnoses', () => HttpResponse.json(history)),
    http.get('/api/crops/7/diagnoses/:id/thumbnail', () =>
      new HttpResponse(new Uint8Array([0xff, 0xd8]), { headers: { 'Content-Type': 'image/jpeg' } })),
    // The raw multipart body, not request.formData(): MSW's parser rejects
    // jsdom's File objects, which is a test-environment clash, not an app bug.
    http.post('/api/crops/7/diagnoses', async ({ request }) => {
      onPost?.(await request.text())
      return HttpResponse.json(answer, { status })
    }),
    http.delete('/api/crops/7/diagnoses/:id', ({ params }) => {
      onDelete?.(params.id)
      return new HttpResponse(null, { status: 204 })
    }),
  )
}

async function choosePhoto(user = userEvent.setup()) {
  await user.upload(screen.getByLabelText('Choose a photo'), leaf())
}

describe('CropDoctor', () => {
  it('uploads the photo with the note and shows the diagnosis', async () => {
    signIn()
    const posts = []
    mockApi({ onPost: (body) => posts.push(body) })
    const user = userEvent.setup()

    renderWithApp(<CropDoctor cropId="7" />)
    await user.type(screen.getByLabelText('Note about the photo'), 'Spots after rain')
    await choosePhoto(user)

    // Shown twice: as the result, and in the history it has just joined.
    expect(await screen.findByText('Confidence 82%')).toBeInTheDocument()
    expect(screen.getAllByText('Rice blast')).toHaveLength(2)
    expect(screen.getByText('Tricyclazole, as the label directs')).toBeInTheDocument()
    expect(posts[0]).toMatch(/name="image"; filename="[^"]+"/)
    expect(posts[0]).toMatch(/name="note"\r?\n\r?\nSpots after rain/)
  })

  it('a new result joins the past checks', async () => {
    signIn()
    mockApi()

    renderWithApp(<CropDoctor cropId="7" />)
    await choosePhoto()

    const past = await screen.findByText('Past checks')
    expect(within(past.parentElement).getByText('Rice blast')).toBeInTheDocument()
  })

  it('sends the farmer to an expert when the model is unsure', async () => {
    signIn()
    mockApi({ answer: { ...BLAST, confidence: 0.35, seeExpert: true } })

    renderWithApp(<CropDoctor cropId="7" />)
    await choosePhoto()

    expect(await screen.findByRole('alert')).toHaveTextContent('Agrarian Service Centre')
  })

  it('asks for a better photo when there was no plant in it', async () => {
    signIn()
    mockApi({ answer: { ...BLAST, id: null, isPlant: false, condition: 'Not a plant', thumbnailUrl: null } })

    renderWithApp(<CropDoctor cropId="7" />)
    await choosePhoto()

    expect(await screen.findByText('We could not see a plant clearly')).toBeInTheDocument()
    expect(screen.queryByText('Past checks')).not.toBeInTheDocument()
  })

  it('shows the server\'s reason when a check is refused', async () => {
    signIn()
    mockApi({ answer: { message: 'You have checked 10 photos today, the daily limit. It resets tomorrow.' }, status: 429 })

    renderWithApp(<CropDoctor cropId="7" />)
    await choosePhoto()

    expect(await screen.findByRole('alert')).toHaveTextContent('daily limit')
  })

  it('opens and deletes a past check', async () => {
    signIn()
    const deleted = []
    mockApi({ history: [BLAST], onDelete: (id) => deleted.push(id) })
    vi.spyOn(window, 'confirm').mockReturnValue(true)
    const user = userEvent.setup()

    renderWithApp(<CropDoctor cropId="7" />)
    await user.click(await screen.findByRole('button', { name: /^Rice blast/ }))
    expect(screen.getByText('Avoid excess nitrogen')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Delete Rice blast check' }))

    await waitFor(() => expect(screen.queryByText('Past checks')).not.toBeInTheDocument())
    expect(deleted).toEqual(['11'])
  })
})
