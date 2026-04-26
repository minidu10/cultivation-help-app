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

const STATUS_OPTIONS = ['PLANTED', 'GROWING', 'READY_TO_HARVEST', 'HARVESTED', 'FAILED']
const REMINDER_TYPES = ['FERTILIZER', 'IRRIGATION', 'PEST_CONTROL', 'HARVEST', 'OTHER']

const STATUS_STYLE = {
  PLANTED:          { bg: 'rgba(96,165,250,0.12)',  border: 'rgba(96,165,250,0.3)',  text: '#60a5fa' },
  GROWING:          { bg: 'rgba(74,222,128,0.12)',  border: 'rgba(74,222,128,0.3)',  text: '#4ade80' },
  READY_TO_HARVEST: { bg: 'rgba(245,158,11,0.12)',  border: 'rgba(245,158,11,0.3)',  text: '#f59e0b' },
  HARVESTED:        { bg: 'rgba(148,163,184,0.12)', border: 'rgba(148,163,184,0.3)', text: '#94a3b8' },
  FAILED:           { bg: 'rgba(248,113,113,0.12)', border: 'rgba(248,113,113,0.3)', text: '#f87171' },
}

const REMINDER_TYPE_COLORS = {
  FERTILIZER:   '#f59e0b',
  IRRIGATION:   '#60a5fa',
  PEST_CONTROL: '#f87171',
  HARVEST:      '#4ade80',
  OTHER:        '#94a3b8',
}

const cardStyle = {
  background: 'var(--bg-card)',
  border: '1px solid var(--border)',
  borderRadius: '16px',
  backdropFilter: 'blur(12px)',
  padding: '24px',
}

const inputStyle = {
  width: '100%', boxSizing: 'border-box',
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '10px', padding: '10px 14px',
  fontFamily: 'Inter, sans-serif', fontSize: '14px',
  color: 'var(--text-primary)', outline: 'none',
}

const labelStyle = {
  display: 'block', fontFamily: 'Inter', fontSize: '12px',
  color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500,
}

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
    title: '', type: 'FERTILIZER', reminderAt: '',
    note: '', aiRecommended: false, enabled: true,
  })

  useEffect(() => { loadAll() }, [id])

  const upcoming = useMemo(() => reminders.filter(r => !r.completed), [reminders])
  const completed = useMemo(() => reminders.filter(r => r.completed), [reminders])

  const loadAll = async () => {
    setLoading(true)
    setError('')
    try {
      const [cropRes, reminderRes] = await Promise.all([getCrop(id), getCropReminders(id)])
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
      const res = await updateCrop(id, { status, aiInsightsEnabled: aiEnabled })
      setCrop(res.data)
    } catch {
      setError('Failed to save crop settings')
    } finally {
      setSavingCrop(false)
    }
  }

  const handleReminderSubmit = async (e) => {
    e.preventDefault()
    if (!form.title || !form.reminderAt) { setError('Reminder title and time are required'); return }
    setSavingReminder(true)
    setError('')
    try {
      await createCropReminder(id, { ...form })
      setForm({ title: '', type: 'FERTILIZER', reminderAt: '', note: '', aiRecommended: false, enabled: true })
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
      setReminders(prev => prev.map(r => r.id === reminder.id ? updated.data : r))
    } catch {
      setError('Failed to update reminder')
    }
  }

  const removeReminder = async (reminderId) => {
    if (!confirm('Delete this reminder?')) return
    try {
      await deleteCropReminder(id, reminderId)
      setReminders(prev => prev.filter(r => r.id !== reminderId))
    } catch {
      setError('Failed to delete reminder')
    }
  }

  if (loading) {
    return (
      <Layout>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '40px 0' }}>
          <div style={{ width: 28, height: 28, border: '3px solid rgba(74,222,128,0.2)', borderTopColor: '#4ade80', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ fontFamily: 'Inter', color: 'var(--text-muted)', fontSize: '14px' }}>Loading crop management…</p>
        </div>
      </Layout>
    )
  }

  const sc = STATUS_STYLE[status] || STATUS_STYLE.PLANTED

  return (
    <Layout>
      {/* Back + heading */}
      <div style={{ marginBottom: '24px' }}>
        <button
          onClick={() => navigate('/crops')}
          style={{ background: 'none', border: 'none', cursor: 'pointer', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', padding: '0 0 8px 0', display: 'flex', alignItems: 'center', gap: '6px' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--accent-lime)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}
        >
          Back to Crops
        </button>
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '24px', color: 'var(--text-primary)', margin: 0, letterSpacing: '-0.5px' }}>
            {crop?.name}
          </h1>
          {crop?.variety && (
            <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>{crop.variety}</span>
          )}
          <span style={{ background: sc.bg, border: `1px solid ${sc.border}`, borderRadius: '100px', padding: '3px 12px', fontFamily: 'Inter', fontSize: '12px', fontWeight: 600, color: sc.text }}>
            {status.replaceAll('_', ' ')}
          </span>
        </div>
        <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', marginTop: '4px' }}>
          Manage status, AI insights, and reminders for this crop.
        </p>
      </div>

      {/* Error */}
      {error && (
        <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>
          {error}
        </div>
      )}

      {/* Crop Settings */}
      <div style={{ ...cardStyle, marginBottom: '20px' }}>
        <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 18px 0' }}>Crop Settings</h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr auto', gap: '16px', alignItems: 'end' }}>
          <div>
            <label style={labelStyle}>Crop Status</label>
            <select value={status} onChange={e => setStatus(e.target.value)} style={inputStyle}>
              {STATUS_OPTIONS.map(opt => (
                <option key={opt} value={opt}>{opt.replaceAll('_', ' ')}</option>
              ))}
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', paddingBottom: '2px' }}>
            <div
              onClick={() => setAiEnabled(v => !v)}
              style={{
                width: 40, height: 22, borderRadius: '100px', cursor: 'pointer',
                background: aiEnabled ? 'var(--accent-lime)' : 'var(--bg-input)',
                border: `1px solid ${aiEnabled ? 'var(--accent-lime)' : 'var(--border)'}`,
                position: 'relative', transition: 'all 0.25s', flexShrink: 0,
              }}
            >
              <div style={{
                position: 'absolute', top: '2px', left: aiEnabled ? '20px' : '2px',
                width: 16, height: 16, borderRadius: '50%',
                background: aiEnabled ? '#0a1a0f' : 'var(--text-faint)',
                transition: 'left 0.25s',
              }} />
            </div>
            <label style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', cursor: 'pointer' }}
              onClick={() => setAiEnabled(v => !v)}>
              AI Recommendations
            </label>
          </div>

          <button
            onClick={saveCropSettings}
            disabled={savingCrop}
            className="agro-btn"
            style={{ padding: '10px 20px', fontSize: '14px', opacity: savingCrop ? 0.6 : 1 }}
          >
            {savingCrop ? 'Saving…' : 'Save Settings'}
          </button>
        </div>
      </div>

      {/* Add Reminder */}
      <div style={{ ...cardStyle, marginBottom: '20px' }}>
        <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 18px 0' }}>Add Reminder</h2>
        <form onSubmit={handleReminderSubmit}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
            <div>
              <label style={labelStyle}>Title *</label>
              <input
                value={form.title}
                onChange={e => setForm(p => ({ ...p, title: e.target.value }))}
                placeholder="e.g. Apply NPK fertilizer"
                style={inputStyle}
              />
            </div>
            <div>
              <label style={labelStyle}>Type</label>
              <select value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))} style={inputStyle}>
                {REMINDER_TYPES.map(t => <option key={t} value={t}>{t.replaceAll('_', ' ')}</option>)}
              </select>
            </div>
            <div>
              <label style={labelStyle}>Date &amp; Time *</label>
              <input
                type="datetime-local"
                value={form.reminderAt}
                onChange={e => setForm(p => ({ ...p, reminderAt: e.target.value }))}
                style={inputStyle}
              />
            </div>
            <div style={{ display: 'flex', gap: '20px', alignItems: 'center', paddingTop: '22px' }}>
              {[
                { key: 'aiRecommended', label: 'AI Recommended' },
                { key: 'enabled', label: 'Enabled' },
              ].map(({ key, label }) => (
                <label key={key} style={{ display: 'flex', alignItems: 'center', gap: '8px', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', cursor: 'pointer' }}>
                  <div
                    onClick={() => setForm(p => ({ ...p, [key]: !p[key] }))}
                    style={{
                      width: 36, height: 20, borderRadius: '100px', cursor: 'pointer',
                      background: form[key] ? 'var(--accent-lime)' : 'var(--bg-input)',
                      border: `1px solid ${form[key] ? 'var(--accent-lime)' : 'var(--border)'}`,
                      position: 'relative', transition: 'all 0.25s', flexShrink: 0,
                    }}
                  >
                    <div style={{
                      position: 'absolute', top: '2px', left: form[key] ? '18px' : '2px',
                      width: 14, height: 14, borderRadius: '50%',
                      background: form[key] ? '#0a1a0f' : 'var(--text-faint)',
                      transition: 'left 0.25s',
                    }} />
                  </div>
                  {label}
                </label>
              ))}
            </div>
            <div style={{ gridColumn: '1 / -1' }}>
              <label style={labelStyle}>Note</label>
              <textarea
                rows={2}
                value={form.note}
                onChange={e => setForm(p => ({ ...p, note: e.target.value }))}
                placeholder="Optional details"
                style={{ ...inputStyle, resize: 'vertical' }}
              />
            </div>
          </div>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
            <button type="submit" disabled={savingReminder} className="agro-btn" style={{ padding: '10px 22px', fontSize: '14px', opacity: savingReminder ? 0.6 : 1 }}>
              {savingReminder ? 'Adding…' : 'Add Reminder'}
            </button>
          </div>
        </form>
      </div>

      {/* Reminders */}
      <div style={cardStyle}>
        <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 16px 0' }}>
          Upcoming Reminders
          {upcoming.length > 0 && (
            <span style={{ marginLeft: '10px', background: 'rgba(74,222,128,0.12)', border: '1px solid rgba(74,222,128,0.25)', borderRadius: '100px', padding: '2px 10px', fontFamily: 'Inter', fontSize: '12px', color: '#4ade80', fontWeight: 600 }}>
              {upcoming.length}
            </span>
          )}
        </h2>

        {upcoming.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <p style={{ fontSize: '32px', marginBottom: '8px' }}>🔔</p>
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>No upcoming reminders</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {upcoming.map(reminder => {
              const typeColor = REMINDER_TYPE_COLORS[reminder.type] || '#94a3b8'
              return (
                <div key={reminder.id} style={{
                  background: 'var(--bg-input)', border: '1px solid var(--border)',
                  borderRadius: '12px', padding: '14px 16px',
                  borderLeft: `3px solid ${typeColor}`,
                  transition: 'border-color 0.2s',
                }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '12px' }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontFamily: 'Space Grotesk', fontWeight: 600, fontSize: '14px', color: 'var(--text-primary)', marginBottom: '4px' }}>
                        {reminder.title}
                      </div>
                      <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>
                        <span style={{ background: `${typeColor}20`, border: `1px solid ${typeColor}40`, borderRadius: '100px', padding: '1px 8px', marginRight: '8px', color: typeColor, fontWeight: 600 }}>
                          {reminder.type?.replaceAll('_', ' ')}
                        </span>
                        {toDateTimeInput(reminder.reminderAt).replace('T', ' ')}
                        {reminder.aiRecommended && (
                          <span style={{ marginLeft: '8px', background: 'rgba(96,165,250,0.12)', border: '1px solid rgba(96,165,250,0.3)', borderRadius: '100px', padding: '1px 8px', color: '#60a5fa', fontWeight: 600 }}>AI Suggested</span>
                        )}
                        {!reminder.enabled && (
                          <span style={{ marginLeft: '8px', background: 'rgba(148,163,184,0.12)', border: '1px solid rgba(148,163,184,0.3)', borderRadius: '100px', padding: '1px 8px', color: '#94a3b8', fontWeight: 600 }}>Disabled</span>
                        )}
                      </div>
                      {reminder.note && (
                        <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)', marginTop: '4px', fontStyle: 'italic' }}>{reminder.note}</div>
                      )}
                    </div>
                    <div style={{ display: 'flex', gap: '6px', flexShrink: 0 }}>
                      <button
                        onClick={() => toggleReminder(reminder, 'completed', true)}
                        style={{ background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.25)', borderRadius: '7px', padding: '5px 10px', fontFamily: 'Inter', fontSize: '12px', color: '#4ade80', cursor: 'pointer' }}
                      >Done</button>
                      <button
                        onClick={() => toggleReminder(reminder, 'enabled', !reminder.enabled)}
                        style={{ background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.25)', borderRadius: '7px', padding: '5px 10px', fontFamily: 'Inter', fontSize: '12px', color: '#f59e0b', cursor: 'pointer' }}
                      >{reminder.enabled ? 'Disable' : 'Enable'}</button>
                      <button
                        onClick={() => removeReminder(reminder.id)}
                        style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.25)', borderRadius: '7px', padding: '5px 10px', fontFamily: 'Inter', fontSize: '12px', color: '#f87171', cursor: 'pointer' }}
                      >Delete</button>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        )}

        {completed.length > 0 && (
          <div style={{ marginTop: '24px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <h3 style={{ fontFamily: 'Space Grotesk', fontWeight: 600, fontSize: '14px', color: 'var(--text-muted)', margin: '0 0 12px 0' }}>
              Completed ({completed.length})
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
              {completed.map(reminder => (
                <div key={reminder.id} style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', textDecoration: 'line-through', padding: '6px 0' }}>
                  {reminder.title} — {toDateTimeInput(reminder.reminderAt).replace('T', ' ')}
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </Layout>
  )
}
