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
 * without rebuilding. Nothing renders until the backend reports it configured,
 * which is what keeps these pages working before Google is set up.
 */
export default function GoogleSignIn({ onError, text = 'signin_with' }) {
  const buttonRef = useRef(null)
  const [clientId, setClientId] = useState('')
  const navigate = useNavigate()
  const { login } = useAuth()

  // Keep the latest callbacks without making them re-run the effects below:
  // re-initialising Google would tear down and redraw the button.
  const handlers = useRef({ onError, login, navigate, text })
  useEffect(() => {
    handlers.current = { onError, login, navigate, text }
  })

  // Step 1: find out whether Google is configured, and load their script.
  useEffect(() => {
    let cancelled = false

    getAuthConfig()
      .then(({ data }) => {
        if (cancelled || !data.googleEnabled) return null
        return loadGsi().then(() => {
          if (!cancelled) setClientId(data.googleClientId)
        })
      })
      .catch(() => {
        // Google unreachable or not configured. Email and password still work,
        // so this stays silent rather than showing an error the user cannot act on.
      })

    return () => { cancelled = true }
  }, [])

  // Step 2: draw the button, once the container is actually visible.
  // Google measures the element, so rendering into a display:none parent
  // produces a zero-width button.
  useEffect(() => {
    if (!clientId || !buttonRef.current) return

    window.google.accounts.id.initialize({
      client_id: clientId,
      callback: async (response) => {
        const { onError: onErr, login: doLogin, navigate: go } = handlers.current
        try {
          const { data: auth } = await googleSignIn(response.credential)
          doLogin({
            fullName: auth.fullName, email: auth.email, city: auth.city,
            themePreference: auth.themePreference, desktopMode: auth.desktopMode,
          }, auth.token)
          go('/dashboard')
        } catch (err) {
          onErr?.(apiError(err, 'Google sign-in failed. Please try again.'))
        }
      },
    })

    // Google only accepts 200-400px.
    const measured = buttonRef.current.offsetWidth || 360
    const width = Math.min(400, Math.max(200, measured))

    window.google.accounts.id.renderButton(buttonRef.current, {
      theme: 'outline',
      size: 'large',
      shape: 'pill',
      text: handlers.current.text,
      logo_alignment: 'center',
      width,
    })
  }, [clientId])

  if (!clientId) return null

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', margin: '20px 0' }}>
        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
        <span style={{
          fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '11px', fontWeight: 600,
          color: 'var(--text-faint)', textTransform: 'uppercase', letterSpacing: '0.5px',
        }}>or</span>
        <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
      </div>
      <div ref={buttonRef} style={{ display: 'flex', justifyContent: 'center', minHeight: '44px' }} />
    </div>
  )
}
