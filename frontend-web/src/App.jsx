import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import CropsPage from './pages/CropsPage'
import CropManagementPage from './pages/CropManagementPage'
import ExpensesPage from './pages/ExpensesPage'
import HarvestsPage from './pages/HarvestsPage'
import RegisterPage from './pages/RegisterPage'
import AIAdvisorPage from './pages/AIAdvisorPage'
import SettingsPage from './pages/SettingsPage'

function PrivateRoute({ children }) {
  const { user } = useAuth()
  const token = localStorage.getItem('token')
  return user && token ? children : <Navigate to="/login" />
}

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
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
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  )
}

export default App