import { useCallback, useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import { Alert } from '../components/AuthUI'
import { BoxIcon, PaymentsIcon, TagIcon } from '../components/Icons'
import {
  AddButton, CropPicker, EmptyState, Field, FormActions, Modal, RecordList, RecordRow, Tiles, Toolbar,
} from '../components/RecordUI'
import { card } from '../components/surfaces'
import { getCrops, getHarvests, addHarvest, updateHarvest, deleteHarvest } from '../api/crops'
import { formatDate, rupees, unitLabel } from '../utils/format'

const UNITS = ['KG', 'TONNE', 'BUSHEL', 'POUND', 'LITER']

const EMPTY_FORM = { harvestDate: '', quantity: '', unit: 'KG', pricePerUnit: '', buyerName: '', notes: '' }

const revenueOf = (h) => Number(h.quantity) * Number(h.pricePerUnit)

export default function HarvestsPage() {
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
  const openAdd = () => { setEditingId(null); setForm(EMPTY_FORM); setError(''); setShowForm(true) }
  const openEdit = (h) => {
    setEditingId(h.id)
    setForm({ harvestDate: h.harvestDate, quantity: String(h.quantity), unit: h.unit, pricePerUnit: String(h.pricePerUnit), buyerName: h.buyerName || '', notes: h.notes || '' })
    setError('')
    setShowForm(true)
  }
  const closeForm = useCallback(() => { setShowForm(false); setEditingId(null); setForm(EMPTY_FORM) }, [])
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
    if (!window.confirm(`Delete the ${formatDate(h.harvestDate)} harvest of ${Number(h.quantity).toLocaleString()} ${unitLabel(h.unit)}?`)) return
    setError('')
    try {
      await deleteHarvest(selectedCrop, h.id)
      setHarvests((prev) => prev.filter((item) => item.id !== h.id))
    } catch (err) { setError(err?.response?.data?.message || 'Failed to delete harvest') }
  }

  const totalRevenue = harvests.reduce((sum, h) => sum + revenueOf(h), 0)
  // Quantities only add up when every harvest uses the same unit.
  const unit = harvests.length > 0 && harvests.every((h) => h.unit === harvests[0].unit) ? harvests[0].unit : null
  const totalQuantity = unit ? harvests.reduce((sum, h) => sum + Number(h.quantity), 0) : 0
  const averagePrice = unit && totalQuantity > 0 ? Math.round((totalRevenue / totalQuantity) * 100) / 100 : null
  const newestFirst = [...harvests].sort((a, b) => (b.harvestDate || '').localeCompare(a.harvestDate || ''))
  const estimatedRevenue = form.quantity && form.pricePerUnit ? Number(form.quantity) * Number(form.pricePerUnit) : 0
  const count = `${harvests.length} ${harvests.length === 1 ? 'harvest' : 'harvests'}`

  return (
    <Layout>
      {!showForm && <Alert>{error}</Alert>}

      {!loading && crops.length === 0 ? (
        <EmptyState
          title="Add a crop first"
          text="Harvests are recorded against a crop. Add your first crop, then come back here to record what you sold."
          action={<Link to="/crops" className="agro-btn" style={{ display: 'inline-block', textDecoration: 'none' }}>Go to My Crops</Link>}
        />
      ) : (
        <>
          <Toolbar>
            <CropPicker crops={crops} value={selectedCrop} onChange={setSelectedCrop} />
            <AddButton onClick={openAdd} disabled={!selectedCrop}>Add harvest</AddButton>
          </Toolbar>

          {loading ? (
            <div style={{ ...card, padding: '48px', textAlign: 'center', fontSize: '14px', color: 'var(--text-muted)' }}>Loading harvests…</div>
          ) : harvests.length === 0 ? (
            <EmptyState
              title="No harvests recorded yet"
              text="Record each sale as it happens. AgroMaster adds up the revenue and works out the profit for this crop."
              action={<AddButton onClick={openAdd}>Add harvest</AddButton>}
            />
          ) : (
            <>
              <Tiles>
                <StatCard title="Harvest revenue" value={rupees(totalRevenue)} tone="good" icon={<PaymentsIcon />} sub={`From ${count}`} />
                <StatCard
                  title="Harvested"
                  value={unit ? `${totalQuantity.toLocaleString()} ${unitLabel(unit)}` : count}
                  tone="brand"
                  icon={<BoxIcon />}
                  sub={unit ? count : 'In more than one unit'}
                />
                <StatCard
                  title="Average price"
                  value={averagePrice !== null ? rupees(averagePrice) : rupees(Math.round(totalRevenue / harvests.length))}
                  icon={<TagIcon />}
                  sub={averagePrice !== null ? `per ${unitLabel(unit)}` : 'per harvest'}
                />
              </Tiles>

              <RecordList title="Harvests" aside="Newest first">
                {newestFirst.map((h) => (
                  <RecordRow
                    key={h.id}
                    icon={<BoxIcon />}
                    title={`${Number(h.quantity).toLocaleString()} ${unitLabel(h.unit)}`}
                    details={[formatDate(h.harvestDate), `${rupees(h.pricePerUnit)} per ${unitLabel(h.unit)}`, h.buyerName].filter(Boolean).join(' · ')}
                    note={h.notes}
                    amount={rupees(revenueOf(h))}
                    amountTone="good"
                    editLabel={`Edit harvest of ${formatDate(h.harvestDate)}`}
                    deleteLabel={`Delete harvest of ${formatDate(h.harvestDate)}`}
                    onEdit={() => openEdit(h)}
                    onDelete={() => handleDelete(h)}
                  />
                ))}
              </RecordList>
            </>
          )}
        </>
      )}

      {showForm && (
        <Modal title={editingId ? 'Edit harvest' : 'Add harvest'} onClose={closeForm}>
          <Alert>{error}</Alert>
          <form onSubmit={handleSubmit}>
            <div className="form-grid">
              <Field label="Harvest date" wide>
                <input name="harvestDate" type="date" value={form.harvestDate} onChange={handleChange} required className="agro-input" />
              </Field>
              <Field label="Quantity">
                <input name="quantity" type="number" step="0.001" min="0" value={form.quantity} onChange={handleChange} required placeholder="e.g. 500" className="agro-input" />
              </Field>
              <Field label="Unit">
                <select name="unit" value={form.unit} onChange={handleChange} className="agro-input">
                  {UNITS.map((u) => <option key={u} value={u}>{unitLabel(u)}</option>)}
                </select>
              </Field>
              <Field label="Price per unit (Rs.)">
                <input name="pricePerUnit" type="number" step="0.01" min="0" value={form.pricePerUnit} onChange={handleChange} required placeholder="e.g. 85" className="agro-input" />
              </Field>
              <Field label="Buyer">
                <input name="buyerName" value={form.buyerName} onChange={handleChange} placeholder="e.g. Polonnaruwa rice mill" className="agro-input" />
              </Field>
              <Field label="Notes" wide>
                <input name="notes" value={form.notes} onChange={handleChange} placeholder="Optional" className="agro-input" />
              </Field>
              {estimatedRevenue > 0 && (
                <p className="span-2" style={{ margin: 0, fontSize: '14px', fontWeight: 600, color: 'var(--profit)' }}>
                  Estimated revenue: {rupees(estimatedRevenue)}
                </p>
              )}
            </div>
            <FormActions submitting={submitting} submitLabel={editingId ? 'Save changes' : 'Save harvest'} onCancel={closeForm} />
          </form>
        </Modal>
      )}
    </Layout>
  )
}
