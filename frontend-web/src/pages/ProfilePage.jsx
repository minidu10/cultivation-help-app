import { useEffect, useRef, useState } from 'react'
import Avatar from '../components/Avatar'
import Layout from '../components/Layout'
import { useAuth } from '../context/AuthContext'
import { getMyProfile, removeMyPhoto, updateMyProfile, uploadMyPhoto } from '../api/users'
import { resizePhoto } from '../utils/resizePhoto'
import { useIsMobile } from '../hooks/useIsMobile'

const inputStyle = {
  width: '100%', boxSizing: 'border-box',
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '10px', padding: '10px 14px',
  fontFamily: 'var(--font-body)', fontSize: '14px',
  color: 'var(--text-primary)', outline: 'none',
  transition: 'border-color 0.2s',
}

const labelStyle = {
  display: 'block', fontFamily: 'var(--font-body)', fontSize: '12px',
  color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500,
}

export default function ProfilePage() {
  const isMobile = useIsMobile()
  const { user, updateUser } = useAuth()
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

  const fileRef = useRef(null)
  const [photoBusy, setPhotoBusy] = useState(false)
  const [photoError, setPhotoError] = useState('')

  const choosePhoto = async (e) => {
    const file = e.target.files?.[0]
    e.target.value = ''
    if (!file) return
    setPhotoBusy(true)
    setPhotoError('')
    try {
      const res = await uploadMyPhoto(await resizePhoto(file, 512))
      updateUser({ avatarVersion: res.data.avatarVersion })
    } catch (err) {
      setPhotoError(err.response?.data?.message || 'Could not save the photo. Try another one.')
    } finally { setPhotoBusy(false) }
  }

  const removePhoto = async () => {
    setPhotoBusy(true)
    setPhotoError('')
    try {
      await removeMyPhoto()
      updateUser({ avatarVersion: null })
    } catch {
      setPhotoError('Could not remove the photo.')
    } finally { setPhotoBusy(false) }
  }

  return (
    <Layout>
      <div style={{ maxWidth: '600px' }}>

        {/* Profile avatar + name header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '18px', marginBottom: '28px' }}>
          <Avatar
            name={form.fullName}
            version={user?.avatarVersion}
            size={72}
            style={{ background: 'var(--accent-lime)', color: 'var(--on-accent)', fontFamily: 'var(--font-body)' }}
          />
          <div>
            <h1 style={{ fontFamily: 'var(--font-body)', fontWeight: 800, fontSize: '22px', color: 'var(--text-primary)', margin: 0, letterSpacing: '-0.5px' }}>
              {form.fullName || 'Your Profile'}
            </h1>
            <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-faint)', marginTop: '2px' }}>
              {form.email}
            </p>
            <div style={{ display: 'flex', gap: '8px', marginTop: '8px', flexWrap: 'wrap' }}>
              <input ref={fileRef} type="file" accept="image/jpeg,image/png" hidden onChange={choosePhoto} />
              <button type="button" className="ghost-btn" style={{ padding: '6px 14px', fontSize: '13px' }}
                disabled={photoBusy} onClick={() => fileRef.current?.click()}>
                {photoBusy ? 'Saving…' : user?.avatarVersion ? 'Change photo' : 'Add photo'}
              </button>
              {user?.avatarVersion && (
                <button type="button" className="ghost-btn" style={{ padding: '6px 14px', fontSize: '13px' }}
                  disabled={photoBusy} onClick={removePhoto}>Remove</button>
              )}
            </div>
            {photoError && <p role="alert" style={{ fontSize: '13px', color: 'var(--loss)', margin: '6px 0 0' }}>{photoError}</p>}
          </div>
        </div>

        {/* Card */}
        <div style={{
          background: 'var(--bg-card)',
          border: '1px solid var(--border)',
          borderRadius: '16px',
          padding: '28px',
        }}>
          <h2 style={{ fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 20px 0' }}>
            Edit Profile
          </h2>

          {loading ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '20px 0' }}>
              <div style={{ width: 22, height: 22, border: '3px solid color-mix(in srgb, var(--accent-lime) 20%, transparent)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
              <p style={{ fontFamily: 'var(--font-body)', color: 'var(--text-muted)', fontSize: '14px' }}>Loading profile…</p>
            </div>
          ) : (
            <form onSubmit={handleSubmit}>
              {message && (
                <div style={{ background: 'color-mix(in srgb, var(--accent-lime) 10%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-lime) 30%, transparent)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--accent-lime)', marginBottom: '16px' }}>
                  {message}
                </div>
              )}
              {error && (
                <div style={{ background: 'color-mix(in srgb, var(--accent-red) 10%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-red) 30%, transparent)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--accent-red)', marginBottom: '16px' }}>
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
                  <p style={{ fontFamily: 'var(--font-body)', fontSize: '11px', color: 'var(--text-faint)', marginTop: '4px' }}>Email cannot be changed</p>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '14px' }}>
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
