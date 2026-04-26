import { useState } from 'react'
import { NavLink, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const LogoutIcon = () => (
  <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor" style={{ flexShrink: 0 }}>
    <path fillRule="evenodd" clipRule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" />
  </svg>
)

const MenuIcon = () => (
  <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
    <path fillRule="evenodd" clipRule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" />
  </svg>
)

const NAV_ITEMS = [
  { path: '/dashboard',  label: 'Dashboard' },
  { path: '/crops',      label: 'My Crops' },
  { path: '/expenses',   label: 'Expenses' },
  { path: '/harvests',   label: 'Harvests' },
  { path: '/ai-advisor', label: 'AI Advisor' },
  { path: '/settings',   label: 'Settings' },
]

const PAGE_LABELS = {
  '/dashboard': 'Dashboard', '/crops': 'My Crops', '/expenses': 'Expenses',
  '/harvests': 'Harvests', '/ai-advisor': 'AI Advisor',
  '/settings': 'Settings',
}

export default function Layout({ children }) {
  const [open, setOpen] = useState(false)
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  const currentLabel = PAGE_LABELS[location.pathname] || 'Dashboard'
  const initials = (user?.fullName || 'U').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()

  return (
    <div className="grain" style={{ display: 'flex', minHeight: '100vh', background: 'var(--bg-primary)' }}>

      {/* ── Sidebar ── */}
      <aside style={{
        width: open ? '200px' : '0px',
        minHeight: '100vh',
        background: 'var(--bg-sidebar)',
        borderRight: open ? '1px solid var(--border)' : 'none',
        backdropFilter: 'blur(20px)',
        display: 'flex',
        flexDirection: 'column',
        transition: 'width 0.25s ease',
        position: 'sticky',
        top: 0,
        alignSelf: 'flex-start',
        height: '100vh',
        zIndex: 10,
        flexShrink: 0,
        overflow: 'hidden',
      }}>

        {/* Brand */}
        <div style={{
          padding: '20px 20px',
          display: 'flex', alignItems: 'center', gap: '10px',
          borderBottom: '1px solid var(--border)',
          minHeight: '64px', whiteSpace: 'nowrap',
        }}>
          <div style={{
            width: 28, height: 28, borderRadius: '7px',
            background: 'linear-gradient(135deg, #4ade80, #16a34a)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: '14px', flexShrink: 0,
            boxShadow: '0 0 12px rgba(74,222,128,0.4)',
          }}>🌿</div>
          <span style={{
            fontFamily: 'Space Grotesk, sans-serif',
            fontWeight: 800, fontSize: '16px',
            color: 'var(--text-primary)', letterSpacing: '-0.3px',
          }}>Agromaster</span>
        </div>

        {/* Nav — text only, no icons */}
        <nav style={{ flex: 1, padding: '14px 0', overflowY: 'auto' }}>
          {NAV_ITEMS.map(item => (
            <NavLink
              key={item.path}
              to={item.path}
              title={item.label}
              onClick={() => setOpen(false)}
              style={({ isActive }) => ({
                display: 'block',
                padding: '11px 20px',
                whiteSpace: 'nowrap',
                background: isActive ? 'rgba(74,222,128,0.1)' : 'transparent',
                borderLeft: isActive ? '3px solid var(--accent-lime)' : '3px solid transparent',
                textDecoration: 'none',
                fontFamily: 'Inter, sans-serif',
                fontSize: '14px',
                fontWeight: isActive ? 600 : 400,
                color: isActive ? 'var(--accent-lime)' : 'var(--text-muted)',
                transition: 'all 0.15s',
                letterSpacing: '0.01em',
              })}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        {/* Sign Out */}
        <div style={{ padding: '14px 20px 20px', borderTop: '1px solid var(--border)' }}>
          <button
            onClick={() => { logout(); navigate('/') }}
            title="Sign Out"
            style={{
              display: 'flex', alignItems: 'center', gap: '8px',
              background: 'transparent', border: 'none',
              cursor: 'pointer', color: 'var(--text-faint)',
              fontFamily: 'Inter', fontSize: '13px',
              padding: '6px 0', borderRadius: '6px',
              transition: 'all 0.2s', whiteSpace: 'nowrap',
            }}
            onMouseEnter={e => e.currentTarget.style.color = 'var(--accent-red)'}
            onMouseLeave={e => e.currentTarget.style.color = 'var(--text-faint)'}
          >
            <LogoutIcon />
            Sign Out
          </button>
        </div>
      </aside>

      {/* ── Main ── */}
      <main style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>

        {/* Topbar */}
        <header style={{
          padding: '14px 28px',
          background: 'var(--bg-header)',
          backdropFilter: 'blur(16px)',
          borderBottom: '1px solid var(--border)',
          display: 'flex', alignItems: 'center', gap: '16px',
          position: 'sticky', top: 0, zIndex: 5,
        }}>
          {/* Hamburger */}
          <button
            onClick={() => setOpen(o => !o)}
            style={{
              background: 'none', border: 'none', cursor: 'pointer',
              color: 'var(--text-muted)', padding: '4px',
              borderRadius: '6px', display: 'flex', alignItems: 'center',
              transition: 'color 0.2s', flexShrink: 0,
            }}
            onMouseEnter={e => e.currentTarget.style.color = 'var(--accent-lime)'}
            onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}
          >
            <MenuIcon />
          </button>

          <div style={{ flex: 1 }}>
            <h1 style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0, letterSpacing: '-0.5px' }}>{currentLabel}</h1>
            <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)', marginTop: '1px' }}>
              {new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
            </div>
          </div>

          {/* User badge */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '6px 12px', flexShrink: 0 }}>
            <div style={{ width: 26, height: 26, borderRadius: '50%', background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', fontWeight: 700, color: '#0a1a0f', fontFamily: 'Space Grotesk' }}>{initials}</div>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>{user?.fullName || 'User'}</div>
              <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)' }}>{user?.city || 'Agromaster Farm'}</div>
            </div>
          </div>
        </header>

        {/* Content */}
        <div className="page-content" style={{ flex: 1, padding: '28px 32px', overflowY: 'auto' }}>
          {children}
        </div>
      </main>
    </div>
  )
}
