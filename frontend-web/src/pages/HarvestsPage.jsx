import { useEffect, useState } from 'react'
import Layout from '../components/Layout'
import { getCrops, getHarvests, addHarvest } from '../api/crops'

const UNITS = ['KG', 'TONNE', 'BUSHEL', 'POUND', 'LITER']

export default function HarvestsPage() {
  const [crops, setCrops] = useState([])
  const [selectedCrop, setSelectedCrop] = useState('')
  const [harvests, setHarvests] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')

  const [form, setForm] = useState({
    harvestDate: '',
    quantity: '',
    unit: 'KG',
    pricePerUnit: '',
    buyerName: '',
    notes: '',
  })

  useEffect(() => { loadCrops() }, [])

  useEffect(() => {
    if (selectedCrop) loadHarvests(selectedCrop)
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

  const loadHarvests = async (cropId) => {
    try {
      const res = await getHarvests(cropId)
      setHarvests(res.data)
    } catch {
      setError('Failed to load harvests')
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
      await addHarvest(selectedCrop, {
        ...form,
        quantity: Number(form.quantity),
        pricePerUnit: Number(form.pricePerUnit),
      })
      setShowForm(false)
      setForm({
        harvestDate: '', quantity: '', unit: 'KG',
        pricePerUnit: '', buyerName: '', notes: '',
      })
      loadHarvests(selectedCrop)
    } catch {
      setError('Failed to add harvest')
    } finally {
      setSubmitting(false)
    }
  }

  const totalRevenue = harvests.reduce(
    (sum, h) => sum + (Number(h.quantity) * Number(h.pricePerUnit)), 0
  )

  return (
    <Layout>
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Harvests</h1>
          <p className="text-gray-500 mt-1">
            Record harvest quantities and revenue
          </p>
        </div>
        <button
          onClick={() => setShowForm(!showForm)}
          disabled={!selectedCrop}
          className="bg-green-600 hover:bg-green-700 text-white
                     px-5 py-2.5 rounded-lg text-sm font-medium
                     disabled:opacity-40 transition-colors"
        >
          {showForm ? 'Cancel' : '+ Add Harvest'}
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

        {harvests.length > 0 && (
          <div className="ml-auto text-right">
            <p className="text-xs text-gray-400">Total revenue</p>
            <p className="text-lg font-bold text-green-600">
              Rs. {totalRevenue.toLocaleString()}
            </p>
          </div>
        )}
      </div>

      {/* Add harvest form */}
      {showForm && (
        <div className="bg-white rounded-xl border border-gray-200
                        p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Record New Harvest
          </h2>
          <form onSubmit={handleSubmit}
                className="grid grid-cols-1 md:grid-cols-2 gap-4">

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Harvest Date *
              </label>
              <input
                name="harvestDate"
                type="date"
                value={form.harvestDate}
                onChange={handleChange}
                required
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div className="flex gap-3">
              <div className="flex-1">
                <label className="block text-sm font-medium
                                  text-gray-600 mb-1">
                  Quantity *
                </label>
                <input
                  name="quantity"
                  type="number"
                  step="0.001"
                  value={form.quantity}
                  onChange={handleChange}
                  required
                  placeholder="e.g. 500"
                  className="w-full border border-gray-300 rounded-lg
                             px-3 py-2 text-sm focus:outline-none
                             focus:ring-2 focus:ring-green-400"
                />
              </div>
              <div className="w-28">
                <label className="block text-sm font-medium
                                  text-gray-600 mb-1">
                  Unit *
                </label>
                <select
                  name="unit"
                  value={form.unit}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg
                             px-3 py-2 text-sm focus:outline-none
                             focus:ring-2 focus:ring-green-400"
                >
                  {UNITS.map((u) => (
                    <option key={u} value={u}>{u}</option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Price per Unit (Rs.) *
              </label>
              <input
                name="pricePerUnit"
                type="number"
                step="0.01"
                value={form.pricePerUnit}
                onChange={handleChange}
                required
                placeholder="e.g. 85"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Buyer Name
              </label>
              <input
                name="buyerName"
                value={form.buyerName}
                onChange={handleChange}
                placeholder="e.g. Colombo Market"
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

            {/* Live revenue preview */}
            {form.quantity && form.pricePerUnit && (
              <div className="md:col-span-2 bg-green-50 rounded-lg
                              px-4 py-3 border border-green-200">
                <p className="text-sm text-green-700">
                  💰 Estimated revenue:{' '}
                  <span className="font-bold">
                    Rs. {(
                      Number(form.quantity) * Number(form.pricePerUnit)
                    ).toLocaleString()}
                  </span>
                </p>
              </div>
            )}

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
                {submitting ? 'Saving...' : 'Save Harvest'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Harvests list */}
      {harvests.length === 0 ? (
        <div className="bg-white rounded-xl border border-gray-200
                        p-12 text-center">
          <p className="text-4xl mb-3">🌽</p>
          <p className="text-gray-500 font-medium">No harvests yet</p>
          <p className="text-gray-400 text-sm mt-1">
            Record your first harvest above
          </p>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200
                        overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 text-left text-gray-500
                             border-b border-gray-200">
                <th className="px-5 py-3 font-medium">Date</th>
                <th className="px-5 py-3 font-medium">Quantity</th>
                <th className="px-5 py-3 font-medium">Price/Unit</th>
                <th className="px-5 py-3 font-medium">Buyer</th>
                <th className="px-5 py-3 font-medium text-right">
                  Revenue
                </th>
              </tr>
            </thead>
            <tbody>
              {harvests.map((h) => (
                <tr key={h.id}
                    className="border-b border-gray-50
                               hover:bg-gray-50 transition-colors">
                  <td className="px-5 py-3 text-gray-600">
                    {h.harvestDate}
                  </td>
                  <td className="px-5 py-3 font-medium text-gray-700">
                    {Number(h.quantity).toLocaleString()} {h.unit}
                  </td>
                  <td className="px-5 py-3 text-gray-600">
                    Rs. {Number(h.pricePerUnit).toLocaleString()}
                  </td>
                  <td className="px-5 py-3 text-gray-500">
                    {h.buyerName || '—'}
                  </td>
                  <td className="px-5 py-3 text-right font-semibold
                                 text-green-600">
                    Rs. {(
                      Number(h.quantity) * Number(h.pricePerUnit)
                    ).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="bg-gray-50 border-t border-gray-200">
                <td colSpan={4}
                    className="px-5 py-3 font-semibold text-gray-700">
                  Total Revenue
                </td>
                <td className="px-5 py-3 text-right font-bold
                               text-green-600 text-base">
                  Rs. {totalRevenue.toLocaleString()}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      )}
    </Layout>
  )
}