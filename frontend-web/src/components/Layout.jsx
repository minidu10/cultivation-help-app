import { useEffect, useState } from 'react'
import { NavLink, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import {
  BoxIcon, ChatIcon, CloseIcon, GearIcon, GridIcon, LogoutIcon, MenuIcon, ReceiptIcon, SproutIcon,
} from './Icons'
import Avatar from './Avatar'
import logo from '../assets/logo.png'

const NAV_ITEMS = [
  { path: '/dashboard',  label: 'Dashboard',  Icon: GridIcon },
  { path: '/crops',      label: 'My Crops',   Icon: SproutIcon },
  { path: '/expenses',   label: 'Expenses',   Icon: ReceiptIcon },
  { path: '/harvests',   label: 'Harvests',   Icon: BoxIcon },
  { path: '/ai-advisor', label: 'AI Advisor', Icon: ChatIcon },
  { path: '/settings',   label: 'Settings',   Icon: GearIcon },
]

const PAGE_LABELS = {
  '/dashboard': 'Dashboard', '/crops': 'My Crops', '/expenses': 'Expenses',
  '/harvests': 'Harvests', '/ai-advisor': 'AI Advisor',
  '/settings': 'Settings', '/profile': 'Profile',
}

function pageLabel(pathname) {
  if (PAGE_LABELS[pathname]) return PAGE_LABELS[pathname]
  if (pathname.startsWith('/crops/')) return 'My Crops'
  return 'Dashboard'
}

/**
 * The signed-in shell: the sections in a sidebar, and a top bar with the
 * page name and the farmer. The sidebar is hidden and slides in from the menu
 * button. Pass `title={null}` for a page that renders its own heading; the
 * top bar then shows the section name without making it the page's heading.
 */
export default function Layout({ children, title }) {
  const [menuOpen, setMenuOpen] = useState(false)
  const isMobile = useIsMobile(1024)
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  const label = title || pageLabel(location.pathname)

  useEffect(() => {
    if (!menuOpen) return undefined
    const onKey = (e) => { if (e.key === 'Escape') setMenuOpen(false) }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [menuOpen])

  const signOut = () => { logout(); navigate('/') }

  return (
    <div className="app-shell">
      {menuOpen && <div className="app-backdrop" onClick={() => setMenuOpen(false)} />}

      <aside id="app-sidebar" className={`app-sidebar${menuOpen ? ' open' : ''}`}>
        <div className="app-brand">
          <NavLink to="/dashboard" onClick={() => setMenuOpen(false)} style={{ display: 'flex', alignItems: 'center', gap: '10px', textDecoration: 'none', color: 'var(--text-primary)', fontWeight: 700, fontSize: '20px' }}>
            <img src={logo} alt="" width="32" height="32" style={{ display: 'block' }} />
            <span>Agro<span style={{ color: 'var(--accent-lime)' }}>Master</span></span>
          </NavLink>
          <button type="button" className="icon-btn" onClick={() => setMenuOpen(false)} aria-label="Close menu" style={{ marginLeft: 'auto' }}>
            <CloseIcon />
          </button>
        </div>

        <nav aria-label="Main" className="app-nav">
          {NAV_ITEMS.map((item) => (
            <NavLink key={item.path} to={item.path} onClick={() => setMenuOpen(false)} className="side-link">
              <item.Icon />
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="app-sidebar-foot">
          <button type="button" className="signout-btn" onClick={signOut}>
            <LogoutIcon size={18} />
            Sign out
          </button>
        </div>
      </aside>

      <div className="app-main">
        <header className="app-topbar">
          <button
            type="button"
            className="icon-btn"
            onClick={() => setMenuOpen(true)}
            aria-expanded={menuOpen}
            aria-controls="app-sidebar"
            aria-label="Open menu"
            style={{ marginLeft: '-8px' }}
          >
            <MenuIcon size={22} />
          </button>
          {title === null
            ? <span className="app-topbar-title">{label}</span>
            : <h1 className="app-topbar-title">{label}</h1>}
          <NavLink to="/profile" className="user-chip" aria-label={`Profile of ${user?.fullName || 'you'}`}>
            <Avatar className="user-avatar" name={user?.fullName} version={user?.avatarVersion} />
            {!isMobile && (
              <span style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.25, minWidth: 0 }}>
                <span style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-primary)' }}>{user?.fullName || 'Farmer'}</span>
                {user?.city && <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{user.city}</span>}
              </span>
            )}
          </NavLink>
        </header>

        <main className="page-content" style={{ width: '100%', maxWidth: '1240px', margin: '0 auto', padding: '28px 32px 56px', boxSizing: 'border-box' }}>
          {children}
        </main>
      </div>
    </div>
  )
}
