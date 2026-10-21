import api from './axios'

export const getCrops = () => api.get('/crops')

export const getCrop = (id) => api.get(`/crops/${id}`)

export const createCrop = (data) => api.post('/crops', data)

export const updateCrop = (id, data) => api.put(`/crops/${id}`, data)

export const deleteCrop = (id) => api.delete(`/crops/${id}`)

export const getExpenses = (cropId) =>
  api.get(`/crops/${cropId}/expenses`)

export const addExpense = (cropId, data) =>
  api.post(`/crops/${cropId}/expenses`, data)

export const updateExpense = (cropId, expenseId, data) =>
  api.put(`/crops/${cropId}/expenses/${expenseId}`, data)

export const deleteExpense = (cropId, expenseId) =>
  api.delete(`/crops/${cropId}/expenses/${expenseId}`)

export const getHarvests = (cropId) =>
  api.get(`/crops/${cropId}/harvests`)

export const addHarvest = (cropId, data) =>
  api.post(`/crops/${cropId}/harvests`, data)

export const updateHarvest = (cropId, harvestId, data) =>
  api.put(`/crops/${cropId}/harvests/${harvestId}`, data)

export const deleteHarvest = (cropId, harvestId) =>
  api.delete(`/crops/${cropId}/harvests/${harvestId}`)

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

// Totals, per-crop profit/loss and reminders in one round trip, instead of a
// profit/loss request per crop added up in the browser.
export const getDashboardSummary = () => api.get('/dashboard/summary')

// Goes through the backend so the request is authenticated. The AI service is
// not reachable from the browser at all.
export const askAI = (question, cropContext = '') =>
  api.post('/ai/ask', { question, cropContext })

// Goes through the backend rather than straight to the AI service, so the
// result can be cached and only regenerated when the crop's figures change.
export const getCropInsight = (cropId, { refresh = false } = {}) =>
  api.get(`/crops/${cropId}/insights`, { params: refresh ? { refresh: true } : {} })

// Reports whether the AI service is reachable and which model it is using,
// so the advisor page can show the real state instead of a fixed label.
export const getAIHealth = () => api.get('/ai/health')