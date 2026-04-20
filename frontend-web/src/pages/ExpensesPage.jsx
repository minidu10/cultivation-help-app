import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { getCrops, getExpenses, addExpense } from '../api/crops'

const CATEGORIES = [
  'FERTILIZER', 'LABOR', 'TRANSPORT', 'EQUIPMENT',
  'SEEDS', 'PESTICIDES', 'IRRIGATION', 'MISCELLANEOUS'
]

const CATEGORY_ICONS = {
  FERTILIZER: '🌿',
  LABOR: '👷',
  TRANSPORT: '🚛',
  EQUIPMENT: '⚙️',
  SEEDS: '🌱',
  PESTICIDES: '🧪',
  IRRIGATION: '💧',
  MISCELLANEOUS: '📦',
}

export default function ExpensesPage() {
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [expenses, setExpenses] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')

  const [form, setForm] = useState({
    category: 'FERTILIZER',
    description: '',
    amount: '',
    expenseDate: '',
    notes: '',
  })

  useEffect(() => {
    loadCrops()
  }, [])

  useEffect(() => {
    if (selectedCrop) loadExpenses(selectedCrop)
  }, [selectedCrop])

  const loadCrops = async () => {
    try {
      const res = await getCrops()
      setCrops(res.data)
      if (res.data.length > 0) setSelectedCrop(res.data[0].id)
    } catch {
      setError('Failed to load crops')
    }
  }

  const loadExpenses = async (cropId) => {
    try {
      const res = await getExpenses(cropId)
      setExpenses(res.data)
    } catch {
      setError('Failed to load expenses')
    }
  }

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSubmitting(true)
    setError('')
    try {
      await addExpense(selectedCrop, {
        ...form,
        amount: Number(form.amount),
      })
      setShowForm(false)
      setForm({
        category: 'FERTILIZER',
        description: '',
        amount: '',
        expenseDate: '',
        notes: '',
      })
      loadExpenses(selectedCrop)
    } catch (err) {
      const backendMessage = err?.response?.data?.message
      setError(backendMessage || 'Failed to add expense')
    } finally {
      setSubmitting(false)
    }
  }

  const totalExpenses = expenses.reduce(
    (sum, e) => sum + Number(e.amount), 0
  )

  const selectedCropName = crops.find(
    (c) => c.id === Number(selectedCrop)
  )?.name || ''

  return (
    <Layout>
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Expenses</h1>
          <p className="text-gray-500 mt-1">
            Track all your cultivation costs
          </p>
        </div>
        <button
          onClick={() => setShowForm(!showForm)}
          disabled={!selectedCrop}
          className="bg-green-600 hover:bg-green-700 text-white
                     px-5 py-2.5 rounded-lg text-sm font-medium
                     disabled:opacity-40 transition-colors"
        >
          {showForm ? 'Cancel' : '+ Add Expense'}
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="bg-red-50 text-red-600 text-sm px-4 py-3
                        rounded-lg mb-4 border border-red-200">
          {error}
        </div>
      )}

      {/* Crop selector */}
      <div className="bg-white rounded-xl border border-gray-200
                      p-4 mb-6 flex items-center gap-4">
        <label className="text-sm font-medium text-gray-600
                          whitespace-nowrap">
          Select Crop:
        </label>
        {crops.length === 0 ? (
          <p className="text-sm text-gray-400">
            No crops yet — add crops first
          </p>
        ) : (
          <select
            value={selectedCrop}
            onChange={(e) => setSelectedCrop(e.target.value)}
            className="border border-gray-300 rounded-lg px-3 py-2
                       text-sm focus:outline-none focus:ring-2
                       focus:ring-green-400"
          >
            {crops.map((crop) => (
              <option key={crop.id} value={crop.id}>
                {crop.name} {crop.variety ? `(${crop.variety})` : ''}
              </option>
            ))}
          </select>
        )}

        {expenses.length > 0 && (
          <div className="ml-auto text-right">
            <p className="text-xs text-gray-400">Total spent</p>
            <p className="text-lg font-bold text-red-600">
              Rs. {totalExpenses.toLocaleString()}
            </p>
          </div>
        )}
      </div>

      {/* Add expense form */}
      {showForm && (
        <div className="bg-white rounded-xl border border-gray-200
                        p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Add Expense for {selectedCropName}
          </h2>
          <form onSubmit={handleSubmit}
                className="grid grid-cols-1 md:grid-cols-2 gap-4">

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Category *
              </label>
              <select
                name="category"
                value={form.category}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              >
                {CATEGORIES.map((cat) => (
                  <option key={cat} value={cat}>
                    {CATEGORY_ICONS[cat]} {cat}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Amount (Rs.) *
              </label>
              <input
                name="amount"
                type="number"
                step="0.01"
                value={form.amount}
                onChange={handleChange}
                required
                placeholder="e.g. 3500"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Description *
              </label>
              <input
                name="description"
                value={form.description}
                onChange={handleChange}
                required
                placeholder="e.g. Urea fertilizer 50kg"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Date *
              </label>
              <input
                name="expenseDate"
                type="date"
                value={form.expenseDate}
                onChange={handleChange}
                required
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Notes
              </label>
              <input
                name="notes"
                value={form.notes}
                onChange={handleChange}
                placeholder="Optional notes..."
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div className="md:col-span-2 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setShowForm(false)}
                className="px-5 py-2 text-sm text-gray-600
                           hover:text-gray-800 font-medium"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={submitting}
                className="bg-green-600 hover:bg-green-700 text-white
                           px-6 py-2 rounded-lg text-sm font-medium
                           disabled:opacity-50 transition-colors"
              >
                {submitting ? 'Saving...' : 'Save Expense'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Expenses list */}
      {expenses.length === 0 ? (
        <div className="bg-white rounded-xl border border-gray-200
                        p-12 text-center">
          <p className="text-4xl mb-3">💰</p>
          <p className="text-gray-500 font-medium">No expenses yet</p>
          <p className="text-gray-400 text-sm mt-1">
            Click "Add Expense" to record a cost
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200
                        overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 text-left text-gray-500
                             border-b border-gray-200">
                <th className="px-5 py-3 font-medium">Category</th>
                <th className="px-5 py-3 font-medium">Description</th>
                <th className="px-5 py-3 font-medium">Date</th>
                <th className="px-5 py-3 font-medium text-right">
                  Amount
                </th>
              </tr>
            </thead>
            <tbody>
              {expenses.map((exp) => (
                <tr key={exp.id}
                    className="border-b border-gray-50
                               hover:bg-gray-50 transition-colors">
                  <td className="px-5 py-3">
                    <span className="flex items-center gap-2">
                      <span>{CATEGORY_ICONS[exp.category]}</span>
                      <span className="font-medium text-gray-700">
                        {exp.category}
                      </span>
                    </span>
                  </td>
                  <td className="px-5 py-3 text-gray-600">
                    {exp.description}
                  </td>
                  <td className="px-5 py-3 text-gray-500">
                    {exp.expenseDate}
                  </td>
                  <td className="px-5 py-3 text-right font-semibold
                                 text-red-600">
                    Rs. {Number(exp.amount).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="bg-gray-50 border-t border-gray-200">
                <td colSpan={3}
                    className="px-5 py-3 font-semibold text-gray-700">
                  Total
                </td>
                <td className="px-5 py-3 text-right font-bold
                               text-red-600 text-base">
                  Rs. {totalExpenses.toLocaleString()}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      )}
    </Layout>
  )
}