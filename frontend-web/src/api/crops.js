import api from './axios'
import axios from 'axios'

export const getCrops = () => api.get('/crops')

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

const AI_URL = import.meta.env.VITE_AI_URL || 'http://localhost:8000'

export const askAI = (question, cropContext = '') =>
  axios.post('/ai/ask', {
    question,
    crop_context: cropContext,
  })

export const getCropInsights = (data) =>
  axios.post('/ai/insights', data)