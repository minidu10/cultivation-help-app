import { createContext, useContext, useEffect, useState } from 'react'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('user')
    return saved ? JSON.parse(saved) : null
  })

  useEffect(() => {
    const media = window.matchMedia('(prefers-color-scheme: dark)')

    const applyTheme = () => {
      const manualTheme = (user?.themePreference || 'LIGHT').toUpperCase()
      const followSystem = !!user?.desktopMode
      const resolvedTheme = followSystem
        ? (media.matches ? 'DARK' : 'LIGHT')
        : manualTheme

      document.documentElement.classList.remove('theme-light', 'theme-dark')
      document.documentElement.classList.add(
        resolvedTheme === 'DARK' ? 'theme-dark' : 'theme-light'
      )
      document.documentElement.style.colorScheme =
        resolvedTheme === 'DARK' ? 'dark' : 'light'
    }

    applyTheme()
    media.addEventListener('change', applyTheme)
    return () => media.removeEventListener('change', applyTheme)
  }, [user])

  const login = (userData, token) => {
    localStorage.setItem('token', token)
    localStorage.setItem('user', JSON.stringify(userData))
    setUser(userData)
  }

  const logout = () => {
    localStorage.removeItem('token')
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
    <AuthContext.Provider value={{ user, login, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  return useContext(AuthContext)
}