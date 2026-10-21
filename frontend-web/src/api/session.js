// The one place that knows where tokens are kept. The axios client reads
// them, the auth context writes them, and nothing else touches storage.

const ACCESS_KEY = 'token'
const REFRESH_KEY = 'refreshToken'

export const getAccessToken = () => localStorage.getItem(ACCESS_KEY)

export const getRefreshToken = () => localStorage.getItem(REFRESH_KEY)

export function saveTokens({ token, refreshToken }) {
  if (token) localStorage.setItem(ACCESS_KEY, token)
  if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken)
}

export function clearTokens() {
  localStorage.removeItem(ACCESS_KEY)
  localStorage.removeItem(REFRESH_KEY)
}

// The axios client finds out a session is over (refresh refused) but cannot
// navigate; the auth context can. This is the wire between them.
const expiryListeners = new Set()

export function onSessionExpired(listener) {
  expiryListeners.add(listener)
  return () => expiryListeners.delete(listener)
}

export function notifySessionExpired() {
  expiryListeners.forEach((listener) => listener())
}
