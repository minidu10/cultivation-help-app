import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { getAuthConfig, googleSignIn } from '../api/auth'
import { apiError } from '../utils/password'

const GSI_SRC = 'https://accounts.google.com/gsi/client'

/** Loads the Google Identity Services script once, shared across pages. */
function loadGsi() {
  if (window.google?.accounts?.id) return Promise.resolve()

  const existing = document.querySelector(`script[src="${GSI_SRC}"]`)
  if (existing) {
    return new Promise((resolve, reject) => {
      existing.addEventListener('load', resolve)
      existing.addEventListener('error', reject)
    })
  }

  return new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.src = GSI_SRC
    script.async = true
    script.defer = true
    script.onload = resolve
    script.onerror = () => reject(new Error('Could not load Google Sign-In'))
    document.head.appendChild(script)
  })
}

/**
 * Renders Google's own sign-in button.
 *
 * The client id comes from GET /api/auth/config rather than a build-time
 * variable, so the frontend needs no environment file and the id can change
 * without rebuilding. When it is not configured the component renders nothing,
 * which is what keeps the page working before Google is set up.
 */
export default function GoogleSignIn({ onError, text = 'signin_with' }) {
  const buttonRef = useRef(null)
  const [enabled, setEnabled] = useState(false)
  const navigate = useNavigate()
  const { login } = useAuth()

  useEffect(() => {
    let cancelled = false

    const setup = async () => {
      try {
        const { data } = await getAuthConfig()
        if (cancelled || !data.googleEnabled) return

        await loadGsi()
        if (cancelled || !buttonRef.current) return

        window.google.accounts.id.initialize({
          client_id: data.googleClientId,
          callback: async (response) => {
            try {
              const { data: auth } = await googleSignIn(response.credential)
              login({
                fullName: auth.fullName, email: auth.email, city: auth.city,
                themePreference: auth.themePreference, desktopMode: auth.desktopMode,
              }, auth.token)
              navigate('/dashboard')
            } catch (err) {
              onError?.(apiError(err, 'Google sign-in failed. Please try again.'))
            }
          },
        })

        window.google.accounts.id.renderButton(buttonRef.current, {
          theme: 'outline',
          size: 'large',
          shape: 'pill',
          text,
          width: buttonRef.current.offsetWidth || 360,
        })
        setEnabled(true)
      } catch {
        // Google unreachable or not configured: the page still works with
        // email and password, so this stays silent.
        if (!cancelled) setEnabled(false)
      }
    }

    setup()
    return () => { cancelled = true }
  }, [])

  return (
    <div style={{ display: enabled ? 'block' : 'none' }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: '12px',
        margin: '20px 0',
      }}>
        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
        <span style={{
          fontFamily: 'Inter', fontSize: '11px', fontWeight: 600,
          color: 'var(--text-faint)', textTransform: 'uppercase', letterSpacing: '0.5px',
        }}>or</span>
        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
      </div>
      <div ref={buttonRef} style={{ display: 'flex', justifyContent: 'center', minHeight: '40px' }} />
    </div>
  )
}
