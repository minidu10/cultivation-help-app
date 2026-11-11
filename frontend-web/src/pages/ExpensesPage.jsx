import { useCallback, useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import { Alert } from '../components/AuthUI'
import { DotsIcon, ListIcon, PieIcon, ReceiptIcon } from '../components/Icons'
import { CATEGORY_ICONS } from '../components/iconMaps'
import {
  AddButton, CropPicker, EmptyState, Field, FormActions, Modal, RecordList, RecordRow, Tiles, Toolbar,
} from '../components/RecordUI'
import { card } from '../components/surfaces'
import { getCrops, getExpenses, addExpense, updateExpense, deleteExpense } from '../api/crops'
import { formatDate, humanize, rupees } from '../utils/format'

const CATEGORIES = ['FERTILIZER', 'LABOR', 'TRANSPORT', 'EQUIPMENT', 'SEEDS', 'PESTICIDES', 'IRRIGATION', 'MISCELLANEOUS']

const EMPTY_FORM = { category: 'FERTILIZER', description: '', amount: '', expenseDate: '', notes: '' }

function CategoryIcon({ category, size }) {
  const Icon = CATEGORY_ICONS[category] || DotsIcon
  return <Icon size={size} />
}

/** [category, amount] pairs, largest first. */
function byCategory(expenses) {
  const sums = {}
  for (const exp of expenses) sums[exp.category] = (sums[exp.category] || 0) + Number(exp.amount)
  return Object.entries(sums).sort((a, b) => b[1] - a[1])
}

/** Each category's share of the crop's spending. */
function CategoryBreakdown({ rows, total }) {
  return (
    <section style={{ ...card, padding: '18px 20px' }} aria-labelledby="breakdown-title">
      <h2 id="breakdown-title" style={{ fontSize: '17px', fontWeight: 700, color: 'var(--text-primary)', margin: '0 0 6px' }}>Where the money went</h2>
      <ul style={{ listStyle: 'none', margin: 0, padding: 0 }}>
        {rows.map(([category, amount]) => {
          const share = total > 0 ? Math.round((amount / total) * 100) : 0
          return (
            <li key={category} style={{ padding: '11px 0', borderTop: '1px solid var(--border)', fontSize: '14px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <span style={{ color: 'var(--text-muted)' }}><CategoryIcon category={category} size={18} /></span>
                <span style={{ flex: 1, color: 'var(--text-primary)' }}>{humanize(category)}</span>
                <span style={{ fontWeight: 600, color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(amount)}</span>
                <span style={{ width: '40px', textAlign: 'right', color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>{share}%</span>
              </div>
              <div aria-hidden="true" style={{ height: '5px', borderRadius: '3px', background: 'var(--bg-tile)', marginTop: '8px', overflow: 'hidden' }}>
                <div style={{ width: `${share}%`, height: '100%', background: 'var(--accent-lime)', borderRadius: '3px' }} />
              </div>
            </li>
          )
        })}
      </ul>
    </section>
  )
}

export default function ExpensesPage() {
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [expenses, setExpenses] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  // Null while adding; the expense's id while editing one.
  const [editingId, setEditingId] = useState(null)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState(EMPTY_FORM)

  useEffect(() => { loadCrops() }, [])
  useEffect(() => { if (selectedCrop) loadExpenses(selectedCrop) }, [selectedCrop])

  const loadCrops = async () => {
    try {
      const res = await getCrops(); setCrops(res.data)
      if (res.data.length > 0) setSelectedCrop(res.data[0].id)
      else setLoading(false)
    }
    catch { setError('Failed to load crops'); setLoading(false) }
  }
  const loadExpenses = async (cropId) => {
    setLoading(true)
    try { const res = await getExpenses(cropId); setExpenses(res.data) }
    catch { setError('Failed to load expenses') }
    finally { setLoading(false) }
  }
  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })
  const openAdd = () => { setEditingId(null); setForm(EMPTY_FORM); setError(''); setShowForm(true) }
  const openEdit = (exp) => {
    setEditingId(exp.id)
    setForm({ category: exp.category, description: exp.description, amount: String(exp.amount), expenseDate: exp.expenseDate, notes: exp.notes || '' })
    setError('')
    setShowForm(true)
  }
  const closeForm = useCallback(() => { setShowForm(false); setEditingId(null); setForm(EMPTY_FORM) }, [])
  const handleSubmit = async (e) => {
    e.preventDefault(); setSubmitting(true); setError('')
    const payload = { ...form, amount: Number(form.amount) }
    try {
      if (editingId) await updateExpense(selectedCrop, editingId, payload)
      else await addExpense(selectedCrop, payload)
      closeForm()
      loadExpenses(selectedCrop)
    } catch (err) { setError(err?.response?.data?.message || (editingId ? 'Failed to update expense' : 'Failed to add expense')) }
    finally { setSubmitting(false) }
  }
  const handleDelete = async (exp) => {
    if (!window.confirm(`Delete "${exp.description}" (${rupees(exp.amount)})?`)) return
    setError('')
    try {
      await deleteExpense(selectedCrop, exp.id)
      setExpenses((prev) => prev.filter((item) => item.id !== exp.id))
    } catch (err) { setError(err?.response?.data?.message || 'Failed to delete expense') }
  }

  const totalExpenses = expenses.reduce((sum, e) => sum + Number(e.amount), 0)
  const newestFirst = [...expenses].sort((a, b) => (b.expenseDate || '').localeCompare(a.expenseDate || ''))
  const oldest = newestFirst[newestFirst.length - 1]
  const categories = byCategory(expenses)
  const [topCategory, topAmount] = categories[0] || ['', 0]
  const count = `${expenses.length} ${expenses.length === 1 ? 'expense' : 'expenses'}`

  return (
    <Layout>
      {!showForm && <Alert>{error}</Alert>}

      {!loading && crops.length === 0 ? (
        <EmptyState
          title="Add a crop first"
          text="Expenses are recorded against a crop. Add your first crop, then come back here to record what you spend on it."
          action={<Link to="/crops" className="agro-btn" style={{ display: 'inline-block', textDecoration: 'none' }}>Go to My Crops</Link>}
        />
      ) : (
        <>
          <Toolbar>
            <CropPicker crops={crops} value={selectedCrop} onChange={setSelectedCrop} />
            <AddButton onClick={openAdd} disabled={!selectedCrop}>Add expense</AddButton>
          </Toolbar>

          {loading ? (
            <div style={{ ...card, padding: '48px', textAlign: 'center', fontSize: '14px', color: 'var(--text-muted)' }}>Loading expenses…</div>
          ) : expenses.length === 0 ? (
            <EmptyState
              title="No expenses recorded yet"
              text="Record seed, fertilizer, labour and other costs as you pay them, so the profit for this crop is right at harvest."
              action={<AddButton onClick={openAdd}>Add expense</AddButton>}
            />
          ) : (
            <>
              <Tiles>
                <StatCard title="Total spent" value={rupees(totalExpenses)} tone="bad" icon={<ReceiptIcon />} sub={count} />
                <StatCard title="Biggest cost" value={humanize(topCategory)} icon={<PieIcon />} sub={`${Math.round((topAmount / totalExpenses) * 100)}% of the spending`} />
                <StatCard title="Spending since" value={formatDate(oldest.expenseDate)} icon={<ListIcon />} sub={`Latest on ${formatDate(newestFirst[0].expenseDate)}`} />
              </Tiles>

              <div className="split">
                <RecordList title="Expenses" aside="Newest first">
                  {newestFirst.map((exp) => (
                    <RecordRow
                      key={exp.id}
                      icon={<CategoryIcon category={exp.category} />}
                      tone="bad"
                      title={exp.description}
                      details={`${humanize(exp.category)} · ${formatDate(exp.expenseDate)}`}
                      note={exp.notes}
                      amount={rupees(exp.amount)}
                      amountTone="bad"
                      editLabel={`Edit ${exp.description}`}
                      deleteLabel={`Delete ${exp.description}`}
                      onEdit={() => openEdit(exp)}
                      onDelete={() => handleDelete(exp)}
                    />
                  ))}
                </RecordList>
                <CategoryBreakdown rows={categories} total={totalExpenses} />
              </div>
            </>
          )}
        </>
      )}

      {showForm && (
        <Modal title={editingId ? 'Edit expense' : 'Add expense'} onClose={closeForm}>
          <Alert>{error}</Alert>
          <form onSubmit={handleSubmit}>
            <div className="form-grid">
              <Field label="Category">
                <select name="category" value={form.category} onChange={handleChange} className="agro-input">
                  {CATEGORIES.map((cat) => <option key={cat} value={cat}>{humanize(cat)}</option>)}
                </select>
              </Field>
              <Field label="Amount (Rs.)">
                <input name="amount" type="number" step="0.01" min="0" value={form.amount} onChange={handleChange} required placeholder="e.g. 3500" className="agro-input" />
              </Field>
              <Field label="Description">
                <input name="description" value={form.description} onChange={handleChange} required placeholder="e.g. Urea fertilizer 50kg" className="agro-input" />
              </Field>
              <Field label="Date">
                <input name="expenseDate" type="date" value={form.expenseDate} onChange={handleChange} required className="agro-input" />
              </Field>
              <Field label="Notes" wide>
                <input name="notes" value={form.notes} onChange={handleChange} placeholder="Optional" className="agro-input" />
              </Field>
            </div>
            <FormActions submitting={submitting} submitLabel={editingId ? 'Save changes' : 'Save expense'} onCancel={closeForm} />
          </form>
        </Modal>
      )}
    </Layout>
  )
}
