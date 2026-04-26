import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'

function StyledInput({ label, type = 'text', value, onChange, placeholder, name, required }) {
  const [focused, setFocused] = useState(false)
  return (
    <div style={{ marginBottom: '16px' }}>
      <label style={{
        display: 'block', fontFamily: 'Inter, sans-serif',
        fontSize: '12px', fontWeight: 600,
        color: 'var(--text-muted)', marginBottom: '6px',
        textTransform: 'uppercase', letterSpacing: '0.5px',
      }}>{label}</label>
      <input
        type={type} value={value} onChange={onChange}
        placeholder={placeholder} name={name} required={required}
        onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
        style={{
          width: '100%', boxSizing: 'border-box',
          background: 'var(--bg-input)',
          border: `1.5px solid ${focused ? 'var(--accent-lime)' : 'var(--border)'}`,
          borderRadius: '10px', padding: '12px 14px',
          fontFamily: 'Inter', fontSize: '14px',
          color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
          boxShadow: focused ? '0 0 0 3px rgba(74,222,128,0.1)' : 'none',
        }}
      />
    </div>
  )
}

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleLogin = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const response = await api.post('/auth/login', { email, password })
      const { token, fullName, email: userEmail, city, themePreference, desktopMode } = response.data
      login({ fullName, email: userEmail, city, themePreference, desktopMode }, token)
      navigate('/dashboard')
    } catch {
      setError('Invalid email or password. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{
      minHeight: '100vh',
      background: 'var(--bg-primary)',
      display: 'flex',
    }}>
      {/* Left panel — branding */}
      <div style={{
        display: 'none',
        flex: '0 0 420px',
        background: 'linear-gradient(160deg, #0d2b1a 0%, #071408 100%)',
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'column',
        gap: '32px',
        padding: '60px',
        position: 'relative',
        overflow: 'hidden',
        // Show on wider screens via media query workaround via inline JSX:
      }}>
        <div style={{
          position: 'absolute', inset: 0,
          background: 'radial-gradient(ellipse at 40% 50%, rgba(74,222,128,0.12) 0%, transparent 70%)',
          pointerEvents: 'none',
        }} />
        <div style={{ textAlign: 'center', position: 'relative' }}>
          <div style={{ fontSize: '64px', marginBottom: '20px' }}>🌿</div>
          <div style={{ fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '32px', color: '#e8f5e2', letterSpacing: '-1px', marginBottom: '12px' }}>Agromaster</div>
          <div style={{ fontFamily: 'Inter', fontSize: '15px', color: 'rgba(232,245,226,0.6)', lineHeight: 1.6 }}>Smart crop management for Sri Lankan farmers</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', width: '100%' }}>
          {['Track every crop from seed to harvest', 'Monitor expenses and revenue clearly', 'AI-powered farming advice, 24/7'].map((f, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#4ade80', flexShrink: 0 }} />
              <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'rgba(232,245,226,0.7)' }}>{f}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Right panel — form */}
      <div style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '40px 24px',
      }}>
        <div style={{ width: '100%', maxWidth: '400px' }}>

          {/* Logo */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '36px' }}>
            <div style={{
              width: 44, height: 44, borderRadius: '12px',
              background: 'linear-gradient(135deg, #4ade80, #16a34a)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: '22px', boxShadow: '0 0 24px rgba(74,222,128,0.4)',
            }}>🌿</div>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '22px', color: 'var(--text-primary)', letterSpacing: '-0.5px', lineHeight: 1 }}>Agromaster</div>
              <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)', marginTop: '3px' }}>Farm Management Platform</div>
            </div>
          </div>

          {/* Heading */}
          <div style={{ marginBottom: '28px' }}>
            <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '26px', color: 'var(--text-primary)', margin: '0 0 6px', letterSpacing: '-0.5px' }}>Welcome back</h1>
            <p style={{ fontFamily: 'Inter', fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>Sign in to your farm dashboard</p>
          </div>

          {/* Card */}
          <div className="auth-card" style={{
            background: 'var(--bg-card)',
            border: '1px solid var(--border)',
            borderRadius: '20px',
            padding: '32px',
            backdropFilter: 'blur(16px)',
          }}>
            {error && (
              <div style={{
                background: 'rgba(248,113,113,0.08)', border: '1px solid rgba(248,113,113,0.25)',
                borderRadius: '10px', padding: '11px 14px',
                fontFamily: 'Inter', fontSize: '13px', color: 'var(--accent-red)',
                marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px',
              }}>
                <span>⚠</span> {error}
              </div>
            )}
            <form onSubmit={handleLogin}>
              <StyledInput label="Email" type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="farmer@example.com" required />
              <StyledInput label="Password" type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="••••••••" required />
              <div style={{ textAlign: 'right', marginTop: '-8px', marginBottom: '20px' }}>
                <a href="#" style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--accent-lime)', textDecoration: 'none' }}>Forgot password?</a>
              </div>
              <button type="submit" disabled={loading} className="agro-btn" style={{ width: '100%' }}>
                {loading ? 'Signing in…' : 'Sign In'}
              </button>
            </form>
          </div>

          <div style={{ marginTop: '20px', textAlign: 'center', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>
            Don't have an account?{' '}
            <Link to="/register" style={{ color: 'var(--accent-lime)', fontWeight: 600, textDecoration: 'none' }}>Create one free</Link>
          </div>
        </div>
      </div>
    </div>
  )
}
