import { useState, useEffect } from 'react'
import { getPasswordStrength } from '../utils/password'

/** Text field matching the styling used across the auth pages. */
export function StyledInput({ label, type = 'text', value, onChange, placeholder, name, required, half, autoFocus, disabled }) {
  const [focused, setFocused] = useState(false)
  return (
    <div style={{ gridColumn: half ? 'span 1' : '1 / -1' }}>
      <label style={{
        display: 'block', fontFamily: 'Inter',
        fontSize: '12px', fontWeight: 600,
        color: 'var(--text-muted)', marginBottom: '6px',
        textTransform: 'uppercase', letterSpacing: '0.5px',
      }}>{label}</label>
      <input
        type={type} value={value} onChange={onChange}
        placeholder={placeholder} name={name} required={required}
        autoFocus={autoFocus} disabled={disabled}
        onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
        style={{
          width: '100%', boxSizing: 'border-box',
          background: 'var(--bg-input)',
          border: `1.5px solid ${focused ? 'var(--accent-lime)' : 'var(--border)'}`,
          borderRadius: '10px', padding: '11px 14px',
          fontFamily: 'Inter', fontSize: '14px',
          color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
          opacity: disabled ? 0.6 : 1,
          boxShadow: focused ? '0 0 0 3px rgba(74,222,128,0.1)' : 'none',
        }}
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
        <span style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)' }}>Password strength</span>
        <span style={{ fontFamily: 'Inter', fontSize: '11px', fontWeight: 600, color }}>{label}</span>
      </div>
    </div>
  )
}

/** Password field with live strength meter and the unmet-rules list. */
export function PasswordField({ label = 'Password *', name, value, onChange, errors, placeholder = 'Min. 8 characters', full }) {
  return (
    <div style={{ gridColumn: full ? '1 / -1' : 'span 1' }}>
      <label style={{
        display: 'block', fontFamily: 'Inter', fontSize: '12px', fontWeight: 600,
        color: 'var(--text-muted)', marginBottom: '6px',
        textTransform: 'uppercase', letterSpacing: '0.5px',
      }}>{label}</label>
      <input
        type="password" name={name} value={value} onChange={onChange}
        placeholder={placeholder} required
        style={{
          width: '100%', boxSizing: 'border-box',
          background: 'var(--bg-input)',
          border: `1.5px solid ${value && errors.length === 0 ? '#4ade80' : value ? '#f87171' : 'var(--border)'}`,
          borderRadius: '10px', padding: '11px 14px',
          fontFamily: 'Inter', fontSize: '14px',
          color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
        }}
      />
      <PasswordStrengthBar password={value} />
      {value && errors.length > 0 && (
        <ul style={{ margin: '6px 0 0', paddingLeft: '16px', listStyle: 'disc' }}>
          {errors.map(e => (
            <li key={e} style={{ fontFamily: 'Inter', fontSize: '11px', color: '#f87171', lineHeight: 1.6 }}>{e}</li>
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
      placeholder="000000"
      autoFocus={autoFocus}
      style={{
        width: '100%', boxSizing: 'border-box',
        background: 'var(--bg-input)',
        border: `1.5px solid ${value.length === 6 ? '#4ade80' : 'var(--border)'}`,
        borderRadius: '10px', padding: '14px',
        fontFamily: 'Space Grotesk, monospace',
        fontSize: '28px', fontWeight: 700,
        letterSpacing: '10px', textAlign: 'center', textIndent: '10px',
        color: 'var(--text-primary)', outline: 'none', transition: 'all 0.2s',
      }}
    />
  )
}

export function Alert({ kind = 'error', children }) {
  if (!children) return null
  const error = kind === 'error'
  return (
    <div style={{
      background: error ? 'rgba(248,113,113,0.08)' : 'rgba(74,222,128,0.08)',
      border: `1px solid ${error ? 'rgba(248,113,113,0.25)' : 'rgba(74,222,128,0.25)'}`,
      borderRadius: '10px', padding: '11px 14px',
      fontFamily: 'Inter', fontSize: '13px',
      color: error ? 'var(--accent-red)' : 'var(--accent-lime)',
      marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px',
    }}>
      <span>{error ? '⚠' : '✓'}</span> {children}
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
      <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)' }}>
        Resend code in {left}s
      </span>
    )
  }
  return (
    <button
      type="button" onClick={onResend} disabled={disabled}
      style={{
        background: 'none', border: 'none', padding: 0, cursor: 'pointer',
        fontFamily: 'Inter', fontSize: '12px', fontWeight: 600,
        color: 'var(--accent-lime)',
      }}
    >
      Resend code
    </button>
  )
}

/** Shared page chrome: logo, heading, card. */
export function AuthShell({ title, subtitle, children, footer, maxWidth = '440px' }) {
  return (
    <div style={{
      minHeight: '100vh', background: 'var(--bg-primary)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      padding: '40px 24px',
    }}>
      <div style={{ width: '100%', maxWidth }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '28px' }}>
          <div style={{
            width: 44, height: 44, borderRadius: '12px',
            background: 'linear-gradient(135deg, #4ade80, #16a34a)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: '22px', boxShadow: '0 0 24px rgba(74,222,128,0.4)',
          }}>🌿</div>
          <div>
            <div style={{ fontFamily: 'Space Grotesk', fontWeight: 800, fontSize: '22px', color: 'var(--text-primary)', letterSpacing: '-0.5px', lineHeight: 1 }}>Agromaster</div>
            <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)', marginTop: '3px' }}>Farm Management Platform</div>
          </div>
        </div>

        <div style={{ marginBottom: '24px' }}>
          <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '26px', color: 'var(--text-primary)', margin: '0 0 6px', letterSpacing: '-0.5px' }}>{title}</h1>
          {subtitle && <p style={{ fontFamily: 'Inter', fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>{subtitle}</p>}
        </div>

        <div className="auth-card" style={{
          background: 'var(--bg-card)', border: '1px solid var(--border)',
          borderRadius: '20px', padding: '28px 32px 32px', backdropFilter: 'blur(16px)',
        }}>
          {children}
        </div>

        {footer && (
          <div style={{ marginTop: '20px', textAlign: 'center', fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>
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
    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '22px' }}>
      {Array.from({ length: total }, (_, i) => i + 1).map(n => (
        <div key={n} style={{ display: 'flex', alignItems: 'center', gap: '8px', flex: n < total ? 1 : '0 0 auto' }}>
          <div style={{
            width: 26, height: 26, borderRadius: '50%', flexShrink: 0,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'Inter', fontSize: '12px', fontWeight: 700,
            background: n <= current ? 'linear-gradient(135deg, #4ade80, #16a34a)' : 'var(--bg-input)',
            color: n <= current ? '#06210f' : 'var(--text-faint)',
            border: n <= current ? 'none' : '1px solid var(--border)',
            transition: 'all 0.25s',
          }}>{n < current ? '✓' : n}</div>
          {n < total && (
            <div style={{
              height: 2, flex: 1, borderRadius: 2,
              background: n < current ? '#4ade80' : 'var(--border)',
              transition: 'background 0.25s',
            }} />
          )}
        </div>
      ))}
    </div>
  )
}
