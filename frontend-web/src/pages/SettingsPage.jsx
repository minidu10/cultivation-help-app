import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { useAuth } from '../context/AuthContext'
import { getMyProfile, updateMyProfile } from '../api/users'

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
      setError('')
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
        if (!user) {
          setError('Failed to load settings.')
        }
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [])

  const saveSettings = async () => {
    setSaving(true)
    setMessage('')
    setError('')

    try {
      const res = await updateMyProfile({
        fullName,
        phone,
        city,
        themePreference,
        desktopMode,
      })
      const updated = res.data
      updateUser({
        fullName: updated.fullName,
        email: updated.email,
        phone: updated.phone,
        city: updated.city,
        themePreference: updated.themePreference,
        desktopMode: updated.desktopMode,
      })
      setMessage('Settings saved successfully.')
    } catch {
      setError('Failed to save settings.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Settings</h1>
        <p className="text-gray-500 mb-6">Control your appearance and layout preferences.</p>

        <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm space-y-6">
          {loading ? (
            <p className="text-sm text-gray-500">Loading settings...</p>
          ) : (
            <>
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

              <section>
                <h2 className="text-base font-semibold text-gray-700 mb-3">Profile</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-600 mb-1">Full Name</label>
                    <input
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-1">Email</label>
                    <input
                      value={email}
                      disabled
                      className="w-full border border-gray-200 bg-gray-100 rounded-lg px-4 py-2.5 text-sm text-gray-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-1">Phone</label>
                    <input
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-1">City</label>
                    <input
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      className="w-full border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-green-400"
                    />
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-base font-semibold text-gray-700 mb-3">Theme</h2>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => setThemePreference('LIGHT')}
                    className={`border rounded-lg px-4 py-2.5 text-sm font-medium ${themePreference === 'LIGHT' ? 'border-green-600 bg-green-50 text-green-700' : 'border-gray-300 text-gray-600'}`}
                  >
                    Light Mode
                  </button>
                  <button
                    type="button"
                    onClick={() => setThemePreference('DARK')}
                    className={`border rounded-lg px-4 py-2.5 text-sm font-medium ${themePreference === 'DARK' ? 'border-green-600 bg-green-50 text-green-700' : 'border-gray-300 text-gray-600'}`}
                  >
                    Dark Mode
                  </button>
                </div>
              </section>

              <section>
                <h2 className="text-base font-semibold text-gray-700 mb-2">Layout</h2>
                <label className="flex items-start gap-3 text-sm text-gray-600">
                  <input
                    type="checkbox"
                    checked={desktopMode}
                    onChange={(e) => setDesktopMode(e.target.checked)}
                    className="mt-1"
                  />
                  <span>
                    Enable Desktop Mode (Follow Laptop/System Theme)
                    <span className="block text-xs text-gray-500 mt-1">
                      When enabled, website theme follows your laptop setting automatically:
                      dark laptop mode = dark website, light laptop mode = light website.
                    </span>
                  </span>
                </label>
              </section>

              <button
                type="button"
                onClick={saveSettings}
                disabled={saving}
                className="bg-green-600 hover:bg-green-700 text-white text-sm font-semibold px-5 py-2.5 rounded-lg disabled:opacity-60"
              >
                {saving ? 'Saving...' : 'Save Settings'}
              </button>
            </>
          )}
        </div>
      </div>
    </Layout>
  )
}
