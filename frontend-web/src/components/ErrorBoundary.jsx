import { Component } from 'react'

/**
 * Catches render errors anywhere below it.
 *
 * Without this React unmounts the whole tree on an uncaught render error, so a
 * single bad value in one component leaves the farmer staring at a blank white
 * page with nothing to act on.
 *
 * Must be a class: there is no hook equivalent of componentDidCatch.
 */
export default class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  componentDidCatch(error, info) {
    // Goes to the browser console for debugging; nothing is sent anywhere.
    console.error('Unhandled render error:', error, info?.componentStack)
  }

  render() {
    if (!this.state.hasError) return this.props.children

    return (
      <div style={{
        minHeight: '100vh',
        background: 'var(--bg-primary, #0b1410)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px',
      }}>
        <div style={{
          maxWidth: '420px',
          textAlign: 'center',
          fontFamily: 'Inter, system-ui, sans-serif',
        }}>
          <div style={{ fontSize: '40px', marginBottom: '16px' }}>🌿</div>
          <h1 style={{
            fontFamily: 'Space Grotesk, Inter, sans-serif',
            fontSize: '20px', fontWeight: 700,
            color: 'var(--text-primary, #e8f5e2)',
            margin: '0 0 8px',
          }}>
            Something went wrong
          </h1>
          <p style={{
            fontSize: '14px', lineHeight: 1.6,
            color: 'var(--text-muted, #9aa8a0)',
            margin: '0 0 24px',
          }}>
            The page could not be displayed. Your data is safe — reloading
            usually fixes it.
          </p>
          <button
            onClick={() => window.location.reload()}
            style={{
              background: 'linear-gradient(135deg, #4ade80, #16a34a)',
              color: '#06210f',
              border: 'none', borderRadius: '10px',
              padding: '11px 26px',
              fontFamily: 'Inter, sans-serif', fontSize: '14px', fontWeight: 600,
              cursor: 'pointer',
            }}
          >
            Reload the page
          </button>
        </div>
      </div>
    )
  }
}
