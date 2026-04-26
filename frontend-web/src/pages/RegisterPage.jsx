import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'
import { useIsMobile } from '../hooks/useIsMobile'

function getPasswordStrength(password) {
  if (!password) return { score: 0, label: '', color: '' }
  let score = 0
  if (password.length >= 8)  score++
  if (password.length >= 12) score++
  if (/[A-Z]/.test(password)) score++
  if (/[a-z]/.test(password)) score++
  if (/[0-9]/.test(password)) score++
  if (/[^A-Za-z0-9]/.test(password)) score++

  if (score <= 2) return { score, label: 'Weak',   color: '#f87171' }
  if (score <= 4) return { score, label: 'Fair',   color: '#f59e0b' }
  if (score <= 5) return { score, label: 'Good',   color: '#60a5fa' }
  return             { score, label: 'Strong', color: '#4ade80' }
}

function validatePassword(password) {
  const errors = []
  if (password.length < 8)           errors.push('At least 8 characters')
  if (!/[A-Z]/.test(password))       errors.push('At least one uppercase letter')
  if (!/[a-z]/.test(password))       errors.push('At least one lowercase letter')
  if (!/[0-9]/.test(password))       errors.push('At least one number')
  if (!/[^A-Za-z0-9]/.test(password)) errors.push('At least one special character (!@#$...)')
  return errors
}

function StyledInput({ label, type = 'text', value, onChange, placeholder, name, required, half }) {
  const [focused, setFocused] = useState(false)
  return (
    <div style={{ gridColumn: half ? 'span 1' : '1 / -1' }}>
      <label style={{
        display: 'block', fontFamily: 'Inter',
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
          borderRadius: '10px', padding: '11px 14px',
          fontFamily: 'Inter', fontSize: '14px',
          color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
          boxShadow: focused ? '0 0 0 3px rgba(74,222,128,0.1)' : 'none',
        }}
      />
    </div>
  )
}

function PasswordStrengthBar({ password }) {
  const { score, label, color } = getPasswordStrength(password)
  if (!password) return null
  const pct = Math.round((score / 6) * 100)

  return (
    <div style={{ marginTop: '8px' }}>
      <div style={{ height: '4px', borderRadius: '99px', background: 'var(--border)', overflow: 'hidden' }}>
        <div style={{
          height: '100%', width: `${pct}%`,
          background: color,
          borderRadius: '99px',
          transition: 'width 0.3s, background 0.3s',
        }} />
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '5px' }}>
        <span style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)' }}>
          Password strength
        </span>
        <span style={{ fontFamily: 'Inter', fontSize: '11px', fontWeight: 600, color }}>{label}</span>
      </div>
    </div>
  )
}

export default function RegisterPage() {
  const isMobile = useIsMobile()
  const [form, setForm] = useState({ fullName: '', email: '', password: '', confirmPassword: '', phone: '', city: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    const pwErrors = validatePassword(form.password)
    if (pwErrors.length > 0) {
      setError('Weak password: ' + pwErrors[0])
      return
    }
    if (form.password !== form.confirmPassword) {
      setError('Passwords do not match')
      return
    }

    setLoading(true)
    try {
      const response = await api.post('/auth/register', {
        fullName: form.fullName, email: form.email,
        password: form.password, phone: form.phone, city: form.city,
      })
      const { token, fullName, email, city, themePreference, desktopMode } = response.data
      login({ fullName, email, city, themePreference, desktopMode }, token)
      navigate('/dashboard')
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed. Email may already be used.')
    } finally {
      setLoading(false)
    }
  }

  const pwErrors = validatePassword(form.password)
  const pwStrength = getPasswordStrength(form.password)

  return (
    <div style={{
      minHeight: '100vh',
      background: 'var(--bg-primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '40px 24px',
    }}>
      <div style={{ width: '100%', maxWidth: '480px' }}>

        {/* Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '28px' }}>
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
        <div style={{ marginBottom: '24px' }}>
          <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '26px', color: 'var(--text-primary)', margin: '0 0 6px', letterSpacing: '-0.5px' }}>Create your account</h1>
        </div>

        {/* Card */}
        <div className="auth-card" style={{
          background: 'var(--bg-card)',
          border: '1px solid var(--border)',
          borderRadius: '20px',
          padding: '28px 32px 32px',
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

          <form onSubmit={handleSubmit}>
            <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '12px' }}>
              <StyledInput label="Full Name *" name="fullName" value={form.fullName} onChange={handleChange} placeholder="Kamal Perera" required />
              <StyledInput label="Email *" type="email" name="email" value={form.email} onChange={handleChange} placeholder="farmer@example.com" required />
              <StyledInput label="Phone" name="phone" value={form.phone} onChange={handleChange} placeholder="+94 77 123 4567" half />
              <StyledInput label="City" name="city" value={form.city} onChange={handleChange} placeholder="Ratnapura" half />

              {/* Password field with strength meter */}
              <div style={{ gridColumn: isMobile ? '1 / -1' : 'span 1' }}>
                <label style={{
                  display: 'block', fontFamily: 'Inter', fontSize: '12px', fontWeight: 600,
                  color: 'var(--text-muted)', marginBottom: '6px',
                  textTransform: 'uppercase', letterSpacing: '0.5px',
                }}>Password *</label>
                <input
                  type="password" name="password" value={form.password}
                  onChange={handleChange} placeholder="Min. 8 characters" required
                  style={{
                    width: '100%', boxSizing: 'border-box',
                    background: 'var(--bg-input)',
                    border: `1.5px solid ${form.password && pwErrors.length === 0 ? '#4ade80' : form.password ? '#f87171' : 'var(--border)'}`,
                    borderRadius: '10px', padding: '11px 14px',
                    fontFamily: 'Inter', fontSize: '14px',
                    color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
                  }}
                />
                <PasswordStrengthBar password={form.password} />
                {form.password && pwErrors.length > 0 && (
                  <ul style={{ margin: '6px 0 0', paddingLeft: '16px', listStyle: 'disc' }}>
                    {pwErrors.map(e => (
                      <li key={e} style={{ fontFamily: 'Inter', fontSize: '11px', color: '#f87171', lineHeight: 1.6 }}>{e}</li>
                    ))}
                  </ul>
                )}
              </div>

              <StyledInput label="Confirm Password *" type="password" name="confirmPassword" value={form.confirmPassword} onChange={handleChange} placeholder="Repeat password" required half />
            </div>

            {/* Password rules hint */}
            <div style={{ marginTop: '10px', padding: '10px 14px', background: 'rgba(74,222,128,0.05)', border: '1px solid rgba(74,222,128,0.12)', borderRadius: '8px' }}>
              <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)', margin: 0, lineHeight: 1.7 }}>
                Password must include: uppercase &amp; lowercase letters, a number, and a special character (e.g. !@#$%)
              </p>
            </div>

            <button
              type="submit"
              disabled={loading || pwErrors.length > 0 || !form.password}
              className="agro-btn"
              style={{ width: '100%', marginTop: '16px', opacity: (pwErrors.length > 0 && form.password) ? 0.5 : 1 }}
            >
              {loading ? 'Creating account…' : 'Start Growing Free'}
            </button>
          </form>
        </div>

        <div style={{ marginTop: '20px', textAlign: 'center', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>
          Already have an account?{' '}
          <Link to="/login" style={{ color: 'var(--accent-lime)', fontWeight: 600, textDecoration: 'none' }}>Sign in</Link>
        </div>
      </div>
    </div>
  )
}
