import axios from 'axios'
import {
  clearTokens, getAccessToken, getRefreshToken, notifySessionExpired, saveTokens,
} from './session'

const api = axios.create({
  baseURL: '/api',
})

// Automatically attach JWT token to every request
api.interceptors.request.use((config) => {
  const token = getAccessToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Calls where a 401 means "wrong credentials", not "token expired".
// Refreshing and retrying those would be wrong, and for /auth/refresh itself
// it would loop.
const NO_REFRESH = ['/auth/login', '/auth/refresh', '/auth/google', '/auth/register']

// One refresh at a time. When the token expires, every request in flight
// fails together; without this each would spend the same single-use refresh
// token, and the server would treat the second use as theft and revoke the
// session.
let refreshing = null

function refreshSession() {
  if (!refreshing) {
    const refreshToken = getRefreshToken()
    refreshing = (refreshToken
      ? axios.post('/api/auth/refresh', { refreshToken })
      : Promise.reject(new Error('No refresh token')))
      .then(({ data }) => {
        saveTokens(data)
        return data.token
      })
      .finally(() => { refreshing = null })
  }
  return refreshing
}

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const { config, response } = error
    const eligible = response?.status === 401
      && config
      && !config._retried
      && !NO_REFRESH.some((path) => config.url?.startsWith(path))

    if (!eligible) {
      return Promise.reject(error)
    }

    try {
      const token = await refreshSession()
      config._retried = true
      config.headers.Authorization = `Bearer ${token}`
      return api(config)
    } catch {
      clearTokens()
      notifySessionExpired()
      return Promise.reject(error)
    }
  },
)

export default api
