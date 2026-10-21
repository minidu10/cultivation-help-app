import { describe, expect, it, vi } from 'vitest'
import api from './axios'
import { getAccessToken, getRefreshToken, onSessionExpired, saveTokens } from './session'
import { http, HttpResponse, server } from '../test/server'

/** A protected endpoint that only accepts the given access token. */
function protectedRoute(path, acceptedToken) {
  return http.get(path, ({ request }) =>
    request.headers.get('Authorization') === `Bearer ${acceptedToken}`
      ? HttpResponse.json({ ok: true })
      : HttpResponse.json({ message: 'expired' }, { status: 401 }))
}

function refreshRoute({ onCall = () => {}, succeed = true } = {}) {
  return http.post('/api/auth/refresh', async ({ request }) => {
    onCall(await request.json())
    return succeed
      ? HttpResponse.json({ token: 'access-2', refreshToken: 'refresh-2', expiresIn: 1800 })
      : HttpResponse.json({ message: 'Your session has ended.' }, { status: 401 })
  })
}

describe('api client', () => {
  it('sends the stored access token', async () => {
    saveTokens({ token: 'access-1', refreshToken: 'refresh-1' })
    server.use(protectedRoute('/api/crops', 'access-1'))

    const { data } = await api.get('/crops')

    expect(data.ok).toBe(true)
  })

  it('refreshes an expired token once and retries the request', async () => {
    saveTokens({ token: 'access-1', refreshToken: 'refresh-1' })
    const sent = []
    server.use(protectedRoute('/api/crops', 'access-2'), refreshRoute({ onCall: (body) => sent.push(body) }))

    const { data } = await api.get('/crops')

    expect(data.ok).toBe(true)
    expect(sent).toEqual([{ refreshToken: 'refresh-1' }])
    expect(getAccessToken()).toBe('access-2')
    expect(getRefreshToken()).toBe('refresh-2')
  })

  // Refresh tokens are single-use: if each failing request refreshed on its
  // own, the second would replay a spent token and the server would revoke
  // the whole session.
  it('shares one refresh between requests that expire together', async () => {
    saveTokens({ token: 'access-1', refreshToken: 'refresh-1' })
    let refreshCalls = 0
    server.use(
      protectedRoute('/api/crops', 'access-2'),
      protectedRoute('/api/reminders/due', 'access-2'),
      protectedRoute('/api/users/me', 'access-2'),
      refreshRoute({ onCall: () => { refreshCalls += 1 } }),
    )

    const results = await Promise.all([api.get('/crops'), api.get('/reminders/due'), api.get('/users/me')])

    expect(results.every((r) => r.data.ok)).toBe(true)
    expect(refreshCalls).toBe(1)
  })

  it('ends the session when the refresh is refused', async () => {
    saveTokens({ token: 'access-1', refreshToken: 'refresh-1' })
    const expired = vi.fn()
    const unsubscribe = onSessionExpired(expired)
    server.use(protectedRoute('/api/crops', 'never'), refreshRoute({ succeed: false }))

    await expect(api.get('/crops')).rejects.toMatchObject({ response: { status: 401 } })

    expect(expired).toHaveBeenCalledOnce()
    expect(getAccessToken()).toBeNull()
    expect(getRefreshToken()).toBeNull()
    unsubscribe()
  })

  it('does not try to refresh when there is no refresh token', async () => {
    saveTokens({ token: 'access-1' })
    const refresh = vi.fn()
    server.use(protectedRoute('/api/crops', 'never'), refreshRoute({ onCall: refresh }))

    await expect(api.get('/crops')).rejects.toMatchObject({ response: { status: 401 } })

    expect(refresh).not.toHaveBeenCalled()
  })

  it('treats a 401 from login as wrong credentials, not an expired session', async () => {
    const refresh = vi.fn()
    server.use(
      http.post('/api/auth/login', () => HttpResponse.json({ message: 'Invalid email or password' }, { status: 401 })),
      refreshRoute({ onCall: refresh }),
    )

    await expect(api.post('/auth/login', { email: 'a@b.c', password: 'x' }))
      .rejects.toMatchObject({ response: { status: 401 } })

    expect(refresh).not.toHaveBeenCalled()
  })

  it('leaves business-rule 403s alone', async () => {
    saveTokens({ token: 'access-1', refreshToken: 'refresh-1' })
    const refresh = vi.fn()
    server.use(
      http.get('/api/crops/1/insights', () => HttpResponse.json({ message: 'AI insights are off' }, { status: 403 })),
      refreshRoute({ onCall: refresh }),
    )

    await expect(api.get('/crops/1/insights')).rejects.toMatchObject({ response: { status: 403 } })

    expect(refresh).not.toHaveBeenCalled()
    expect(getAccessToken()).toBe('access-1')
  })
})
