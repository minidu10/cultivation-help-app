import api from './axios'

export const getMyProfile = () => api.get('/users/me')

export const updateMyProfile = (payload) => api.put('/users/me', payload)
