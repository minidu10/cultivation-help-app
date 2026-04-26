import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { getCrops, getHarvests, addHarvest } from '../api/crops'

const UNITS = ['KG', 'TONNE', 'BUSHEL', 'POUND', 'LITER']

const cardStyle = { background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '16px', backdropFilter: 'blur(12px)', padding: '24px' }
const inputStyle = { width: '100%', boxSizing: 'border-box', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 14px', fontFamily: 'Inter, sans-serif', fontSize: '14px', color: 'var(--text-primary)', outline: 'none' }
const labelStyle = { display: 'block', fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500 }

export default function HarvestsPage() {
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [harvests, setHarvests] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState({ harvestDate: '', quantity: '', unit: 'KG', pricePerUnit: '', buyerName: '', notes: '' })

  useEffect(() => { loadCrops() }, [])
  useEffect(() => { if (selectedCrop) loadHarvests(selectedCrop) }, [selectedCrop])

  const loadCrops = async () => {
    try { const res = await getCrops(); setCrops(res.data); if (res.data.length > 0) setSelectedCrop(res.data[0].id) }
    catch { setError('Failed to load crops') }
  }
  const loadHarvests = async (cropId) => {
    try { const res = await getHarvests(cropId); setHarvests(res.data) }
    catch (err) { setError(err?.response?.data?.message || 'Failed to load harvests') }
  }
  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })
  const handleSubmit = async (e) => {
    e.preventDefault(); setSubmitting(true); setError('')
    try {
      await addHarvest(selectedCrop, { ...form, quantity: Number(form.quantity), pricePerUnit: Number(form.pricePerUnit) })
      setShowForm(false)
      setForm({ harvestDate: '', quantity: '', unit: 'KG', pricePerUnit: '', buyerName: '', notes: '' })
      loadHarvests(selectedCrop)
    } catch (err) { setError(err?.response?.data?.message || 'Failed to add harvest') }
    finally { setSubmitting(false) }
  }

  const totalRevenue = harvests.reduce((sum, h) => sum + (Number(h.quantity) * Number(h.pricePerUnit)), 0)
  const estimatedRevenue = form.quantity && form.pricePerUnit ? Number(form.quantity) * Number(form.pricePerUnit) : 0

  return (
    <Layout>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '8px 14px' }}>
            <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', whiteSpace: 'nowrap' }}>Select Crop:</span>
            {crops.length === 0 ? (
              <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>No crops yet</span>
            ) : (
              <select value={selectedCrop} onChange={e => setSelectedCrop(e.target.value)} style={{ background: 'transparent', border: 'none', color: 'var(--text-primary)', fontFamily: 'Inter', fontSize: '14px', fontWeight: 600, outline: 'none', cursor: 'pointer' }}>
                {crops.map(crop => <option key={crop.id} value={crop.id}>{crop.name}{crop.variety ? ` (${crop.variety})` : ''}</option>)}
              </select>
            )}
          </div>
          {harvests.length > 0 && (
            <div style={{ background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.2)', borderRadius: '10px', padding: '8px 14px' }}>
              <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'rgba(74,222,128,0.7)' }}>Total Revenue</div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: '16px', fontWeight: 700, color: '#4ade80' }}>Rs. {totalRevenue.toLocaleString()}</div>
            </div>
          )}
        </div>
        <button onClick={() => setShowForm(!showForm)} disabled={!selectedCrop} className="agro-btn" style={{ padding: '9px 20px', fontSize: '14px', opacity: !selectedCrop ? 0.5 : 1 }}>
          {showForm ? '× Cancel' : '+ Add Harvest'}
        </button>
      </div>

      {/* Error */}
      {error && <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>{error}</div>}

      {/* Add harvest modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-hover)', borderRadius: '20px', padding: '36px', width: '520px', maxWidth: '95vw', maxHeight: '90vh', overflowY: 'auto', backdropFilter: 'blur(20px)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>Record Harvest</h2>
              <button onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '22px' }}>×</button>
            </div>
            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
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
                    <span style={{ fontFamily: 'Inter', fontSize: '13px', color: '#4ade80' }}>
                      💰 Estimated revenue: <strong>Rs. {estimatedRevenue.toLocaleString()}</strong>
                    </span>
                  </div>
                )}
              </div>
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '20px' }}>
                <button type="button" onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'Inter', fontSize: '14px', padding: '8px 16px' }}>Cancel</button>
                <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : 'Save Harvest'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Harvests list */}
      {harvests.length === 0 ? (
        <div style={{ ...cardStyle, textAlign: 'center', padding: '80px' }}>
          <p style={{ fontSize: '48px', marginBottom: '12px' }}>📦</p>
          <p style={{ fontFamily: 'Space Grotesk', fontWeight: 600, fontSize: '18px', color: 'var(--text-muted)', marginBottom: '6px' }}>No harvests yet</p>
          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>Record your first harvest above</p>
        </div>
      ) : (
        <>
          {/* Summary */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: '16px', marginBottom: '20px' }}>
            {[
              { label: 'Total Revenue', value: `Rs. ${totalRevenue.toLocaleString()}`, color: '#4ade80' },
              { label: 'Total Records', value: harvests.length, color: '#60a5fa' },
              { label: 'Avg per Harvest', value: `Rs. ${Math.round(totalRevenue / harvests.length).toLocaleString()}`, color: '#f59e0b' },
            ].map(s => (
              <div key={s.label} style={{ ...cardStyle, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>{s.label}</div>
                  <div style={{ fontFamily: 'Space Grotesk', fontSize: '24px', fontWeight: 800, color: s.color, letterSpacing: '-0.5px' }}>{s.value}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Timeline */}
          <div style={{ position: 'relative', paddingLeft: '28px' }}>
            <div style={{ position: 'absolute', left: '10px', top: 0, bottom: 0, width: '2px', background: 'linear-gradient(#4ade80, rgba(74,222,128,0.1))' }} />
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {harvests.map((h, i) => {
                const revenue = Number(h.quantity) * Number(h.pricePerUnit)
                return (
                  <div key={h.id} style={{ position: 'relative' }}>
                    <div style={{ position: 'absolute', left: '-22px', top: '20px', width: 12, height: 12, borderRadius: '50%', background: 'var(--accent-lime)', border: '2px solid var(--bg-primary)', boxShadow: '0 0 8px var(--accent-lime)' }} />
                    <div style={{ ...cardStyle, display: 'flex', alignItems: 'center', justifyContent: 'space-between', transition: 'all 0.2s' }}
                      onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--border-hover)'; e.currentTarget.style.transform = 'translateY(-1px)' }}
                      onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.transform = 'none' }}
                    >
                      <div style={{ flex: 1 }}>
                        <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)', marginBottom: '4px' }}>
                          {Number(h.quantity).toLocaleString()} {h.unit}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>
                          {h.harvestDate}
                          {h.buyerName && ` · ${h.buyerName}`}
                          {h.notes && ` · ${h.notes}`}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)', marginTop: '2px' }}>
                          Rs. {Number(h.pricePerUnit).toLocaleString()} / {h.unit}
                        </div>
                      </div>
                      <div style={{ textAlign: 'right', flexShrink: 0, marginLeft: '20px' }}>
                        <div style={{ fontFamily: 'Space Grotesk', fontSize: '20px', fontWeight: 800, color: '#4ade80', letterSpacing: '-0.5px' }}>
                          Rs. {revenue.toLocaleString()}
                        </div>
                        <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)', marginTop: '2px' }}>Revenue</div>
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
