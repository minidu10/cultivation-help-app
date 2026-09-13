import api from './axios'

// Registration is a three step flow: prove the email is real, then create
// the account. The backend re-checks the verification, so these steps
// cannot be skipped by posting straight to /auth/register.
export const sendRegistrationCode = (email) =>
  api.post('/auth/send-code', { email })

export const verifyRegistrationCode = (email, code) =>
  api.post('/auth/verify-code', { email, code })

export const register = (payload) =>
  api.post('/auth/register', payload)

export const login = (email, password) =>
  api.post('/auth/login', { email, password })

// Google Sign-In. The client id is served by the backend so the frontend
// needs no build-time configuration.
export const getAuthConfig = () =>
  api.get('/auth/config')

export const googleSignIn = (credential) =>
  api.post('/auth/google', { credential })

// Password reset uses the same code mechanism.
export const requestPasswordReset = (email) =>
  api.post('/auth/forgot-password', { email })

export const resetPassword = (email, code, newPassword) =>
  api.post('/auth/reset-password', { email, code, newPassword })
