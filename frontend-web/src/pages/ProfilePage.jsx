import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { useAuth } from '../context/AuthContext'
import { getMyProfile, updateMyProfile } from '../api/users'

const inputStyle = {
  width: '100%', boxSizing: 'border-box',
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '10px', padding: '10px 14px',
  fontFamily: 'Inter, sans-serif', fontSize: '14px',
  color: 'var(--text-primary)', outline: 'none',
  transition: 'border-color 0.2s',
}

const labelStyle = {
  display: 'block', fontFamily: 'Inter', fontSize: '12px',
  color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500,
}

export default function ProfilePage() {
  const { updateUser } = useAuth()
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', city: '' })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError('')
      try {
        const res = await getMyProfile()
        const data = res.data
        setForm({ fullName: data.fullName || '', email: data.email || '', phone: data.phone || '', city: data.city || '' })
      } catch {
        setError('Failed to load profile.')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const handleChange = (e) => setForm(prev => ({ ...prev, [e.target.name]: e.target.value }))

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setMessage('')
    setError('')
    try {
      const res = await updateMyProfile({ fullName: form.fullName, phone: form.phone, city: form.city })
      const updated = res.data
      updateUser({ fullName: updated.fullName, email: updated.email, phone: updated.phone, city: updated.city, themePreference: updated.themePreference, desktopMode: updated.desktopMode })
      setMessage('Profile updated successfully.')
    } catch {
      setError('Failed to save profile changes.')
    } finally {
      setSaving(false)
    }
  }

  const initials = (form.fullName || 'U').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()

  return (
    <Layout>
      <div style={{ maxWidth: '600px' }}>

        {/* Profile avatar + name header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '18px', marginBottom: '28px' }}>
          <div style={{
            width: 56, height: 56, borderRadius: '50%',
            background: 'linear-gradient(135deg, #4ade80, #16a34a)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: '20px', fontWeight: 700, color: '#0a1a0f',
            fontFamily: 'Space Grotesk', flexShrink: 0,
            boxShadow: '0 0 20px rgba(74,222,128,0.25)',
          }}>
            {initials}
          </div>
          <div>
            <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '22px', color: 'var(--text-primary)', margin: 0, letterSpacing: '-0.5px' }}>
              {form.fullName || 'Your Profile'}
            </h1>
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', marginTop: '2px' }}>
              {form.email}
            </p>
          </div>
        </div>

        {/* Card */}
        <div style={{
          background: 'var(--bg-card)',
          border: '1px solid var(--border)',
          borderRadius: '16px',
          backdropFilter: 'blur(12px)',
          padding: '28px',
        }}>
          <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 20px 0' }}>
            Edit Profile
          </h2>

          {loading ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '20px 0' }}>
              <div style={{ width: 22, height: 22, border: '3px solid rgba(74,222,128,0.2)', borderTopColor: '#4ade80', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
              <p style={{ fontFamily: 'Inter', color: 'var(--text-muted)', fontSize: '14px' }}>Loading profile…</p>
            </div>
          ) : (
            <form onSubmit={handleSubmit}>
              {message && (
                <div style={{ background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#4ade80', marginBottom: '16px' }}>
                  {message}
                </div>
              )}
              {error && (
                <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>
                  {error}
                </div>
              )}

              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <label style={labelStyle}>Full Name</label>
                  <input
                    name="fullName"
                    value={form.fullName}
                    onChange={handleChange}
                    required
                    placeholder="Your full name"
                    style={inputStyle}
                    onFocus={e => e.target.style.borderColor = 'var(--accent-lime)'}
                    onBlur={e => e.target.style.borderColor = 'var(--border)'}
                  />
                </div>

                <div>
                  <label style={labelStyle}>Email Address</label>
                  <input
                    name="email"
                    value={form.email}
                    disabled
                    style={{ ...inputStyle, opacity: 0.55, cursor: 'not-allowed' }}
                  />
                  <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)', marginTop: '4px' }}>Email cannot be changed</p>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                  <div>
                    <label style={labelStyle}>Phone</label>
                    <input
                      name="phone"
                      value={form.phone}
                      onChange={handleChange}
                      placeholder="+94 71 234 5678"
                      style={inputStyle}
                      onFocus={e => e.target.style.borderColor = 'var(--accent-lime)'}
                      onBlur={e => e.target.style.borderColor = 'var(--border)'}
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>City</label>
                    <input
                      name="city"
                      value={form.city}
                      onChange={handleChange}
                      placeholder="e.g. Colombo"
                      style={inputStyle}
                      onFocus={e => e.target.style.borderColor = 'var(--accent-lime)'}
                      onBlur={e => e.target.style.borderColor = 'var(--border)'}
                    />
                  </div>
                </div>

                <div style={{ paddingTop: '4px' }}>
                  <button
                    type="submit"
                    disabled={saving}
                    className="agro-btn"
                    style={{ padding: '11px 28px', fontSize: '14px', opacity: saving ? 0.6 : 1 }}
                  >
                    {saving ? 'Saving…' : 'Save Profile'}
                  </button>
                </div>
              </div>
            </form>
          )}
        </div>
      </div>
    </Layout>
  )
}
