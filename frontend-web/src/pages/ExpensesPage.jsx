import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { getCrops, getExpenses, addExpense } from '../api/crops'
import { useIsMobile } from '../hooks/useIsMobile'

const CATEGORIES = ['FERTILIZER', 'LABOR', 'TRANSPORT', 'EQUIPMENT', 'SEEDS', 'PESTICIDES', 'IRRIGATION', 'MISCELLANEOUS']
const CATEGORY_ICONS = { FERTILIZER: '🌿', LABOR: '👷', TRANSPORT: '🚛', EQUIPMENT: '⚙️', SEEDS: '🌱', PESTICIDES: '🧪', IRRIGATION: '💧', MISCELLANEOUS: '📦' }
const CAT_COLORS = { FERTILIZER: '#f59e0b', LABOR: '#60a5fa', TRANSPORT: '#c084fc', EQUIPMENT: '#94a3b8', SEEDS: '#4ade80', PESTICIDES: '#f87171', IRRIGATION: '#60a5fa', MISCELLANEOUS: '#94a3b8' }

const cardStyle = { background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '16px', backdropFilter: 'blur(12px)', padding: '24px' }
const inputStyle = { width: '100%', boxSizing: 'border-box', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 14px', fontFamily: 'Inter, sans-serif', fontSize: '14px', color: 'var(--text-primary)', outline: 'none' }
const labelStyle = { display: 'block', fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '6px', fontWeight: 500 }

export default function ExpensesPage() {
  const isMobile = useIsMobile()
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [expenses, setExpenses] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState({ category: 'FERTILIZER', description: '', amount: '', expenseDate: '', notes: '' })

  useEffect(() => { loadCrops() }, [])
  useEffect(() => { if (selectedCrop) loadExpenses(selectedCrop) }, [selectedCrop])

  const loadCrops = async () => {
    try { const res = await getCrops(); setCrops(res.data); if (res.data.length > 0) setSelectedCrop(res.data[0].id) }
    catch { setError('Failed to load crops') }
  }
  const loadExpenses = async (cropId) => {
    try { const res = await getExpenses(cropId); setExpenses(res.data) }
    catch { setError('Failed to load expenses') }
  }
  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })
  const handleSubmit = async (e) => {
    e.preventDefault(); setSubmitting(true); setError('')
    try {
      await addExpense(selectedCrop, { ...form, amount: Number(form.amount) })
      setShowForm(false)
      setForm({ category: 'FERTILIZER', description: '', amount: '', expenseDate: '', notes: '' })
      loadExpenses(selectedCrop)
    } catch (err) { setError(err?.response?.data?.message || 'Failed to add expense') }
    finally { setSubmitting(false) }
  }

  const totalExpenses = expenses.reduce((sum, e) => sum + Number(e.amount), 0)
  const selectedCropName = crops.find(c => c.id === Number(selectedCrop))?.name || ''

  return (
    <Layout>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px', flexWrap: 'wrap', gap: '12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flexWrap: 'wrap' }}>
          {/* Crop selector */}
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
          {expenses.length > 0 && (
            <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.2)', borderRadius: '10px', padding: '8px 14px' }}>
              <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'rgba(248,113,113,0.7)' }}>Total Spent</div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: '16px', fontWeight: 700, color: '#f87171' }}>Rs. {totalExpenses.toLocaleString()}</div>
            </div>
          )}
        </div>
        <button onClick={() => setShowForm(!showForm)} disabled={!selectedCrop} className="agro-btn" style={{ padding: '9px 20px', fontSize: '14px', opacity: !selectedCrop ? 0.5 : 1 }}>
          {showForm ? '× Cancel' : '+ Add Expense'}
        </button>
      </div>

      {/* Error */}
      {error && <div style={{ background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', borderRadius: '10px', padding: '12px 16px', fontFamily: 'Inter', fontSize: '13px', color: '#f87171', marginBottom: '16px' }}>{error}</div>}

      {/* Add expense modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border-hover)', borderRadius: '20px', padding: '36px', width: '520px', maxWidth: '95vw', maxHeight: '90vh', overflowY: 'auto', backdropFilter: 'blur(20px)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h2 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>Add Expense — {selectedCropName}</h2>
              <button onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '22px' }}>×</button>
            </div>
            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '14px' }}>
                <div>
                  <label style={labelStyle}>Category *</label>
                  <select name="category" value={form.category} onChange={handleChange} style={inputStyle}>
                    {CATEGORIES.map(cat => <option key={cat} value={cat}>{CATEGORY_ICONS[cat]} {cat}</option>)}
                  </select>
                </div>
                <div>
                  <label style={labelStyle}>Amount (Rs.) *</label>
                  <input name="amount" type="number" step="0.01" value={form.amount} onChange={handleChange} required placeholder="e.g. 3500" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Description *</label>
                  <input name="description" value={form.description} onChange={handleChange} required placeholder="e.g. Urea fertilizer 50kg" style={inputStyle} />
                </div>
                <div>
                  <label style={labelStyle}>Date *</label>
                  <input name="expenseDate" type="date" value={form.expenseDate} onChange={handleChange} required style={inputStyle} />
                </div>
                <div style={{ gridColumn: '1 / -1' }}>
                  <label style={labelStyle}>Notes</label>
                  <input name="notes" value={form.notes} onChange={handleChange} placeholder="Optional notes..." style={inputStyle} />
                </div>
              </div>
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '20px' }}>
                <button type="button" onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'Inter', fontSize: '14px', padding: '8px 16px' }}>Cancel</button>
                <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : 'Save Expense'}</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Main content */}
      {expenses.length === 0 ? (
        <div style={{ ...cardStyle, textAlign: 'center', padding: '80px' }}>
          <p style={{ fontSize: '48px', marginBottom: '12px' }}>💸</p>
          <p style={{ fontFamily: 'Space Grotesk', fontWeight: 600, fontSize: '18px', color: 'var(--text-muted)', marginBottom: '6px' }}>No expenses yet</p>
          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>Click "+ Add Expense" to record a cost</p>
        </div>
      ) : (
        <div style={cardStyle}>
          <div className="table-scroll">
          <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: '550px' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid rgba(74,222,128,0.1)' }}>
                {['Category', 'Description', 'Date', 'Notes', 'Amount'].map(h => (
                  <th key={h} style={{ padding: '12px 14px', fontFamily: 'Inter', fontSize: '12px', fontWeight: 600, color: 'var(--text-muted)', textAlign: h === 'Amount' ? 'right' : 'left', textTransform: 'uppercase', letterSpacing: '0.5px' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {expenses.map((exp, i) => {
                const color = CAT_COLORS[exp.category] || '#94a3b8'
                return (
                  <tr key={exp.id}
                    style={{ borderBottom: i < expenses.length - 1 ? '1px solid rgba(74,222,128,0.06)' : 'none', transition: 'background 0.2s' }}
                    onMouseEnter={e => e.currentTarget.style.background = 'rgba(74,222,128,0.04)'}
                    onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                  >
                    <td style={{ padding: '13px 14px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <span style={{ fontSize: '16px' }}>{CATEGORY_ICONS[exp.category]}</span>
                        <span style={{ background: `${color}20`, border: `1px solid ${color}50`, borderRadius: '100px', padding: '2px 8px', fontFamily: 'Inter', fontSize: '11px', fontWeight: 600, color }}>{exp.category}</span>
                      </div>
                    </td>
                    <td style={{ padding: '13px 14px', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-primary)' }}>{exp.description}</td>
                    <td style={{ padding: '13px 14px', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>{exp.expenseDate}</td>
                    <td style={{ padding: '13px 14px', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', fontStyle: 'italic' }}>{exp.notes || '—'}</td>
                    <td style={{ padding: '13px 14px', fontFamily: 'Space Grotesk', fontSize: '14px', fontWeight: 700, color: '#f87171', textAlign: 'right' }}>Rs. {Number(exp.amount).toLocaleString()}</td>
                  </tr>
                )
              })}
            </tbody>
            <tfoot>
              <tr style={{ borderTop: '1px solid rgba(74,222,128,0.12)', background: 'rgba(74,222,128,0.04)' }}>
                <td colSpan={4} style={{ padding: '14px', fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '14px', color: 'var(--text-primary)' }}>Total Expenses</td>
                <td style={{ padding: '14px', textAlign: 'right', fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '18px', color: '#f87171' }}>Rs. {totalExpenses.toLocaleString()}</td>
              </tr>
            </tfoot>
          </table>
          </div>
        </div>
      )}
    </Layout>
  )
}
