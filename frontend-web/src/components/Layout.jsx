import { useState } from 'react'
import { NavLink, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import logo from '../assets/logo.png'

const LogoutIcon = () => (
  <svg aria-hidden="true" width="16" height="16" viewBox="0 0 20 20" fill="currentColor" style={{ flexShrink: 0 }}>
    <path fillRule="evenodd" clipRule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z" />
  </svg>
)

const MenuIcon = ({ open }) => (
  <svg aria-hidden="true" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
    {open
      ? <><path d="M6 6l12 12" /><path d="M18 6L6 18" /></>
      : <><path d="M4 7h16" /><path d="M4 12h16" /><path d="M4 17h16" /></>}
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
  '/settings': 'Settings', '/profile': 'Profile',
}

const font = 'var(--font-body)'

/**
 * The signed-in shell: a top bar with the sections, then the page.
 * `title` overrides the heading taken from the route; pass null for a page
 * that renders its own.
 */
export default function Layout({ children, title }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const isMobile = useIsMobile(900)
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  const heading = title === undefined ? (PAGE_LABELS[location.pathname] || 'Dashboard') : title
  const initials = (user?.fullName || 'U').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()
  const showLinks = !isMobile || menuOpen

  const signOut = () => { logout(); navigate('/') }

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-primary)', fontFamily: font }}>
      <header style={{ position: 'sticky', top: 0, zIndex: 10, background: 'var(--bg-header)', borderBottom: '1px solid var(--border)' }}>
        <div style={{ maxWidth: 1240, margin: '0 auto', padding: '0 20px', minHeight: 64, display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '0 28px' }}>
          <NavLink to="/dashboard" style={{ display: 'flex', alignItems: 'center', gap: '8px', fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: '21px', color: 'var(--text-primary)', textDecoration: 'none', padding: '14px 0' }}>
            <img src={logo} alt="" width="32" height="32" style={{ display: 'block' }} />
            <span>Agro<span style={{ color: 'var(--accent-lime)' }}>Master</span></span>
          </NavLink>

          {isMobile && (
            <button
              type="button"
              onClick={() => setMenuOpen(o => !o)}
              aria-expanded={menuOpen}
              aria-controls="app-nav"
              aria-label={menuOpen ? 'Close menu' : 'Open menu'}
              style={{ marginLeft: 'auto', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-primary)', padding: 10, display: 'flex' }}
            >
              <MenuIcon open={menuOpen} />
            </button>
          )}

          {showLinks && (
            <nav
              id="app-nav"
              aria-label="Main"
              style={{
                display: 'flex', flexDirection: isMobile ? 'column' : 'row', gap: isMobile ? 2 : 4,
                flex: isMobile ? '1 0 100%' : '1 1 auto', padding: isMobile ? '0 0 12px' : 0,
              }}
            >
              {NAV_ITEMS.map(item => (
                <NavLink
                  key={item.path}
                  to={item.path}
                  onClick={() => setMenuOpen(false)}
                  style={({ isActive }) => ({
                    padding: '8px 12px',
                    borderRadius: '8px',
                    background: isActive ? 'var(--bg-tile)' : 'transparent',
                    color: isActive ? 'var(--text-primary)' : 'var(--text-muted)',
                    fontSize: '14px',
                    fontWeight: isActive ? 600 : 500,
                    textDecoration: 'none',
                    whiteSpace: 'nowrap',
                  })}
                >
                  {item.label}
                </NavLink>
              ))}
            </nav>
          )}

          {showLinks && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: isMobile ? '0 0 14px' : 0, flex: isMobile ? '1 0 100%' : '0 0 auto' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <span aria-hidden="true" style={{ width: 32, height: 32, borderRadius: '50%', background: 'var(--bg-tile)', color: 'var(--accent-lime)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '12px', fontWeight: 700, flexShrink: 0 }}>{initials}</span>
                <span style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.25 }}>
                  <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>{user?.fullName || 'Farmer'}</span>
                  {user?.city && <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{user.city}</span>}
                </span>
              </div>
              <button
                type="button"
                onClick={signOut}
                style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'transparent', border: '1px solid var(--border)', borderRadius: 8, padding: '7px 12px', cursor: 'pointer', color: 'var(--text-muted)', fontFamily: font, fontSize: '13px' }}
              >
                <LogoutIcon />
                Sign out
              </button>
            </div>
          )}
        </div>
      </header>

      <main className="page-content" style={{ maxWidth: 1240, margin: '0 auto', padding: '28px 20px 56px' }}>
        {heading && (
          <h1 style={{ fontFamily: font, fontWeight: 700, fontSize: '24px', color: 'var(--text-primary)', margin: '0 0 20px' }}>{heading}</h1>
        )}
        {children}
      </main>
    </div>
  )
}
