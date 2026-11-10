import { createContext, useContext, useEffect, useState } from 'react'
import { logoutSession } from '../api/auth'
import { clearTokens, getRefreshToken, onSessionExpired, saveTokens } from '../api/session'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('user')
    return saved ? JSON.parse(saved) : null
  })
  // Set when the server refused to renew the session, so the app can say why
  // the user landed on the login page instead of silently dropping them there.
  const [sessionExpired, setSessionExpired] = useState(false)

  useEffect(() => onSessionExpired(() => {
    localStorage.removeItem('user')
    setUser(null)
    setSessionExpired(true)
  }), [])

  useEffect(() => {
    const media = window.matchMedia('(prefers-color-scheme: dark)')

    const applyTheme = () => {
      const manualTheme = (user?.themePreference || 'LIGHT').toUpperCase()
      const followSystem = !!user?.desktopMode
      const resolvedTheme = followSystem
        ? (media.matches ? 'DARK' : 'LIGHT')
        : manualTheme

      if (resolvedTheme === 'LIGHT') {
        document.documentElement.setAttribute('data-theme', 'light')
      } else {
        document.documentElement.removeAttribute('data-theme')
      }
      document.documentElement.style.colorScheme =
        resolvedTheme === 'DARK' ? 'dark' : 'light'
    }

    applyTheme()
    media.addEventListener('change', applyTheme)
    return () => media.removeEventListener('change', applyTheme)
  }, [user])

  const login = (userData, token, refreshToken) => {
    saveTokens({ token, refreshToken })
    localStorage.setItem('user', JSON.stringify(userData))
    setUser(userData)
    setSessionExpired(false)
  }

  const logout = () => {
    const refreshToken = getRefreshToken()
    // Best effort: signing out locally must not wait on, or fail with, the network.
    if (refreshToken) logoutSession(refreshToken).catch(() => {})
    clearTokens()
    localStorage.removeItem('user')
    setUser(null)
  }

  const updateUser = (partialUserData) => {
    setUser((prev) => {
      const next = { ...(prev || {}), ...partialUserData }
      localStorage.setItem('user', JSON.stringify(next))
      return next
    })
  }

  return (
    <AuthContext.Provider value={{ user, login, logout, updateUser, sessionExpired }}>
      {children}
    </AuthContext.Provider>
  )
}

// Kept alongside the provider deliberately; splitting it into its own module
// for fast-refresh's sake would fragment the context for no runtime gain.
// eslint-disable-next-line react-refresh/only-export-components
export function useAuth() {
  return useContext(AuthContext)
}