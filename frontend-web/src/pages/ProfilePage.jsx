import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { useAuth } from '../context/AuthContext'
import { getMyProfile, updateMyProfile } from '../api/users'

export default function ProfilePage() {
  const { updateUser } = useAuth()
  const [form, setForm] = useState({
    fullName: '',
    email: '',
    phone: '',
    city: '',
  })
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
        setForm({
          fullName: data.fullName || '',
          email: data.email || '',
          phone: data.phone || '',
          city: data.city || '',
        })
      } catch {
        setError('Failed to load profile.')
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [])

  const handleChange = (e) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setMessage('')
    setError('')

    try {
      const payload = {
        fullName: form.fullName,
        phone: form.phone,
        city: form.city,
      }
      const res = await updateMyProfile(payload)
      const updated = res.data
      updateUser({
        fullName: updated.fullName,
        email: updated.email,
        phone: updated.phone,
        city: updated.city,
        themePreference: updated.themePreference,
        desktopMode: updated.desktopMode,
      })
      setMessage('Profile updated successfully.')
    } catch {
      setError('Failed to save profile changes.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Edit Profile</h1>
        <p className="text-gray-500 mb-6">Update your farmer profile details.</p>

        <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
          {loading ? (
            <p className="text-sm text-gray-500">Loading profile...</p>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              {message && (
                <div className="bg-green-50 border border-green-200 text-green-700 text-sm px-4 py-2 rounded-lg">
                  {message}
                </div>
              )}
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-2 rounded-lg">
                  {error}
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-600 mb-1">Full Name</label>
                <input
                  name="fullName"
                  value={form.fullName}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-600 mb-1">Email</label>
                <input
                  name="email"
                  value={form.email}
                  className="w-full border border-gray-200 bg-gray-100 rounded-lg px-4 py-2.5 text-sm text-gray-500"
                  disabled
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-600 mb-1">Phone</label>
                  <input
                    name="phone"
                    value={form.phone}
                    onChange={handleChange}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-600 mb-1">City</label>
                  <input
                    name="city"
                    value={form.city}
                    onChange={handleChange}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={saving}
                className="bg-green-600 hover:bg-green-700 text-white text-sm font-semibold px-5 py-2.5 rounded-lg disabled:opacity-60"
              >
                {saving ? 'Saving...' : 'Save Profile'}
              </button>
            </form>
          )}
        </div>
      </div>
    </Layout>
  )
}
