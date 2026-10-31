import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import App from './App'
import { http, HttpResponse, server } from './test/server'
import { renderWithApp, signIn } from './test/render'

describe('session handling', () => {
  it('sends the user to sign in, with a reason, once the session cannot be renewed', async () => {
    signIn()
    server.use(
      http.get('/api/dashboard/summary', () => HttpResponse.json({ message: 'expired' }, { status: 401 })),
      http.post('/api/auth/refresh', () => HttpResponse.json({ message: 'ended' }, { status: 401 })),
    )

    renderWithApp(<App />, { route: '/dashboard' })

    // The login page is a lazily loaded chunk, so allow time for the import:
    // on a busy CI runner the first transform of it can take several seconds.
    expect(await screen.findByText(/Your session has ended\. Please sign in again\./, {}, { timeout: 10000 }))
      .toBeInTheDocument()
    expect(localStorage.getItem('token')).toBeNull()
    expect(localStorage.getItem('user')).toBeNull()
  }, 15000)

  it('keeps visitors who never signed in on the landing page', async () => {
    renderWithApp(<App />, { route: '/dashboard' })

    expect(await screen.findAllByRole('button', { name: /sign in|get started/i })).not.toHaveLength(0)
    expect(screen.queryByText(/Your session has ended/)).not.toBeInTheDocument()
  })

  it('logging out revokes the refresh token on the server', async () => {
    signIn({ refreshToken: 'refresh-to-revoke' })
    const revoked = []
    server.use(
      http.get('/api/dashboard/summary', () => HttpResponse.json({
        totals: { totalRevenue: 0, totalExpenses: 0, netProfit: 0, activeCrops: 0, totalCrops: 0 },
        crops: [], dueReminders: [], upcomingReminders: [],
      })),
      http.post('/api/auth/logout', async ({ request }) => {
        revoked.push((await request.json()).refreshToken)
        return new HttpResponse(null, { status: 204 })
      }),
    )

    renderWithApp(<App />, { route: '/dashboard' })
    const logoutButton = await screen.findByRole('button', { name: /log ?out|sign out/i })
    logoutButton.click()

    await screen.findAllByRole('button', { name: /sign in|get started/i })
    expect(revoked).toEqual(['refresh-to-revoke'])
    expect(localStorage.getItem('refreshToken')).toBeNull()
  })
})
