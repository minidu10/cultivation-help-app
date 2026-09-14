import api from './axios'
import axios from 'axios'

export const getCrops = () => api.get('/crops')

export const getCrop = (id) => api.get(`/crops/${id}`)

export const createCrop = (data) => api.post('/crops', data)

export const updateCrop = (id, data) => api.put(`/crops/${id}`, data)

export const deleteCrop = (id) => api.delete(`/crops/${id}`)

export const getExpenses = (cropId) =>
  api.get(`/crops/${cropId}/expenses`)

export const addExpense = (cropId, data) =>
  api.post(`/crops/${cropId}/expenses`, data)

export const getHarvests = (cropId) =>
  api.get(`/crops/${cropId}/harvests`)

export const addHarvest = (cropId, data) =>
  api.post(`/crops/${cropId}/harvests`, data)

export const getProfitLoss = (cropId) =>
  api.get(`/crops/${cropId}/expenses/profit-loss`)

export const getCropReminders = (cropId) =>
  api.get(`/crops/${cropId}/reminders`)

export const createCropReminder = (cropId, data) =>
  api.post(`/crops/${cropId}/reminders`, data)

export const updateCropReminder = (cropId, reminderId, data) =>
  api.put(`/crops/${cropId}/reminders/${reminderId}`, data)

export const deleteCropReminder = (cropId, reminderId) =>
  api.delete(`/crops/${cropId}/reminders/${reminderId}`)

export const getDueReminders = () => api.get('/reminders/due')

export const askAI = (question, cropContext = '') =>
  axios.post('/ai/ask', {
    question,
    crop_context: cropContext,
  })

// Goes through the backend rather than straight to the AI service, so the
// result can be cached and only regenerated when the crop's figures change.
export const getCropInsight = (cropId, { refresh = false } = {}) =>
  api.get(`/crops/${cropId}/insights`, { params: refresh ? { refresh: true } : {} })

// Reports whether the AI service is reachable and which model it is using,
// so the advisor page can show the real state instead of a fixed label.
export const getAIHealth = () => axios.get('/ai/health')