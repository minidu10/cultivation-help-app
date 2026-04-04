import { NavLink } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useNavigate } from 'react-router-dom'
import logo from '../assets/logo.png'

const navItems = [
  { path: '/dashboard', icon: '📊', label: 'Dashboard' },
  { path: '/crops', icon: '🌾', label: 'My Crops' },
  { path: '/expenses', icon: '💰', label: 'Expenses' },
  { path: '/harvests', icon: '🌽', label: 'Harvests' },
   { path: '/ai-advisor', icon: '🤖', label: 'AI Advisor' },
]

export default function Sidebar({ isOpen, setIsOpen }) {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <aside className={`w-64 min-h-screen bg-white text-gray-800
                      border-r border-gray-200 shadow-xl
                      flex flex-col fixed left-0 top-0 z-50
                      transition-transform duration-300 ease-in-out
                      ${isOpen ? 'translate-x-0' : '-translate-x-full'}`}>

      {/* Logo and Close Button */}
      <div className="flex items-center justify-between px-6 py-5
                      border-b border-gray-200">
        <div className="flex items-center gap-3">
          <img src={logo} alt="logo" className="w-8 h-8" />
          <span className="font-bold text-lg text-gray-900">Cultivation</span>
        </div>
        <button 
          onClick={() => setIsOpen(false)}
          className="text-gray-500 hover:text-gray-800 focus:outline-none"
          aria-label="Close sidebar"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      {/* Nav links */}
      <nav className="flex-1 px-4 py-6 space-y-1">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            onClick={() => setIsOpen(false)}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm
               font-medium transition-colors ${
                isActive
                  ? 'bg-gray-100 text-gray-900 shadow-sm'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`
            }
          >
            <span>{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* User info + logout */}
      <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
        <p className="text-sm text-gray-500 mb-1">Logged in as</p>
        <p className="text-sm font-medium text-gray-900 truncate">{user?.fullName}</p>
        <button
          onClick={handleLogout}
          className="mt-3 text-xs text-gray-500 font-medium
                     hover:text-red-600 transition-colors"
        >
          Sign out →
        </button>
      </div>
    </aside>
  )
}