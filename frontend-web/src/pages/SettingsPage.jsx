import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { useAuth } from '../context/AuthContext'
import { getMyProfile, updateMyProfile } from '../api/users'

const sectionTitle = {
  fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: '13px',
  color: 'var(--accent-lime)', textTransform: 'uppercase', letterSpacing: '1.5px', marginBottom: '14px',
}
const cardStyle = {
  background: 'var(--bg-card)', border: '1px solid var(--border)',
  borderRadius: '16px', backdropFilter: 'blur(12px)', marginBottom: '24px', overflow: 'hidden',
}
const labelStyle = {
  display: 'block', fontFamily: 'Inter', fontSize: '12px',
  color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500,
}
const inputStyle = {
  width: '100%', boxSizing: 'border-box', background: 'var(--bg-input)',
  border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 14px',
  fontFamily: 'Inter', fontSize: '14px', color: 'var(--text-primary)',
  outline: 'none', transition: 'border-color 0.2s, box-shadow 0.2s',
}

function InputField({ label, value, onChange, disabled, placeholder }) {
  return (
    <div>
      <label style={labelStyle}>{label}</label>
      <input
        value={value}
        onChange={onChange}
        disabled={disabled}
        placeholder={placeholder}
        style={{ ...inputStyle, opacity: disabled ? 0.5 : 1, cursor: disabled ? 'not-allowed' : 'text' }}
        onFocus={e => { if (!disabled) { e.target.style.borderColor = 'var(--border-hover)'; e.target.style.boxShadow = '0 0 12px rgba(74,222,128,0.1)' } }}
        onBlur={e => { e.target.style.borderColor = 'var(--border)'; e.target.style.boxShadow = 'none' }}
      />
    </div>
  )
}

export default function SettingsPage() {
  const { user, updateUser } = useAuth()
  const [fullName, setFullName] = useState(user?.fullName || '')
  const [email, setEmail] = useState(user?.email || '')
  const [phone, setPhone] = useState(user?.phone || '')
  const [city, setCity] = useState(user?.city || '')
  const [themePreference, setThemePreference] = useState(user?.themePreference || 'LIGHT')
  const [desktopMode, setDesktopMode] = useState(!!user?.desktopMode)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      try {
        const res = await getMyProfile()
        const data = res.data
        setFullName(data.fullName || '')
        setEmail(data.email || '')
        setPhone(data.phone || '')
        setCity(data.city || '')
        setThemePreference(data.themePreference || 'LIGHT')
        setDesktopMode(!!data.desktopMode)
      } catch {
        if (!user) setError('Failed to load settings.')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const handleThemeChange = (newTheme) => {
    if (newTheme === 'DESKTOP') {
      setDesktopMode(true)
      updateUser({ desktopMode: true })
    } else {
      setDesktopMode(false)
      setThemePreference(newTheme)
      updateUser({ themePreference: newTheme, desktopMode: false })
    }
  }

  const activeThemeKey = desktopMode ? 'DESKTOP' : themePreference

  const saveSettings = async () => {
    setSaving(true)
    setMessage('')
    setError('')
    try {
      const res = await updateMyProfile({ fullName, phone, city, themePreference, desktopMode })
      const updated = res.data
      updateUser({
        fullName: updated.fullName, email: updated.email,
        phone: updated.phone, city: updated.city,
        themePreference: updated.themePreference, desktopMode: updated.desktopMode,
      })
      setMessage('Settings saved successfully.')
      setTimeout(() => setMessage(''), 3000)
    } catch {
      setError('Failed to save settings.')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <Layout>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '200px' }}>
          <div style={{ fontFamily: 'Inter', fontSize: '14px', color: 'var(--text-muted)' }}>Loading settings…</div>
        </div>
      </Layout>
    )
  }

  const THEME_OPTIONS = [
    { id: 'DARK',    label: 'Dark Mode',    icon: '🌙', desc: 'Deep forest green — easy on eyes at night' },
    { id: 'LIGHT',   label: 'Light Mode',   icon: '☀️', desc: 'Clean and bright — great for daytime use' },
    { id: 'DESKTOP', label: 'Desktop Mode', icon: '🖥️', desc: 'Follows your system dark/light preference' },
  ]

  return (
    <Layout>
      {error && (
        <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '20px' }}>
          {error}
        </div>
      )}

      {/* ── Appearance ── */}
      <div style={{ marginBottom: '28px' }}>
        <div style={sectionTitle}>Appearance</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
          {THEME_OPTIONS.map(t => {
            const active = activeThemeKey === t.id
            return (
              <div
                key={t.id}
                onClick={() => handleThemeChange(t.id)}
                style={{
                  padding: '22px', borderRadius: '14px',
                  border: `2px solid ${active ? 'var(--accent-lime)' : 'var(--border)'}`,
                  background: active ? 'rgba(74,222,128,0.07)' : 'var(--bg-card)',
                  backdropFilter: 'blur(12px)',
                  cursor: 'pointer', transition: 'all 0.2s',
                  boxShadow: active ? '0 0 20px rgba(74,222,128,0.15)' : 'none',
                }}
                onMouseEnter={e => { if (!active) e.currentTarget.style.borderColor = 'var(--border-hover)' }}
                onMouseLeave={e => { if (!active) e.currentTarget.style.borderColor = 'var(--border)' }}
              >
                <div style={{ fontSize: '30px', marginBottom: '12px' }}>{t.icon}</div>
                <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)', marginBottom: '5px' }}>{t.label}</div>
                <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', lineHeight: 1.5 }}>{t.desc}</div>
                {active && (
                  <div style={{ marginTop: '14px', display: 'inline-flex', alignItems: 'center', gap: '5px', background: 'rgba(74,222,128,0.12)', border: '1px solid rgba(74,222,128,0.25)', borderRadius: '100px', padding: '3px 10px' }}>
                    <div style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent-lime)' }} />
                    <span style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--accent-lime)', fontWeight: 600 }}>Active</span>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {/* ── Profile ── */}
      <div style={{ marginBottom: '28px' }}>
        <div style={sectionTitle}>Profile</div>
        <div style={{ ...cardStyle, padding: '24px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div style={{ gridColumn: '1 / -1' }}>
              <InputField label="Full Name" value={fullName} onChange={e => setFullName(e.target.value)} placeholder="Your full name" />
            </div>
            <InputField label="Email (read-only)" value={email} onChange={() => {}} disabled />
            <InputField label="Phone" value={phone} onChange={e => setPhone(e.target.value)} placeholder="+94 71 234 5678" />
            <div style={{ gridColumn: '1 / -1' }}>
              <InputField label="City" value={city} onChange={e => setCity(e.target.value)} placeholder="e.g. Colombo" />
            </div>
          </div>
        </div>
      </div>

      {/* ── Save ── */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px', paddingBottom: '40px' }}>
        <button onClick={saveSettings} disabled={saving} className="agro-btn" style={{ padding: '13px 36px' }}>
          {saving ? 'Saving…' : 'Save Changes'}
        </button>
        {message && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontFamily: 'Inter', fontSize: '14px', color: 'var(--accent-lime)' }}>
            <span>✓</span> {message}
          </div>
        )}
      </div>
    </Layout>
  )
}
