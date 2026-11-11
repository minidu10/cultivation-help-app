import { useState } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'
import GoogleSignIn from '../components/GoogleSignIn'
import { AuthShell, StyledInput, Alert } from '../components/AuthUI'

const linkStyle = { color: 'var(--accent-lime)', fontWeight: 600, textDecoration: 'none' }

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const notice = location.state?.message

  const handleLogin = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const response = await api.post('/auth/login', { email, password })
      const { token, refreshToken, fullName, email: userEmail, city, themePreference, desktopMode } = response.data
      login({ fullName, email: userEmail, city, themePreference, desktopMode }, token, refreshToken)
      navigate('/dashboard')
    } catch {
      setError('Invalid email or password. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthShell
      title="Welcome back"
      subtitle="Sign in to your farm records."
      footer={<>Don't have an account?{' '}<Link to="/register" style={linkStyle}>Create one free</Link></>}
    >
      {!error && <Alert kind="success">{notice}</Alert>}
      <Alert>{error}</Alert>

      <form onSubmit={handleLogin} style={{ display: 'grid', gap: '16px' }}>
        <StyledInput label="Email" type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="farmer@example.com" autoComplete="email" required />
        <StyledInput label="Password" type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Your password" autoComplete="current-password" required />
        <div style={{ textAlign: 'right', marginTop: '-6px' }}>
          <Link to="/forgot-password" style={{ ...linkStyle, fontSize: '14px', fontWeight: 500 }}>Forgot password?</Link>
        </div>
        <button type="submit" disabled={loading} className="agro-btn" style={{ width: '100%', padding: '15px 22px', fontSize: '16px' }}>
          {loading ? 'Signing in…' : 'Sign in'}
        </button>
      </form>

      <GoogleSignIn onError={setError} text="signin_with" />
    </AuthShell>
  )
}
