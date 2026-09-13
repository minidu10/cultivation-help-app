import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { requestPasswordReset, resetPassword } from '../api/auth'
import { validatePassword, apiError } from '../utils/password'
import {
  AuthShell, StepDots, StyledInput, PasswordField, CodeInput, Alert, ResendTimer,
} from '../components/AuthUI'

const RESEND_COOLDOWN = 60

export default function ForgotPasswordPage() {
  const navigate = useNavigate()

  const [step, setStep] = useState(1)     // 1 email · 2 code + new password
  const [email, setEmail] = useState('')
  const [code, setCode] = useState('')
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')

  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [loading, setLoading] = useState(false)
  const [cooldown, setCooldown] = useState(0)

  const pwErrors = validatePassword(password)

  const handleRequest = async (e) => {
    e.preventDefault()
    setError(''); setNotice(''); setLoading(true)
    try {
      await requestPasswordReset(email.trim())
      setStep(2)
      setCooldown(RESEND_COOLDOWN)
      // The backend answers identically whether or not the account exists,
      // so the wording here must not imply the address was found.
      setNotice('If that email has an account, a reset code is on its way.')
    } catch (err) {
      setError(apiError(err, 'Could not send the reset code. Try again.'))
    } finally {
      setLoading(false)
    }
  }

  const handleResend = async () => {
    setError(''); setNotice('')
    try {
      await requestPasswordReset(email.trim())
      setCooldown(RESEND_COOLDOWN)
      setNotice('A new code is on its way.')
    } catch (err) {
      setError(apiError(err, 'Could not resend the code.'))
    }
  }

  const handleReset = async (e) => {
    e.preventDefault()
    setError('')

    if (pwErrors.length > 0) {
      setError('Weak password: ' + pwErrors[0])
      return
    }
    if (password !== confirm) {
      setError('Passwords do not match')
      return
    }

    setLoading(true)
    try {
      await resetPassword(email.trim(), code, password)
      navigate('/login', {
        state: { message: 'Password updated. Sign in with your new password.' },
      })
    } catch (err) {
      setError(apiError(err, 'Could not reset the password.'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthShell
      title="Reset your password"
      subtitle={step === 1
        ? 'We will email you a 6-digit code'
        : 'Enter the code and choose a new password'}
      footer={<>Remembered it?{' '}
        <Link to="/login" style={{ color: 'var(--accent-lime)', fontWeight: 600, textDecoration: 'none' }}>Back to sign in</Link>
      </>}
    >
      <StepDots current={step} total={2} />
      <Alert kind="error">{error}</Alert>
      {!error && <Alert kind="success">{notice}</Alert>}

      {step === 1 && (
        <form onSubmit={handleRequest}>
          <StyledInput
            label="Email *" type="email" value={email} autoFocus required
            onChange={e => setEmail(e.target.value)}
            placeholder="farmer@example.com"
          />
          <button type="submit" disabled={loading || !email.trim()} className="agro-btn" style={{ width: '100%', marginTop: '18px' }}>
            {loading ? 'Sending code…' : 'Send reset code'}
          </button>
        </form>
      )}

      {step === 2 && (
        <form onSubmit={handleReset}>
          <CodeInput value={code} onChange={setCode} autoFocus />
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '12px', marginBottom: '18px' }}>
            <button
              type="button"
              onClick={() => { setStep(1); setCode(''); setError(''); setNotice('') }}
              style={{
                background: 'none', border: 'none', padding: 0, cursor: 'pointer',
                fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)',
              }}
            >
              ← Change email
            </button>
            <ResendTimer seconds={cooldown} onResend={handleResend} />
          </div>

          <div style={{ display: 'grid', gap: '12px' }}>
            <PasswordField
              label="New Password *" name="password" value={password}
              onChange={e => setPassword(e.target.value)} errors={pwErrors} full
            />
            <StyledInput
              label="Confirm New Password *" type="password" value={confirm}
              onChange={e => setConfirm(e.target.value)} placeholder="Repeat password" required
            />
          </div>

          <button
            type="submit"
            disabled={loading || code.length !== 6 || pwErrors.length > 0 || !password}
            className="agro-btn"
            style={{ width: '100%', marginTop: '18px' }}
          >
            {loading ? 'Updating…' : 'Set new password'}
          </button>
        </form>
      )}
    </AuthShell>
  )
}
