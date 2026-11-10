import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'

// Requests the shell of the app makes on almost every page. Individual tests
// add or override handlers for the endpoints they are about.
export const defaultHandlers = [
  http.get('/api/auth/config', () => HttpResponse.json({ googleClientId: '', googleEnabled: false })),
  http.get('/api/weather/*', () => HttpResponse.json({ message: 'Weather is not configured' }, { status: 503 })),
  http.get('/api/alerts', () => HttpResponse.json([])),
]

export const server = setupServer(...defaultHandlers)

export { http, HttpResponse }
