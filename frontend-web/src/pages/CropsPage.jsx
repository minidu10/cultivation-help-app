import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Layout from '../components/Layout'
import { getCrops, createCrop, deleteCrop } from '../api/crops'
import { useIsMobile } from '../hooks/useIsMobile'

const STATUS_STYLE = {
  PLANTED:          { bg: 'rgba(96,165,250,0.12)',  border: 'rgba(96,165,250,0.3)',  text: '#60a5fa',  label: 'Planted' },
  GROWING:          { bg: 'rgba(74,222,128,0.12)',  border: 'rgba(74,222,128,0.3)',  text: '#4ade80',  label: 'Growing' },
  READY_TO_HARVEST: { bg: 'rgba(245,158,11,0.12)',  border: 'rgba(245,158,11,0.3)',  text: '#f59e0b',  label: 'Ready to Harvest' },
  HARVESTED:        { bg: 'rgba(148,163,184,0.12)', border: 'rgba(148,163,184,0.3)', text: '#94a3b8',  label: 'Harvested' },
  FAILED:           { bg: 'rgba(248,113,113,0.12)', border: 'rgba(248,113,113,0.3)', text: '#f87171',  label: 'Failed' },
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

export default function CropsPage() {
  const navigate = useNavigate()
  const isMobile = useIsMobile()
  const [crops, setCrops] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [filterStatus, setFilterStatus] = useState('All')

  const [form, setForm] = useState({
    name: '', variety: '', fieldLocation: '',
    fieldSizeAcres: '', plantingDate: '', expectedHarvestDate: '', notes: '',
  })

  useEffect(() => { loadCrops() }, [])

  const loadCrops = async () => {
    try { const res = await getCrops(); setCrops(res.data) }
    catch { setError('Failed to load crops') }
    finally { setLoading(false) }
  }

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSubmitting(true)
    setError('')
    try {
      await createCrop({ ...form, fieldSizeAcres: form.fieldSizeAcres ? Number(form.fieldSizeAcres) : null })
      setShowForm(false)
      setForm({ name: '', variety: '', fieldLocation: '', fieldSizeAcres: '', plantingDate: '', expectedHarvestDate: '', notes: '' })
      loadCrops()
    } catch { setError('Failed to create crop') }
    finally { setSubmitting(false) }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this crop and all its data?')) return
    try { await deleteCrop(id); setCrops(crops.filter((c) => c.id !== id)) }
    catch { setError('Failed to delete crop') }
  }

  const filters = ['All', 'GROWING', 'PLANTED', 'READY_TO_HARVEST', 'HARVESTED', 'FAILED']
  const visible = filterStatus === 'All' ? crops : crops.filter(c => c.status === filterStatus)

  const cardStyle = {
    background: 'var(--bg-card)',
    border: '1px solid var(--border)',
    borderRadius: '16px', padding: '24px',
    backdropFilter: 'blur(12px)',
    transition: 'all 0.3s', cursor: 'pointer',
    position: 'relative', overflow: 'hidden',
  }

  return (
    <Layout>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', alignItems: 'center' }}>
          {filters.map(f => {
            const sc = STATUS_STYLE[f]
            const isActive = filterStatus === f
            return (
              <button key={f} onClick={() => setFilterStatus(f)} style={{
                background: isActive ? (sc ? sc.bg : 'rgba(74,222,128,0.15)') : 'var(--bg-input)',
                border: `1px solid ${isActive ? (sc ? sc.border : 'rgba(74,222,128,0.5)') : 'var(--border)'}`,
                borderRadius: '100px', padding: '6px 14px',
                fontFamily: 'Inter', fontSize: '13px',
                color: isActive ? (sc ? sc.text : '#4ade80') : 'var(--text-muted)',
                cursor: 'pointer', transition: 'all 0.2s',
              }}>
                {f === 'All' ? `All (${crops.length})` : (sc?.label || f) + ` (${crops.filter(c => c.status === f).length})`}
              </button>
            )
          })}
        </div>
        <button onClick={() => setShowForm(!showForm)} className="agro-btn" style={{ padding: '9px 20px', fontSize: '14px' }}>
          {showForm ? '× Cancel' : '+ Add Crop'}
        </button>
      </div>

      {/* Error */}
      {error && (
        <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>
          {error}
        </div>
      )}

      {/* Add crop modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-hover)', borderRadius: '20px', padding: '36px', width: '560px', maxWidth: '95vw', maxHeight: '90vh', overflowY: 'auto', backdropFilter: 'blur(20px)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '28px' }}>
              <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>Add New Crop</h2>
              <button onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '22px' }}>×</button>
            </div>
            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '14px' }}>
                {[
                  { label: 'Crop Name *', name: 'name', placeholder: 'e.g. Rice', required: true },
                  { label: 'Variety', name: 'variety', placeholder: 'e.g. Samba' },
                  { label: 'Field Location', name: 'fieldLocation', placeholder: 'e.g. North Field' },
                  { label: 'Field Size (acres)', name: 'fieldSizeAcres', type: 'number', placeholder: 'e.g. 2.5' },
                  { label: 'Planting Date *', name: 'plantingDate', type: 'date', required: true },
                  { label: 'Expected Harvest Date', name: 'expectedHarvestDate', type: 'date' },
                ].map(f => (
                  <div key={f.name}>
                    <label style={labelStyle}>{f.label}</label>
                    <input name={f.name} type={f.type || 'text'} value={form[f.name]} onChange={handleChange}
                      placeholder={f.placeholder} required={f.required} step={f.type === 'number' ? '0.1' : undefined}
                      style={inputStyle} />
                  </div>
                ))}
                <div style={{ gridColumn: '1 / -1' }}>
                  <label style={labelStyle}>Notes</label>
                  <textarea name="notes" value={form.notes} onChange={handleChange} rows={2}
                    placeholder="Any additional notes..." style={{ ...inputStyle, resize: 'vertical' }} />
                </div>
              </div>
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '20px' }}>
                <button type="button" onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'Inter', fontSize: '14px', padding: '8px 16px' }}>Cancel</button>
                <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : 'Save Crop'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Loading */}
      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '40px 0' }}>
          <div style={{ width: 28, height: 28, border: '3px solid rgba(74,222,128,0.2)', borderTopColor: '#4ade80', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ fontFamily: 'Inter', color: 'var(--text-muted)', fontSize: '14px' }}>Loading crops…</p>
        </div>
      ) : visible.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '80px 0' }}>
          <p style={{ fontSize: '48px', marginBottom: '12px' }}>🌱</p>
          <p style={{ fontFamily: 'Space Grotesk', fontWeight: 600, fontSize: '18px', color: 'var(--text-muted)', marginBottom: '6px' }}>
            {filterStatus === 'All' ? 'No crops yet' : `No ${STATUS_STYLE[filterStatus]?.label || filterStatus} crops`}
          </p>
          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>
            {filterStatus === 'All' ? 'Click "+ Add Crop" to get started' : 'Try a different filter'}
          </p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : 'repeat(3, 1fr)', gap: '16px' }}>
          {visible.map((crop) => {
            const sc = STATUS_STYLE[crop.status] || STATUS_STYLE.PLANTED
            return (
              <div key={crop.id} style={cardStyle}
                onClick={() => navigate(`/crops/${crop.id}`)}
                onMouseEnter={e => {
                  e.currentTarget.style.borderColor = 'rgba(74,222,128,0.3)'
                  e.currentTarget.style.transform = 'translateY(-3px)'
                  e.currentTarget.style.boxShadow = '0 8px 32px rgba(74,222,128,0.1)'
                }}
                onMouseLeave={e => {
                  e.currentTarget.style.borderColor = 'rgba(74,222,128,0.12)'
                  e.currentTarget.style.transform = 'translateY(0)'
                  e.currentTarget.style.boxShadow = 'none'
                }}
              >
                {/* Color accent bar */}
                <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '3px', background: `linear-gradient(90deg, ${sc.text}, transparent)`, opacity: 0.7 }} />

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '14px' }}>
                  <div>
                    <h3 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: 0 }}>{crop.name}</h3>
                    {crop.variety && <p style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>{crop.variety}</p>}
                  </div>
                  <span style={{ background: sc.bg, border: `1px solid ${sc.border}`, borderRadius: '100px', padding: '3px 10px', fontFamily: 'Inter', fontSize: '11px', fontWeight: 600, color: sc.text, flexShrink: 0, marginLeft: '8px' }}>
                    {sc.label}
                  </span>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '16px' }}>
                  {crop.fieldLocation && <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>📍 {crop.fieldLocation}</p>}
                  {crop.fieldSizeAcres && <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>📐 {crop.fieldSizeAcres} acres</p>}
                  <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>🌱 Planted: {crop.plantingDate}</p>
                  {crop.expectedHarvestDate && <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>📅 Harvest by: {crop.expectedHarvestDate}</p>}
                </div>

                <div style={{ display: 'flex', gap: '8px', paddingTop: '12px', borderTop: '1px solid rgba(74,222,128,0.08)' }}>
                  <button style={{ flex: 1, background: 'rgba(74,222,128,0.08)', border: '1px solid rgba(74,222,128,0.2)', borderRadius: '8px', padding: '6px', fontFamily: 'Inter', fontSize: '12px', color: '#4ade80', cursor: 'pointer' }}
                    onClick={e => { e.stopPropagation(); navigate(`/crops/${crop.id}`) }}>
                    View Details
                  </button>
                  <button onClick={(e) => { e.stopPropagation(); handleDelete(crop.id) }}
                    style={{ background: 'rgba(248,113,113,0.08)', border: '1px solid rgba(248,113,113,0.2)', borderRadius: '8px', padding: '6px 10px', fontFamily: 'Inter', fontSize: '12px', color: '#f87171', cursor: 'pointer' }}>
                    ×
                  </button>
                </div>
              </div>
            )
          })}
        </div>
      )}
    </Layout>
  )
}
