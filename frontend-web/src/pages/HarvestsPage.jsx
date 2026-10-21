import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { getCrops, getHarvests, addHarvest, updateHarvest, deleteHarvest } from '../api/crops'
import { useIsMobile } from '../hooks/useIsMobile'

const UNITS = ['KG', 'TONNE', 'BUSHEL', 'POUND', 'LITER']

const cardStyle = { background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '16px', backdropFilter: 'blur(12px)', padding: '24px' }
const inputStyle = { width: '100%', boxSizing: 'border-box', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 14px', fontFamily: 'Inter, sans-serif', fontSize: '14px', color: 'var(--text-primary)', outline: 'none' }
const labelStyle = { display: 'block', fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500 }
const actionBtnStyle = { background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '8px', padding: '5px 10px', fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-muted)', cursor: 'pointer' }

const EMPTY_FORM = { harvestDate: '', quantity: '', unit: 'KG', pricePerUnit: '', buyerName: '', notes: '' }

export default function HarvestsPage() {
  const isMobile = useIsMobile()
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [harvests, setHarvests] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  // Null while adding; the harvest's id while editing one.
  const [editingId, setEditingId] = useState(null)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState(EMPTY_FORM)

  useEffect(() => { loadCrops() }, [])
  useEffect(() => { if (selectedCrop) loadHarvests(selectedCrop) }, [selectedCrop])

  const loadCrops = async () => {
    try {
      const res = await getCrops(); setCrops(res.data)
      if (res.data.length > 0) setSelectedCrop(res.data[0].id)
      else setLoading(false)
    }
    catch { setError('Failed to load crops'); setLoading(false) }
  }
  const loadHarvests = async (cropId) => {
    setLoading(true)
    try { const res = await getHarvests(cropId); setHarvests(res.data) }
    catch (err) { setError(err?.response?.data?.message || 'Failed to load harvests') }
    finally { setLoading(false) }
  }
  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })
  const openAdd = () => { setEditingId(null); setForm(EMPTY_FORM); setShowForm(true) }
  const openEdit = (h) => {
    setEditingId(h.id)
    setForm({ harvestDate: h.harvestDate, quantity: String(h.quantity), unit: h.unit, pricePerUnit: String(h.pricePerUnit), buyerName: h.buyerName || '', notes: h.notes || '' })
    setShowForm(true)
  }
  const closeForm = () => { setShowForm(false); setEditingId(null); setForm(EMPTY_FORM) }
  const handleSubmit = async (e) => {
    e.preventDefault(); setSubmitting(true); setError('')
    const payload = { ...form, quantity: Number(form.quantity), pricePerUnit: Number(form.pricePerUnit) }
    try {
      if (editingId) await updateHarvest(selectedCrop, editingId, payload)
      else await addHarvest(selectedCrop, payload)
      closeForm()
      loadHarvests(selectedCrop)
    } catch (err) { setError(err?.response?.data?.message || (editingId ? 'Failed to update harvest' : 'Failed to add harvest')) }
    finally { setSubmitting(false) }
  }
  const handleDelete = async (h) => {
    if (!window.confirm(`Delete the ${h.harvestDate} harvest of ${Number(h.quantity).toLocaleString()} ${h.unit}?`)) return
    setError('')
    try {
      await deleteHarvest(selectedCrop, h.id)
      setHarvests((prev) => prev.filter((item) => item.id !== h.id))
    } catch (err) { setError(err?.response?.data?.message || 'Failed to delete harvest') }
  }

  const totalRevenue = harvests.reduce((sum, h) => sum + (Number(h.quantity) * Number(h.pricePerUnit)), 0)
  const estimatedRevenue = form.quantity && form.pricePerUnit ? Number(form.quantity) * Number(form.pricePerUnit) : 0

  return (
    <Layout>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flexWrap: 'wrap' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '8px 14px' }}>
            <span style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: 'var(--text-muted)', whiteSpace: 'nowrap' }}>Select Crop:</span>
            {crops.length === 0 ? (
              <span style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: 'var(--text-faint)' }}>No crops yet</span>
            ) : (
              <select value={selectedCrop} onChange={e => setSelectedCrop(e.target.value)} style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '14px', fontWeight: 600, outline: 'none', cursor: 'pointer' }}>
                {crops.map(crop => <option key={crop.id} value={crop.id}>{crop.name}{crop.variety ? ` (${crop.variety})` : ''}</option>)}
              </select>
            )}
          </div>
          {harvests.length > 0 && (
            <div style={{ background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.2)', borderRadius: '10px', padding: '8px 14px' }}>
              <div style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '11px', color: 'rgba(74,222,128,0.7)' }}>Total Revenue</div>
              <div style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontSize: '16px', fontWeight: 700, color: '#4ade80' }}>Rs. {totalRevenue.toLocaleString()}</div>
            </div>
          )}
        </div>
        <button onClick={() => (showForm ? closeForm() : openAdd())} disabled={!selectedCrop} className="agro-btn" style={{ padding: '9px 20px', fontSize: '14px', opacity: !selectedCrop ? 0.5 : 1 }}>
          {showForm ? '× Cancel' : '+ Add Harvest'}
        </button>
      </div>

      {/* Error */}
      {error && <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>{error}</div>}

      {/* Add harvest modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-hover)', borderRadius: '20px', padding: '36px', width: '520px', maxWidth: '95vw', maxHeight: '90vh', overflowY: 'auto', backdropFilter: 'blur(20px)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>{editingId ? 'Edit Harvest' : 'Record Harvest'}</h2>
              <button onClick={closeForm} aria-label="Close" style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '22px' }}>×</button>
            </div>
            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '14px' }}>
                <div style={{ gridColumn: '1 / -1' }}>
                  <label style={labelStyle}>Harvest Date *</label>
                  <input name="harvestDate" type="date" value={form.harvestDate} onChange={handleChange} required style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Quantity *</label>
                  <input name="quantity" type="number" step="0.001" value={form.quantity} onChange={handleChange} required placeholder="e.g. 500" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Unit *</label>
                  <select name="unit" value={form.unit} onChange={handleChange} style={inputStyle}>
                    {UNITS.map(u => <option key={u} value={u}>{u}</option>)}
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Price per Unit (Rs.) *</label>
                  <input name="pricePerUnit" type="number" step="0.01" value={form.pricePerUnit} onChange={handleChange} required placeholder="e.g. 85" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Buyer Name</label>
                  <input name="buyerName" value={form.buyerName} onChange={handleChange} placeholder="e.g. Colombo Market" style={inputStyle} />
                </div>
                <div style={{ gridColumn: '1 / -1' }}>
                  <label style={labelStyle}>Notes</label>
                  <input name="notes" value={form.notes} onChange={handleChange} placeholder="Optional notes..." style={inputStyle} />
                </div>
                {estimatedRevenue > 0 && (
                  <div style={{ gridColumn: '1 / -1', background: 'rgba(74,222,128,0.08)', border: '1px solid rgba(74,222,128,0.2)', borderRadius: '10px', padding: '12px 16px' }}>
                    <span style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: '#4ade80' }}>
                      💰 Estimated revenue: <strong>Rs. {estimatedRevenue.toLocaleString()}</strong>
                    </span>
                  </div>
                )}
              </div>
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '20px' }}>
                <button type="button" onClick={closeForm} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '14px', padding: '8px 16px' }}>Cancel</button>
                <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : editingId ? 'Save Changes' : 'Save Harvest'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Harvests list */}
      {loading ? (
        <div style={{ ...cardStyle, textAlign: 'center', padding: '60px' }}>
          <p style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: 'var(--text-faint)' }}>Loading harvests…</p>
        </div>
      ) : harvests.length === 0 ? (
        <div style={{ ...cardStyle, textAlign: 'center', padding: '80px' }}>
          <p style={{ fontSize: '48px', marginBottom: '12px' }}>📦</p>
          <p style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontWeight: 600, fontSize: '18px', color: 'var(--text-muted)', marginBottom: '6px' }}>No harvests yet</p>
          <p style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: 'var(--text-faint)' }}>Record your first harvest above</p>
        </div>
      ) : (
        <>
          {/* Summary */}
          <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : 'repeat(3,1fr)', gap: '16px', marginBottom: '20px' }}>
            {[
              { label: 'Total Revenue', value: `Rs. ${totalRevenue.toLocaleString()}`, color: '#4ade80' },
              { label: 'Total Records', value: harvests.length, color: '#60a5fa' },
              { label: 'Avg per Harvest', value: `Rs. ${Math.round(totalRevenue / harvests.length).toLocaleString()}`, color: '#f59e0b' },
            ].map(s => (
              <div key={s.label} style={{ ...cardStyle, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>{s.label}</div>
                  <div style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontSize: '24px', fontWeight: 800, color: s.color, letterSpacing: '-0.5px' }}>{s.value}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Timeline */}
          <div style={{ position: 'relative', paddingLeft: '28px' }}>
            <div style={{ position: 'absolute', left: '10px', top: 0, bottom: 0, width: '2px', background: 'linear-gradient(#4ade80, rgba(74,222,128,0.1))' }} />
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {harvests.map((h) => {
                const revenue = Number(h.quantity) * Number(h.pricePerUnit)
                return (
                  <div key={h.id} style={{ position: 'relative' }}>
                    <div style={{ position: 'absolute', left: '-22px', top: '20px', width: 12, height: 12, borderRadius: '50%', background: 'var(--accent-lime)', border: '2px solid var(--bg-primary)', boxShadow: '0 0 8px var(--accent-lime)' }} />
                    <div style={{ ...cardStyle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', transition: 'all 0.2s' }}
                      onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--border-hover)'; e.currentTarget.style.transform = 'translateY(-1px)' }}
                      onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.transform = 'none' }}
                    >
                      <div style={{ flex: 1 }}>
                        <div style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)', marginBottom: '4px' }}>
                          {Number(h.quantity).toLocaleString()} {h.unit}
                        </div>
                        <div style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-muted)' }}>
                          {h.harvestDate}
                          {h.buyerName && ` · ${h.buyerName}`}
                          {h.notes && ` · ${h.notes}`}
                        </div>
                        <div style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-faint)', marginTop: '2px' }}>
                          Rs. {Number(h.pricePerUnit).toLocaleString()} / {h.unit}
                        </div>
                      </div>
                      <div style={{ textAlign: 'right', flexShrink: 0, marginLeft: '20px' }}>
                        <div style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontSize: '20px', fontWeight: 800, color: '#4ade80', letterSpacing: '-0.5px' }}>
                          Rs. {revenue.toLocaleString()}
                        </div>
                        <div style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '11px', color: 'var(--text-faint)', marginTop: '2px' }}>Revenue</div>
                        <div style={{ marginTop: '8px', whiteSpace: 'nowrap' }}>
                          <button type="button" onClick={() => openEdit(h)} aria-label={`Edit harvest of ${h.harvestDate}`} style={{ ...actionBtnStyle, marginRight: '6px' }}>Edit</button>
                          <button type="button" onClick={() => handleDelete(h)} aria-label={`Delete harvest of ${h.harvestDate}`} style={{ ...actionBtnStyle, color: '#f87171' }}>Delete</button>
                        </div>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </>
      )}
    </Layout>
  )
}
