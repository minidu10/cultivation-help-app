import { Component } from 'react'
import logo from '../assets/logo.png'

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
          fontFamily: 'var(--font-body)',
        }}>
          <img src={logo} alt="" width="56" height="56" style={{ display: 'block', margin: '0 auto 16px' }} />
          <h1 style={{
            fontFamily: 'var(--font-body)',
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
              background: 'var(--accent-lime)',
              color: 'var(--on-accent)',
              border: 'none', borderRadius: '10px',
              padding: '11px 26px',
              fontFamily: 'var(--font-body)', fontSize: '14px', fontWeight: 600,
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
