import { describe, expect, it } from 'vitest'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import SettingsPage from './SettingsPage'
import { http, HttpResponse, server } from '../test/server'
import { renderWithApp, signIn, TEST_USER } from '../test/render'

const PROFILE = { ...TEST_USER, id: 1, phone: '', reminderEmailsEnabled: true }

function mockProfile(profile, puts = []) {
  let saved = { ...profile }
  server.use(
    http.get('/api/users/me', () => HttpResponse.json(saved)),
    http.put('/api/users/me', async ({ request }) => {
      const body = await request.json()
      puts.push(body)
      saved = { ...saved, ...body }
      return HttpResponse.json(saved)
    }),
  )
}

describe('SettingsPage theme', () => {
  // Regression: the theme only reached the server with "Save settings", so
  // leaving the page and coming back reloaded Light and highlighted it while
  // the screen was still dark.
  it('saves a theme the moment it is picked', async () => {
    signIn()
    const puts = []
    mockProfile(PROFILE, puts)

    renderWithApp(<SettingsPage />)
    await userEvent.click(await screen.findByRole('button', { name: /Dark Mode/ }))

    await waitFor(() => expect(puts).toEqual([{ themePreference: 'DARK', desktopMode: false }]))
    expect(screen.getByRole('button', { name: /Dark Mode/ })).toHaveAttribute('aria-pressed', 'true')
    expect(document.documentElement.getAttribute('data-theme')).toBeNull()
  })

  it('highlights the saved theme and shows it when the page opens', async () => {
    signIn()
    mockProfile({ ...PROFILE, themePreference: 'DARK' })

    renderWithApp(<SettingsPage />)

    expect(await screen.findByRole('button', { name: /Dark Mode/ })).toHaveAttribute('aria-pressed', 'true')
    expect(screen.getByRole('button', { name: /Light Mode/ })).toHaveAttribute('aria-pressed', 'false')
    await waitFor(() => expect(document.documentElement.getAttribute('data-theme')).toBeNull())
  })

  it('goes back to the old theme when saving fails', async () => {
    signIn()
    mockProfile(PROFILE)
    server.use(http.put('/api/users/me', () => HttpResponse.json({ message: 'boom' }, { status: 500 })))

    renderWithApp(<SettingsPage />)
    await userEvent.click(await screen.findByRole('button', { name: /Dark Mode/ }))

    expect(await screen.findByText(/Could not save the theme/)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Light Mode/ })).toHaveAttribute('aria-pressed', 'true')
    expect(document.documentElement.getAttribute('data-theme')).toBe('light')
  })
})
