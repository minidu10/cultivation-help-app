import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Layout from '../components/Layout'
import { getCrops, createCrop, deleteCrop } from '../api/crops'

const STATUS_COLORS = {
  PLANTED: 'bg-blue-100 text-blue-700',
  GROWING: 'bg-green-100 text-green-700',
  READY_TO_HARVEST: 'bg-amber-100 text-amber-700',
  HARVESTED: 'bg-gray-100 text-gray-600',
  FAILED: 'bg-red-100 text-red-700',
}

export default function CropsPage() {
  const navigate = useNavigate()
  const [crops, setCrops] = useState([])
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')

  const [form, setForm] = useState({
    name: '',
    variety: '',
    fieldLocation: '',
    fieldSizeAcres: '',
    plantingDate: '',
    expectedHarvestDate: '',
    notes: '',
  })

  useEffect(() => {
    loadCrops()
  }, [])

  const loadCrops = async () => {
    try {
      const res = await getCrops()
      setCrops(res.data)
    } catch {
      setError('Failed to load crops')
    } finally {
      setLoading(false)
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
      await createCrop({
        ...form,
        fieldSizeAcres: form.fieldSizeAcres
          ? Number(form.fieldSizeAcres) : null,
      })
      setShowForm(false)
      setForm({
        name: '', variety: '', fieldLocation: '',
        fieldSizeAcres: '', plantingDate: '',
        expectedHarvestDate: '', notes: '',
      })
      loadCrops()
    } catch {
      setError('Failed to create crop')
    } finally {
      setSubmitting(false)
    }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this crop and all its data?')) return
    try {
      await deleteCrop(id)
      setCrops(crops.filter((c) => c.id !== id))
    } catch {
      setError('Failed to delete crop')
    }
  }

  return (
    <Layout>
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">My Crops</h1>
          <p className="text-gray-500 mt-1">
            {crops.length} crop{crops.length !== 1 ? 's' : ''} recorded
          </p>
        </div>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-green-600 hover:bg-green-700 text-white
                     px-5 py-2.5 rounded-lg text-sm font-medium
                     transition-colors"
        >
          {showForm ? 'Cancel' : '+ Add Crop'}
        </button>
      </div>

      {/* Error */}
      {error && (
        <div className="bg-red-50 text-red-600 text-sm px-4 py-3
                        rounded-lg mb-4 border border-red-200">
          {error}
        </div>
      )}

      {/* Add crop form */}
      {showForm && (
        <div className="bg-white rounded-xl border border-gray-200
                        p-6 mb-6">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            New Crop Details
          </h2>
          <form onSubmit={handleSubmit}
                className="grid grid-cols-1 md:grid-cols-2 gap-4">

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Crop Name *
              </label>
              <input
                name="name"
                value={form.name}
                onChange={handleChange}
                required
                placeholder="e.g. Rice"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Variety
              </label>
              <input
                name="variety"
                value={form.variety}
                onChange={handleChange}
                placeholder="e.g. Samba"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Field Location
              </label>
              <input
                name="fieldLocation"
                value={form.fieldLocation}
                onChange={handleChange}
                placeholder="e.g. North Field"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Field Size (acres)
              </label>
              <input
                name="fieldSizeAcres"
                type="number"
                step="0.1"
                value={form.fieldSizeAcres}
                onChange={handleChange}
                placeholder="e.g. 2.5"
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Planting Date *
              </label>
              <input
                name="plantingDate"
                type="date"
                value={form.plantingDate}
                onChange={handleChange}
                required
                className="w-full border border-gray-300 rounded-lg
                           px-3 py-2 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400"
              />
            </div>

            <div>
              <label className="block text-sm font-medium
                                text-gray-600 mb-1">
                Expected Harvest Date
              </label>
              <input
                name="expectedHarvestDate"
                type="date"
                value={form.expectedHarvestDate}
                onChange={handleChange}
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
              <textarea
                name="notes"
                value={form.notes}
                onChange={handleChange}
                rows={2}
                placeholder="Any additional notes..."
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
                {submitting ? 'Saving...' : 'Save Crop'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Crops list */}
      {loading ? (
        <p className="text-gray-400 animate-pulse">Loading crops...</p>
      ) : crops.length === 0 ? (
        <div className="bg-white rounded-xl border border-gray-200
                        p-12 text-center">
          <p className="text-4xl mb-3">🌱</p>
          <p className="text-gray-500 font-medium">No crops yet</p>
          <p className="text-gray-400 text-sm mt-1">
            Click "Add Crop" to get started
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2
                        lg:grid-cols-3 gap-4">
          {crops.map((crop) => (
            <div
              key={crop.id}
              className="bg-white rounded-xl border border-gray-200
                         p-5 hover:shadow-md transition-shadow cursor-pointer"
              onClick={() => navigate(`/crops/${crop.id}`)}
            >
              {/* Crop header */}
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="font-semibold text-gray-800">
                    {crop.name}
                  </h3>
                  {crop.variety && (
                    <p className="text-sm text-gray-500">{crop.variety}</p>
                  )}
                </div>
                <span className={`text-xs px-2 py-1 rounded-full
                                  font-medium ${STATUS_COLORS[crop.status]
                                  || STATUS_COLORS.PLANTED}`}>
                  {crop.status?.replace('_', ' ')}
                </span>
              </div>

              {/* Crop details */}
              <div className="space-y-1.5 text-sm text-gray-500">
                {crop.fieldLocation && (
                  <p>📍 {crop.fieldLocation}</p>
                )}
                {crop.fieldSizeAcres && (
                  <p>📐 {crop.fieldSizeAcres} acres</p>
                )}
                <p>🌱 Planted: {crop.plantingDate}</p>
                {crop.expectedHarvestDate && (
                  <p>📅 Harvest by: {crop.expectedHarvestDate}</p>
                )}
              </div>

              {/* Actions */}
              <div className="flex gap-2 mt-4 pt-4
                              border-t border-gray-100">
                <button
                  onClick={(e) => {
                    e.stopPropagation()
                    handleDelete(crop.id)
                  }}
                  className="text-xs text-red-400 hover:text-red-600
                             font-medium transition-colors"
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </Layout>
  )
}