import { NavLink } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useNavigate } from 'react-router-dom'
import logo from '../assets/logo.png'

const navItems = [
  { path: '/dashboard', icon: '📊', label: 'Dashboard' },
  { path: '/crops', icon: '🌾', label: 'My Crops' },
  { path: '/expenses', icon: '💰', label: 'Expenses' },
  { path: '/harvests', icon: '🌽', label: 'Harvests' },
]

export default function Sidebar() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <aside className="w-64 min-h-screen bg-green-900 text-white
                      flex flex-col fixed left-0 top-0">

      {/* Logo */}
      <div className="flex items-center gap-3 px-6 py-5
                      border-b border-green-700">
        <img src={logo} alt="logo" className="w-8 h-8" />
        <span className="font-bold text-lg">Cultivation</span>
      </div>

      {/* Nav links */}
      <nav className="flex-1 px-4 py-6 space-y-1">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm
               font-medium transition-colors ${
                isActive
                  ? 'bg-green-600 text-white'
                  : 'text-green-200 hover:bg-green-800'
              }`
            }
          >
            <span>{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* User info + logout */}
      <div className="px-6 py-4 border-t border-green-700">
        <p className="text-sm text-green-300 mb-1">Logged in as</p>
        <p className="text-sm font-medium truncate">{user?.fullName}</p>
        <button
          onClick={handleLogout}
          className="mt-3 text-xs text-green-400
                     hover:text-red-400 transition-colors"
        >
          Sign out →
        </button>
      </div>
    </aside>
  )
}