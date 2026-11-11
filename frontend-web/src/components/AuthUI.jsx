import { useState, useEffect, useId } from 'react'
import { Link } from 'react-router-dom'
import { getPasswordStrength } from '../utils/password'
import logo from '../assets/logo.png'

const font = 'var(--font-body)'

const labelStyle = {
  display: 'block', fontFamily: font, fontSize: '14px', fontWeight: 500,
  color: 'var(--text-primary)', marginBottom: '6px',
}

// Filled fields with a soft outline, as in the Android app.
const inputStyle = (borderColor, extra) => ({
  width: '100%', boxSizing: 'border-box',
  background: 'var(--bg-input)',
  border: `1px solid ${borderColor}`,
  borderRadius: 'var(--radius-control)', padding: '14px',
  fontFamily: font, fontSize: '15px',
  color: 'var(--text-primary)', outline: 'none', transition: 'border-color 0.15s, box-shadow 0.15s',
  ...extra,
})

const focusRing = '0 0 0 3px color-mix(in srgb, var(--accent-lime) 18%, transparent)'

/** Text field matching the styling used across the auth pages. */
export function StyledInput({ label, type = 'text', value, onChange, placeholder, name, required, half, autoFocus, disabled, autoComplete }) {
  const [focused, setFocused] = useState(false)
  const id = useId()
  return (
    <div style={{ gridColumn: half ? 'span 1' : '1 / -1' }}>
      <label htmlFor={id} style={labelStyle}>{label}</label>
      <input
        id={id}
        type={type} value={value} onChange={onChange}
        placeholder={placeholder} name={name} required={required}
        autoFocus={autoFocus} disabled={disabled} autoComplete={autoComplete}
        onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
        style={inputStyle(focused ? 'var(--accent-lime)' : 'var(--border-hover)', {
          opacity: disabled ? 0.6 : 1,
          boxShadow: focused ? focusRing : 'none',
        })}
      />
    </div>
  )
}

function PasswordStrengthBar({ password }) {
  const { score, label, color } = getPasswordStrength(password)
  if (!password) return null
  const pct = Math.round((score / 6) * 100)

  return (
    <div style={{ marginTop: '8px' }}>
      <div style={{ height: '4px', borderRadius: '99px', background: 'var(--border)', overflow: 'hidden' }}>
        <div style={{
          height: '100%', width: `${pct}%`, background: color,
          borderRadius: '99px', transition: 'width 0.3s, background 0.3s',
        }} />
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '5px' }}>
        <span style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-muted)' }}>Password strength</span>
        <span style={{ fontFamily: font, fontSize: '12px', fontWeight: 600, color }}>{label}</span>
      </div>
    </div>
  )
}

/** Password field with live strength meter and the unmet-rules list. */
export function PasswordField({ label = 'Password *', name, value, onChange, errors, placeholder = 'Min. 8 characters', full }) {
  const id = useId()
  const border = value && errors.length === 0 ? 'var(--accent-lime)' : value ? 'var(--accent-red)' : 'var(--border-hover)'
  return (
    <div style={{ gridColumn: full ? '1 / -1' : 'span 1' }}>
      <label htmlFor={id} style={labelStyle}>{label}</label>
      <input
        id={id}
        type="password" name={name} value={value} onChange={onChange}
        placeholder={placeholder} required autoComplete="new-password"
        style={inputStyle(border)}
      />
      <PasswordStrengthBar password={value} />
      {value && errors.length > 0 && (
        <ul style={{ margin: '6px 0 0', paddingLeft: '16px', listStyle: 'disc' }}>
          {errors.map(e => (
            <li key={e} style={{ fontFamily: font, fontSize: '12px', color: 'var(--accent-red)', lineHeight: 1.6 }}>{e}</li>
          ))}
        </ul>
      )}
    </div>
  )
}

/** Six-digit code entry. Accepts only digits and strips spaces on paste. */
export function CodeInput({ value, onChange, autoFocus }) {
  return (
    <input
      value={value}
      onChange={e => onChange(e.target.value.replace(/\D/g, '').slice(0, 6))}
      inputMode="numeric"
      autoComplete="one-time-code"
      aria-label="6-digit code"
      placeholder="000000"
      autoFocus={autoFocus}
      style={inputStyle(value.length === 6 ? 'var(--accent-lime)' : 'var(--border-hover)', {
        padding: '14px',
        fontSize: '28px', fontWeight: 700, fontVariantNumeric: 'tabular-nums',
        letterSpacing: '10px', textAlign: 'center', textIndent: '10px',
      })}
    />
  )
}

export function Alert({ kind = 'error', children }) {
  if (!children) return null
  const error = kind === 'error'
  const color = error ? 'var(--accent-red)' : 'var(--accent-lime)'
  return (
    <div role={error ? 'alert' : 'status'} style={{
      background: `color-mix(in srgb, ${color} 9%, var(--bg-card))`,
      borderRadius: '10px', padding: '12px 14px',
      fontFamily: font, fontSize: '14px', color,
      marginBottom: '20px', display: 'flex', alignItems: 'flex-start', gap: '10px',
    }}>
      <svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
        {error
          ? <><circle cx="12" cy="12" r="9" /><path d="M12 8v5" /><path d="M12 16.5v.01" /></>
          : <><circle cx="12" cy="12" r="9" /><path d="M8 12.5l2.5 2.5L16 9.5" /></>}
      </svg>
      <span>{children}</span>
    </div>
  )
}

/**
 * "Resend code" with the 60 second cooldown the backend enforces.
 * Showing the countdown avoids the user hitting a 429 they can't explain.
 */
export function ResendTimer({ seconds, onResend, disabled }) {
  const [left, setLeft] = useState(seconds)

  useEffect(() => {
    setLeft(seconds)
  }, [seconds])

  useEffect(() => {
    if (left <= 0) return
    const id = setTimeout(() => setLeft(left - 1), 1000)
    return () => clearTimeout(id)
  }, [left])

  if (left > 0) {
    return (
      <span style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)' }}>
        Resend code in {left}s
      </span>
    )
  }
  return (
    <button
      type="button" onClick={onResend} disabled={disabled}
      style={{
        background: 'none', border: 'none', padding: 0, cursor: 'pointer',
        fontFamily: font, fontSize: '13px', fontWeight: 600,
        color: 'var(--accent-lime)',
      }}
    >
      Resend code
    </button>
  )
}

/** Logo mark and wordmark, linking home. */
export function BrandMark({ size = 44 }) {
  return (
    <Link to="/" style={{ display: 'inline-flex', alignItems: 'center', gap: '10px', textDecoration: 'none' }}>
      <img src={logo} alt="" width={size} height={size} style={{ display: 'block' }} />
      <span style={{ fontFamily: font, fontWeight: 700, fontSize: `${Math.round(size * 0.52)}px`, color: 'var(--text-primary)' }}>
        Agro<span style={{ color: 'var(--accent-lime)' }}>Master</span>
      </span>
    </Link>
  )
}

/** Shared page chrome, laid out like the Android app's sign-in: logo, heading, form card. */
export function AuthShell({ title, subtitle, children, footer, maxWidth = '440px' }) {
  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '40px 20px' }}>
      <div style={{ width: '100%', maxWidth }}>
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '28px' }}>
          <BrandMark />
        </div>

        <div style={{ marginBottom: '20px', textAlign: 'center' }}>
          <h1 style={{ fontFamily: font, fontWeight: 700, fontSize: '28px', lineHeight: 1.2, color: 'var(--text-primary)', margin: '0 0 6px', textWrap: 'balance' }}>{title}</h1>
          {subtitle && <p style={{ fontFamily: font, fontSize: '15px', color: 'var(--text-muted)', margin: 0 }}>{subtitle}</p>}
        </div>

        <div className="auth-card" style={{
          background: 'var(--bg-card)', border: '1px solid var(--border)',
          borderRadius: 'var(--radius-card)', padding: '28px 24px 28px',
        }}>
          {children}
        </div>

        {footer && (
          <div style={{ marginTop: '20px', textAlign: 'center', fontFamily: font, fontSize: '14px', color: 'var(--text-muted)' }}>
            {footer}
          </div>
        )}
      </div>
    </div>
  )
}

/** Numbered progress indicator for the multi-step flows. */
export function StepDots({ current, total }) {
  return (
    <div aria-label={`Step ${current} of ${total}`} role="img" style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '22px' }}>
      {Array.from({ length: total }, (_, i) => i + 1).map(n => (
        <div key={n} style={{ display: 'flex', alignItems: 'center', gap: '8px', flex: n < total ? 1 : '0 0 auto' }}>
          <div style={{
            width: 28, height: 28, borderRadius: '50%', flexShrink: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: font, fontSize: '13px', fontWeight: 700,
            background: n <= current ? 'var(--accent-lime)' : 'var(--bg-input)',
            color: n <= current ? 'var(--on-accent)' : 'var(--text-muted)',
            border: n <= current ? 'none' : '1px solid var(--border-hover)',
            transition: 'all 0.25s',
          }}>{n < current ? '✓' : n}</div>
          {n < total && (
            <div style={{
              height: 2, flex: 1, borderRadius: 2,
              background: n < current ? 'var(--accent-lime)' : 'var(--border-hover)',
              transition: 'background 0.25s',
            }} />
          )}
        </div>
      ))}
    </div>
  )
}
