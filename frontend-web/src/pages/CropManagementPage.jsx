import { useEffect, useMemo, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import Layout from '../components/Layout'
import {
  createCropReminder,
  deleteCropReminder,
  getCrop,
  getCropReminders,
  updateCrop,
  updateCropReminder,
} from '../api/crops'

const STATUS_OPTIONS = [
  'PLANTED',
  'GROWING',
  'READY_TO_HARVEST',
  'HARVESTED',
  'FAILED',
]

const REMINDER_TYPES = [
  'FERTILIZER',
  'IRRIGATION',
  'PEST_CONTROL',
  'HARVEST',
  'OTHER',
]

function toDateTimeInput(value) {
  if (!value) return ''
  return value.slice(0, 16)
}

export default function CropManagementPage() {
  const { id } = useParams()
  const navigate = useNavigate()

  const [loading, setLoading] = useState(true)
  const [crop, setCrop] = useState(null)
  const [reminders, setReminders] = useState([])
  const [error, setError] = useState('')
  const [savingCrop, setSavingCrop] = useState(false)
  const [savingReminder, setSavingReminder] = useState(false)

  const [status, setStatus] = useState('PLANTED')
  const [aiEnabled, setAiEnabled] = useState(true)

  const [form, setForm] = useState({
    title: '',
    type: 'FERTILIZER',
    reminderAt: '',
    note: '',
    aiRecommended: false,
    enabled: true,
  })

  useEffect(() => {
    loadAll()
  }, [id])

  const upcoming = useMemo(
    () => reminders.filter((r) => !r.completed),
    [reminders]
  )

  const completed = useMemo(
    () => reminders.filter((r) => r.completed),
    [reminders]
  )

  const loadAll = async () => {
    setLoading(true)
    setError('')
    try {
      const [cropRes, reminderRes] = await Promise.all([
        getCrop(id),
        getCropReminders(id),
      ])
      setCrop(cropRes.data)
      setStatus(cropRes.data.status || 'PLANTED')
      setAiEnabled(cropRes.data.aiInsightsEnabled !== false)
      setReminders(reminderRes.data)
    } catch {
      setError('Failed to load crop management data')
    } finally {
      setLoading(false)
    }
  }

  const saveCropSettings = async () => {
    setSavingCrop(true)
    setError('')
    try {
      const res = await updateCrop(id, {
        status,
        aiInsightsEnabled: aiEnabled,
      })
      setCrop(res.data)
    } catch {
      setError('Failed to save crop settings')
    } finally {
      setSavingCrop(false)
    }
  }

  const handleReminderSubmit = async (e) => {
    e.preventDefault()
    if (!form.title || !form.reminderAt) {
      setError('Reminder title and time are required')
      return
    }

    setSavingReminder(true)
    setError('')
    try {
      await createCropReminder(id, {
        ...form,
        reminderAt: form.reminderAt,
      })
      setForm({
        title: '',
        type: 'FERTILIZER',
        reminderAt: '',
        note: '',
        aiRecommended: false,
        enabled: true,
      })
      const reminderRes = await getCropReminders(id)
      setReminders(reminderRes.data)
    } catch {
      setError('Failed to add reminder')
    } finally {
      setSavingReminder(false)
    }
  }

  const toggleReminder = async (reminder, key, value) => {
    try {
      const updated = await updateCropReminder(id, reminder.id, { [key]: value })
      setReminders((prev) =>
        prev.map((r) => (r.id === reminder.id ? updated.data : r))
      )
    } catch {
      setError('Failed to update reminder')
    }
  }

  const removeReminder = async (reminderId) => {
    if (!confirm('Delete this reminder?')) return
    try {
      await deleteCropReminder(id, reminderId)
      setReminders((prev) => prev.filter((r) => r.id !== reminderId))
    } catch {
      setError('Failed to delete reminder')
    }
  }

  if (loading) {
    return (
      <Layout>
        <p className="text-gray-400 animate-pulse">Loading crop management...</p>
      </Layout>
    )
  }

  return (
    <Layout>
      <div className="flex items-center justify-between mb-6">
        <div>
          <button
            onClick={() => navigate('/crops')}
            className="text-sm text-green-700 hover:text-green-800 mb-2"
          >
            ← Back to crops
          </button>
          <h1 className="text-2xl font-bold text-gray-800">
            Crop Management: {crop?.name}
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage crop status, AI insights mode, and reminders.
          </p>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 text-red-600 text-sm px-4 py-3 rounded-lg mb-4 border border-red-200">
          {error}
        </div>
      )}

      <div className="bg-white rounded-xl border border-gray-200 p-5 mb-6">
        <h2 className="text-base font-semibold text-gray-700 mb-4">Crop Settings</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Crop Status</label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
            >
              {STATUS_OPTIONS.map((option) => (
                <option key={option} value={option}>
                  {option.replaceAll('_', ' ')}
                </option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 pb-2">
            <input
              id="aiEnabled"
              type="checkbox"
              checked={aiEnabled}
              onChange={(e) => setAiEnabled(e.target.checked)}
              className="w-4 h-4"
            />
            <label htmlFor="aiEnabled" className="text-sm text-gray-700">
              Enable AI recommendations for this crop
            </label>
          </div>

          <button
            onClick={saveCropSettings}
            disabled={savingCrop}
            className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium disabled:opacity-50"
          >
            {savingCrop ? 'Saving...' : 'Save Settings'}
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5 mb-6">
        <h2 className="text-base font-semibold text-gray-700 mb-4">Add Reminder</h2>

        <form onSubmit={handleReminderSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Title *</label>
            <input
              value={form.title}
              onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))}
              placeholder="e.g. Apply NPK fertilizer"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Type</label>
            <select
              value={form.type}
              onChange={(e) => setForm((prev) => ({ ...prev, type: e.target.value }))}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
            >
              {REMINDER_TYPES.map((type) => (
                <option key={type} value={type}>{type.replaceAll('_', ' ')}</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-600 mb-1">Date & Time *</label>
            <input
              type="datetime-local"
              value={form.reminderAt}
              onChange={(e) => setForm((prev) => ({ ...prev, reminderAt: e.target.value }))}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <div className="flex items-center gap-5 pt-6">
            <label className="inline-flex items-center gap-2 text-sm text-gray-700">
              <input
                type="checkbox"
                checked={form.aiRecommended}
                onChange={(e) => setForm((prev) => ({ ...prev, aiRecommended: e.target.checked }))}
              />
              AI recommended
            </label>
            <label className="inline-flex items-center gap-2 text-sm text-gray-700">
              <input
                type="checkbox"
                checked={form.enabled}
                onChange={(e) => setForm((prev) => ({ ...prev, enabled: e.target.checked }))}
              />
              Enabled
            </label>
          </div>

          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-600 mb-1">Note</label>
            <textarea
              rows={2}
              value={form.note}
              onChange={(e) => setForm((prev) => ({ ...prev, note: e.target.value }))}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm"
              placeholder="Optional details"
            />
          </div>

          <div className="md:col-span-2 flex justify-end">
            <button
              type="submit"
              disabled={savingReminder}
              className="bg-green-600 hover:bg-green-700 text-white px-5 py-2 rounded-lg text-sm font-medium disabled:opacity-50"
            >
              {savingReminder ? 'Adding...' : 'Add Reminder'}
            </button>
          </div>
        </form>
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <h2 className="text-base font-semibold text-gray-700 mb-3">Upcoming Reminders</h2>
        {upcoming.length === 0 ? (
          <p className="text-sm text-gray-400">No upcoming reminders.</p>
        ) : (
          <div className="space-y-3">
            {upcoming.map((reminder) => (
              <div key={reminder.id} className="border border-gray-100 rounded-lg p-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold text-gray-800">{reminder.title}</p>
                    <p className="text-xs text-gray-500">
                      {reminder.type?.replaceAll('_', ' ')} • {toDateTimeInput(reminder.reminderAt).replace('T', ' ')}
                    </p>
                    {reminder.note && (
                      <p className="text-sm text-gray-600 mt-1">{reminder.note}</p>
                    )}
                    <div className="flex gap-3 mt-2 text-xs">
                      {reminder.aiRecommended && (
                        <span className="px-2 py-1 rounded-full bg-blue-100 text-blue-700">AI Suggested</span>
                      )}
                      {!reminder.enabled && (
                        <span className="px-2 py-1 rounded-full bg-gray-100 text-gray-600">Disabled</span>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => toggleReminder(reminder, 'completed', true)}
                      className="text-xs px-2 py-1 rounded bg-green-100 text-green-700 hover:bg-green-200"
                    >
                      Done
                    </button>
                    <button
                      onClick={() => toggleReminder(reminder, 'enabled', !reminder.enabled)}
                      className="text-xs px-2 py-1 rounded bg-amber-100 text-amber-700 hover:bg-amber-200"
                    >
                      {reminder.enabled ? 'Disable' : 'Enable'}
                    </button>
                    <button
                      onClick={() => removeReminder(reminder.id)}
                      className="text-xs px-2 py-1 rounded bg-red-100 text-red-700 hover:bg-red-200"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {completed.length > 0 && (
          <div className="mt-6 pt-4 border-t border-gray-100">
            <h3 className="text-sm font-semibold text-gray-700 mb-2">Completed</h3>
            <div className="space-y-2">
              {completed.map((reminder) => (
                <div key={reminder.id} className="text-sm text-gray-500 line-through">
                  {reminder.title} ({toDateTimeInput(reminder.reminderAt).replace('T', ' ')})
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </Layout>
  )
}
