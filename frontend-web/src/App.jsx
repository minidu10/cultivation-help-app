import { lazy, Suspense } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext'
import LandingPage from './pages/LandingPage'

// Only the landing page is bundled up front - it is where most visitors
// arrive. Everything else is fetched when its route is first opened, which
// keeps the initial download small on slow rural connections. Recharts in
// particular is heavy and is only needed once someone reaches the dashboard.
const LoginPage          = lazy(() => import('./pages/LoginPage'))
const RegisterPage       = lazy(() => import('./pages/RegisterPage'))
const ForgotPasswordPage = lazy(() => import('./pages/ForgotPasswordPage'))
const DashboardPage      = lazy(() => import('./pages/DashboardPage'))
const CropsPage          = lazy(() => import('./pages/CropsPage'))
const CropManagementPage = lazy(() => import('./pages/CropManagementPage'))
const ExpensesPage       = lazy(() => import('./pages/ExpensesPage'))
const HarvestsPage       = lazy(() => import('./pages/HarvestsPage'))
const AIAdvisorPage      = lazy(() => import('./pages/AIAdvisorPage'))
const SettingsPage       = lazy(() => import('./pages/SettingsPage'))
const ProfilePage        = lazy(() => import('./pages/ProfilePage'))

function PrivateRoute({ children }) {
  const { user } = useAuth()
  const token = localStorage.getItem('token')
  return user && token ? children : <Navigate to="/" />
}

/** Shown only while a route chunk is downloading - usually a few hundred ms. */
function RouteFallback() {
  return (
    <div style={{
      minHeight: '100vh',
      background: 'var(--bg-primary)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '12px',
    }}>
      <div style={{
        width: 18, height: 18, borderRadius: '50%',
        border: '2px solid var(--border)',
        borderTopColor: 'var(--accent-lime)',
        animation: 'agro-spin 0.7s linear infinite',
      }} />
      <span style={{ fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, sans-serif', fontSize: '14px', color: 'var(--text-muted)' }}>
        Loading…
      </span>
      <style>{'@keyframes agro-spin { to { transform: rotate(360deg) } }'}</style>
    </div>
  )
}

function App() {
  return (
    <Suspense fallback={<RouteFallback />}>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/dashboard" element={
          <PrivateRoute><DashboardPage /></PrivateRoute>
        }/>
        <Route path="/crops" element={
          <PrivateRoute><CropsPage /></PrivateRoute>
        }/>
        <Route path="/crops/:id" element={
          <PrivateRoute><CropManagementPage /></PrivateRoute>
        }/>
        <Route path="/expenses" element={
          <PrivateRoute><ExpensesPage /></PrivateRoute>
        }/>
        <Route path="/harvests" element={
          <PrivateRoute><HarvestsPage /></PrivateRoute>
        }/>
        <Route path="/ai-advisor" element={
          <PrivateRoute><AIAdvisorPage /></PrivateRoute>
        }/>
        <Route path="/settings" element={
          <PrivateRoute><SettingsPage /></PrivateRoute>
        }/>
        <Route path="/profile" element={
          <PrivateRoute><ProfilePage /></PrivateRoute>
        }/>
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Suspense>
  )
}

export default App
