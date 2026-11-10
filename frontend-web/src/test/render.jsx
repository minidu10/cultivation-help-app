import { render } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { AuthProvider } from '../context/AuthContext'

export const TEST_USER = {
  fullName: 'Test Farmer',
  email: 'farmer@example.com',
  city: '',
  themePreference: 'LIGHT',
  desktopMode: false,
}

/** Puts a signed-in session in storage, as if the user had logged in earlier. */
export function signIn({ token = 'access-1', refreshToken = 'refresh-1', user = TEST_USER } = {}) {
  localStorage.setItem('token', token)
  localStorage.setItem('refreshToken', refreshToken)
  localStorage.setItem('user', JSON.stringify(user))
}

/** Renders inside the same providers main.jsx sets up. */
export function renderWithApp(ui, { route = '/' } = {}) {
  return render(
    <MemoryRouter initialEntries={[route]}>
      <AuthProvider>{ui}</AuthProvider>
    </MemoryRouter>,
  )
}
