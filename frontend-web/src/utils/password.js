// Mirrors PasswordPolicy.java on the backend. The server is the authority —
// these checks exist to give immediate feedback, not to be the only gate.

export function getPasswordStrength(password) {
  if (!password) return { score: 0, label: '', color: '' }
  let score = 0
  if (password.length >= 8)  score++
  if (password.length >= 12) score++
  if (/[A-Z]/.test(password)) score++
  if (/[a-z]/.test(password)) score++
  if (/[0-9]/.test(password)) score++
  if (/[^A-Za-z0-9]/.test(password)) score++

  if (score <= 2) return { score, label: 'Weak',   color: '#f87171' }
  if (score <= 4) return { score, label: 'Fair',   color: '#f59e0b' }
  if (score <= 5) return { score, label: 'Good',   color: '#60a5fa' }
  return             { score, label: 'Strong', color: '#4ade80' }
}

export function validatePassword(password) {
  const errors = []
  if (password.length < 8)            errors.push('At least 8 characters')
  if (!/[A-Z]/.test(password))        errors.push('At least one uppercase letter')
  if (!/[a-z]/.test(password))        errors.push('At least one lowercase letter')
  if (!/[0-9]/.test(password))        errors.push('At least one number')
  if (!/[^A-Za-z0-9]/.test(password)) errors.push('At least one special character (!@#$...)')
  return errors
}

/** Pulls the server's message out of an axios error, with a sensible default. */
export function apiError(err, fallback) {
  return err?.response?.data?.message || fallback
}
