import api from './axios'

// Photo checks can take most of a minute on a vision model.
const DIAGNOSE_TIMEOUT_MS = 100_000

export const getDiagnoses = (cropId) => api.get(`/crops/${cropId}/diagnoses`)

export const diagnosePhoto = (cropId, photo, note = '') => {
  const form = new FormData()
  form.append('image', photo, photo.name || 'photo.jpg')
  if (note.trim()) form.append('note', note.trim())
  return api.post(`/crops/${cropId}/diagnoses`, form, { timeout: DIAGNOSE_TIMEOUT_MS })
}

export const deleteDiagnosis = (cropId, diagnosisId) =>
  api.delete(`/crops/${cropId}/diagnoses/${diagnosisId}`)

/** Thumbnails need the auth header, which a plain <img src> cannot send. */
export const getThumbnail = (thumbnailUrl) =>
  api.get(thumbnailUrl.replace(/^\/api/, ''), { responseType: 'blob' })
