import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Layout from '../components/Layout'
import { getCrops, createCrop, deleteCrop } from '../api/crops'
import { useIsMobile } from '../hooks/useIsMobile'
import logo from '../assets/logo.png'

const STATUS_STYLE = {
  PLANTED:          { bg: 'color-mix(in srgb, var(--accent-blue) 12%, transparent)',  border: 'color-mix(in srgb, var(--accent-blue) 30%, transparent)',  text: 'var(--accent-blue)',  label: 'Planted' },
  GROWING:          { bg: 'color-mix(in srgb, var(--accent-lime) 12%, transparent)',  border: 'color-mix(in srgb, var(--accent-lime) 30%, transparent)',  text: 'var(--accent-lime)',  label: 'Growing' },
  READY_TO_HARVEST: { bg: 'color-mix(in srgb, var(--accent-amber) 12%, transparent)',  border: 'color-mix(in srgb, var(--accent-amber) 30%, transparent)',  text: 'var(--accent-amber)',  label: 'Ready to Harvest' },
  HARVESTED:        { bg: 'color-mix(in srgb, var(--text-muted) 12%, transparent)', border: 'color-mix(in srgb, var(--text-muted) 30%, transparent)', text: 'var(--text-muted)',  label: 'Harvested' },
  FAILED:           { bg: 'color-mix(in srgb, var(--accent-red) 12%, transparent)', border: 'color-mix(in srgb, var(--accent-red) 30%, transparent)', text: 'var(--accent-red)',  label: 'Failed' },
}

const inputStyle = {
  width: '100%', boxSizing: 'border-box',
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  borderRadius: '10px', padding: '10px 14px',
  fontFamily: 'var(--font-body)', fontSize: '14px',
  color: 'var(--text-primary)', outline: 'none',
}

const labelStyle = {
  display: 'block', fontFamily: 'var(--font-body)', fontSize: '12px',
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
                background: isActive ? (sc ? sc.bg : 'color-mix(in srgb, var(--accent-lime) 15%, transparent)') : 'var(--bg-input)',
                border: `1px solid ${isActive ? (sc ? sc.border : 'color-mix(in srgb, var(--accent-lime) 50%, transparent)') : 'var(--border)'}`,
                borderRadius: '100px', padding: '6px 14px',
                fontFamily: 'var(--font-body)', fontSize: '13px',
                color: isActive ? (sc ? sc.text : 'var(--accent-lime)') : 'var(--text-muted)',
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
        <div style={{ background: 'color-mix(in srgb, var(--accent-red) 10%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-red) 30%, transparent)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--accent-red)', marginBottom: '16px' }}>
          {error}
        </div>
      )}

      {/* Add crop modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-hover)', borderRadius: '20px', padding: '36px', width: '560px', maxWidth: '95vw', maxHeight: '90vh', overflowY: 'auto', }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '28px' }}>
              <h2 style={{ fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>Add New Crop</h2>
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
                <button type="button" onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'var(--font-body)', fontSize: '14px', padding: '8px 16px' }}>Cancel</button>
                <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : 'Save Crop'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Loading */}
      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '40px 0' }}>
          <div style={{ width: 28, height: 28, border: '3px solid color-mix(in srgb, var(--accent-lime) 20%, transparent)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ fontFamily: 'var(--font-body)', color: 'var(--text-muted)', fontSize: '14px' }}>Loading crops…</p>
        </div>
      ) : visible.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '80px 0' }}>
          <img src={logo} alt="" width="56" height="56" style={{ display: 'block', margin: '0 auto 12px' }} />
          <p style={{ fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: '18px', color: 'var(--text-muted)', marginBottom: '6px' }}>
            {filterStatus === 'All' ? 'No crops yet' : `No ${STATUS_STYLE[filterStatus]?.label || filterStatus} crops`}
          </p>
          <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-faint)' }}>
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
                  e.currentTarget.style.borderColor = 'color-mix(in srgb, var(--accent-lime) 30%, transparent)'
                  e.currentTarget.style.transform = 'translateY(-3px)'
                  e.currentTarget.style.boxShadow = '0 6px 20px rgba(0, 0, 0, 0.07)'
                }}
                onMouseLeave={e => {
                  e.currentTarget.style.borderColor = 'color-mix(in srgb, var(--accent-lime) 12%, transparent)'
                  e.currentTarget.style.transform = 'translateY(0)'
                  e.currentTarget.style.boxShadow = 'none'
                }}
              >
                {/* Color accent bar */}
                <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '3px', background: `linear-gradient(90deg, ${sc.text}, transparent)`, opacity: 0.7 }} />

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '14px' }}>
                  <div>
                    <h3 style={{ fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: 0 }}>{crop.name}</h3>
                    {crop.variety && <p style={{ fontFamily: 'var(--font-body)', fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>{crop.variety}</p>}
                  </div>
                  <span style={{ background: sc.bg, border: `1px solid ${sc.border}`, borderRadius: '100px', padding: '3px 10px', fontFamily: 'var(--font-body)', fontSize: '11px', fontWeight: 600, color: sc.text, flexShrink: 0, marginLeft: '8px' }}>
                    {sc.label}
                  </span>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '16px' }}>
                  {crop.fieldLocation && <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-muted)' }}>{crop.fieldLocation}</p>}
                  {crop.fieldSizeAcres && <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-muted)' }}>{crop.fieldSizeAcres} acres</p>}
                  <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-muted)' }}>Planted: {crop.plantingDate}</p>
                  {crop.expectedHarvestDate && <p style={{ fontFamily: 'var(--font-body)', fontSize: '13px', color: 'var(--text-muted)' }}>Harvest by: {crop.expectedHarvestDate}</p>}
                </div>

                <div style={{ display: 'flex', gap: '8px', paddingTop: '12px', borderTop: '1px solid color-mix(in srgb, var(--accent-lime) 8%, transparent)' }}>
                  <button style={{ flex: 1, background: 'color-mix(in srgb, var(--accent-lime) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-lime) 20%, transparent)', borderRadius: '8px', padding: '6px', fontFamily: 'var(--font-body)', fontSize: '12px', color: 'var(--accent-lime)', cursor: 'pointer' }}
                    onClick={e => { e.stopPropagation(); navigate(`/crops/${crop.id}`) }}>
                    View Details
                  </button>
                  <button onClick={(e) => { e.stopPropagation(); handleDelete(crop.id) }}
                    style={{ background: 'color-mix(in srgb, var(--accent-red) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-red) 20%, transparent)', borderRadius: '8px', padding: '6px 10px', fontFamily: 'var(--font-body)', fontSize: '12px', color: 'var(--accent-red)', cursor: 'pointer' }}>
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
