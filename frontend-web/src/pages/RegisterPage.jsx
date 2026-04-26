import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'

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

export default function RegisterPage() {
  const [form, setForm] = useState({ fullName: '', email: '', password: '', confirmPassword: '', phone: '', city: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const { login } = useAuth()
  const navigate = useNavigate()

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    if (form.password !== form.confirmPassword) { setError('Passwords do not match'); return }
    if (form.password.length < 8) { setError('Password must be at least 8 characters'); return }
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
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              <StyledInput label="Full Name *" name="fullName" value={form.fullName} onChange={handleChange} placeholder="Kamal Perera" required />
              <StyledInput label="Email *" type="email" name="email" value={form.email} onChange={handleChange} placeholder="farmer@example.com" required />
              <StyledInput label="Phone" name="phone" value={form.phone} onChange={handleChange} placeholder="+94 77 123 4567" half />
              <StyledInput label="City" name="city" value={form.city} onChange={handleChange} placeholder="Ratnapura" half />
              <StyledInput label="Password *" type="password" name="password" value={form.password} onChange={handleChange} placeholder="Min. 8 characters" required half />
              <StyledInput label="Confirm Password *" type="password" name="confirmPassword" value={form.confirmPassword} onChange={handleChange} placeholder="Repeat password" required half />
            </div>
            <button type="submit" disabled={loading} className="agro-btn" style={{ width: '100%', marginTop: '16px' }}>
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
