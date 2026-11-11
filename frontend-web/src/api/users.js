import api from './axios'

export const getMyProfile = () => api.get('/users/me')

export const updateMyProfile = (payload) => api.put('/users/me', payload)

export const uploadMyPhoto = (file) => {
  const form = new FormData()
  form.append('image', file)
  return api.post('/users/me/photo', form)
}

export const removeMyPhoto = () => api.delete('/users/me/photo')

/** The picture needs the auth header, which a plain <img src> cannot send. */
export const getMyPhoto = () => api.get('/users/me/photo', { responseType: 'blob' })
