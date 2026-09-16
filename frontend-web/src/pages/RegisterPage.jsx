import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import { sendRegistrationCode, verifyRegistrationCode, register } from '../api/auth'
import { validatePassword, apiError } from '../utils/password'
import {
  AuthShell, StepDots, StyledInput, PasswordField, CodeInput, Alert, ResendTimer,
} from '../components/AuthUI'
import GoogleSignIn from '../components/GoogleSignIn'

const RESEND_COOLDOWN = 60   // matches app.verification.resend-cooldown-seconds

export default function RegisterPage() {
  const isMobile = useIsMobile()
  const navigate = useNavigate()
  const { login } = useAuth()

  const [step, setStep] = useState(1)     // 1 email · 2 code · 3 details
  const [email, setEmail] = useState('')
  const [code, setCode] = useState('')
  const [form, setForm] = useState({ fullName: '', password: '', confirmPassword: '', phone: '', city: '' })

  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [loading, setLoading] = useState(false)
  const [cooldown, setCooldown] = useState(0)

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value })
  const pwErrors = validatePassword(form.password)

  // Step 1 — ask the backend to email a code
  const handleSendCode = async (e) => {
    e.preventDefault()
    setError(''); setNotice(''); setLoading(true)
    try {
      await sendRegistrationCode(email.trim())
      setStep(2)
      setCooldown(RESEND_COOLDOWN)
      setNotice(`We sent a 6-digit code to ${email.trim()}`)
    } catch (err) {
      setError(apiError(err, 'Could not send the verification code. Try again.'))
    } finally {
      setLoading(false)
    }
  }

  const handleResend = async () => {
    setError(''); setNotice('')
    try {
      await sendRegistrationCode(email.trim())
      setCooldown(RESEND_COOLDOWN)
      setNotice('A new code is on its way.')
    } catch (err) {
      setError(apiError(err, 'Could not resend the code.'))
    }
  }

  // Step 2 — confirm the code
  const handleVerify = async (e) => {
    e.preventDefault()
    setError(''); setNotice(''); setLoading(true)
    try {
      await verifyRegistrationCode(email.trim(), code)
      setStep(3)
      setNotice('Email verified. Finish creating your account.')
    } catch (err) {
      setError(apiError(err, 'That code is not correct.'))
    } finally {
      setLoading(false)
    }
  }

  // Step 3 — create the account
  const handleRegister = async (e) => {
    e.preventDefault()
    setError('')

    if (pwErrors.length > 0) {
      setError('Weak password: ' + pwErrors[0])
      return
    }
    if (form.password !== form.confirmPassword) {
      setError('Passwords do not match')
      return
    }

    setLoading(true)
    try {
      const { data } = await register({
        fullName: form.fullName,
        email: email.trim(),
        password: form.password,
        phone: form.phone,
        city: form.city,
      })
      login({
        fullName: data.fullName, email: data.email, city: data.city,
        themePreference: data.themePreference, desktopMode: data.desktopMode,
      }, data.token)
      navigate('/dashboard')
    } catch (err) {
      setError(apiError(err, 'Registration failed. Please try again.'))
    } finally {
      setLoading(false)
    }
  }

  const subtitles = {
    1: 'First, let us verify your email address',
    2: 'Enter the 6-digit code we emailed you',
    3: 'Almost there — tell us about yourself',
  }

  return (
    <AuthShell
      title="Create your account"
      subtitle={subtitles[step]}
      maxWidth={step === 3 ? '480px' : '440px'}
      footer={<>Already have an account?{' '}
        <Link to="/login" style={{ color: 'var(--accent-lime)', fontWeight: 600, textDecoration: 'none' }}>Sign in</Link>
      </>}
    >
      <StepDots current={step} total={3} />
      <Alert kind="error">{error}</Alert>
      {!error && <Alert kind="success">{notice}</Alert>}

      {/* ------------------------------------------------- step 1: email */}
      {step === 1 && (
        <form onSubmit={handleSendCode}>
          <StyledInput
            label="Email *" type="email" value={email} autoFocus required
            onChange={e => setEmail(e.target.value)}
            placeholder="farmer@example.com"
          />
          <p style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-faint)', margin: '10px 0 0', lineHeight: 1.6 }}>
            We will email a verification code to this address. Reminders and
            account notifications are sent here too, so use one you check.
          </p>
          <button type="submit" disabled={loading || !email.trim()} className="agro-btn" style={{ width: '100%', marginTop: '18px' }}>
            {loading ? 'Sending code…' : 'Send verification code'}
          </button>

          {/* Google has already verified the address, so signing up this way
              skips the code entirely. Offered on step 1 only. */}
          <GoogleSignIn onError={setError} text="signup_with" />
        </form>
      )}

      {/* -------------------------------------------------- step 2: code */}
      {step === 2 && (
        <form onSubmit={handleVerify}>
          <CodeInput value={code} onChange={setCode} autoFocus />
          <div style={{
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            marginTop: '12px',
          }}>
            <button
              type="button"
              onClick={() => { setStep(1); setCode(''); setError(''); setNotice('') }}
              style={{
                background: 'none', border: 'none', padding: 0, cursor: 'pointer',
                fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-muted)',
              }}
            >
              ← Change email
            </button>
            <ResendTimer seconds={cooldown} onResend={handleResend} />
          </div>
          <p style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '12px', color: 'var(--text-faint)', margin: '14px 0 0', lineHeight: 1.6 }}>
            The code expires in 10 minutes. After 5 incorrect attempts you will
            need to request a new one.
          </p>
          <button type="submit" disabled={loading || code.length !== 6} className="agro-btn" style={{ width: '100%', marginTop: '18px' }}>
            {loading ? 'Verifying…' : 'Verify email'}
          </button>
        </form>
      )}

      {/* ----------------------------------------------- step 3: details */}
      {step === 3 && (
        <form onSubmit={handleRegister}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: '8px',
            padding: '10px 14px', marginBottom: '16px',
            background: 'rgba(74,222,128,0.06)',
            border: '1px solid rgba(74,222,128,0.15)', borderRadius: '10px',
          }}>
            <span style={{ color: 'var(--accent-lime)' }}>✓</span>
            <span style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '13px', color: 'var(--text-primary)' }}>{email.trim()}</span>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '12px' }}>
            <StyledInput label="Full Name *" name="fullName" value={form.fullName} onChange={handleChange} placeholder="Kamal Perera" required autoFocus />
            <StyledInput label="Phone" name="phone" value={form.phone} onChange={handleChange} placeholder="+94 77 123 4567" half />
            <StyledInput label="City" name="city" value={form.city} onChange={handleChange} placeholder="Ratnapura" half />
            <PasswordField name="password" value={form.password} onChange={handleChange} errors={pwErrors} full={isMobile} />
            <StyledInput label="Confirm Password *" type="password" name="confirmPassword" value={form.confirmPassword} onChange={handleChange} placeholder="Repeat password" required half />
          </div>

          <div style={{ marginTop: '10px', padding: '10px 14px', background: 'rgba(74,222,128,0.05)', border: '1px solid rgba(74,222,128,0.12)', borderRadius: '8px' }}>
            <p style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '11px', color: 'var(--text-faint)', margin: 0, lineHeight: 1.7 }}>
              Password must include: uppercase &amp; lowercase letters, a number, and a special character (e.g. !@#$%)
            </p>
          </div>

          <button
            type="submit"
            disabled={loading || pwErrors.length > 0 || !form.password || !form.fullName}
            className="agro-btn"
            style={{ width: '100%', marginTop: '16px', opacity: (pwErrors.length > 0 && form.password) ? 0.5 : 1 }}
          >
            {loading ? 'Creating account…' : 'Start Growing Free'}
          </button>
        </form>
      )}
    </AuthShell>
  )
}
