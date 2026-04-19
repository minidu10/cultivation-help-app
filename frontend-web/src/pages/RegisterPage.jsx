import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'
import logo from '../assets/logo.png'

export default function RegisterPage() {
  const [form, setForm] = useState({
    fullName: '',
    email: '',
    password: '',
    confirmPassword: '',
    phone: '',
    city: '',
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const { login } = useAuth()
  const navigate = useNavigate()

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    // Check passwords match
    if (form.password !== form.confirmPassword) {
      setError('Passwords do not match')
      return
    }

    // Check password length
    if (form.password.length < 8) {
      setError('Password must be at least 8 characters')
      return
    }

    setLoading(true)
    try {
      const response = await api.post('/auth/register', {
        fullName: form.fullName,
        email: form.email,
        password: form.password,
        phone: form.phone,
        city: form.city,
      })

      const {
        token,
        fullName,
        email,
        city,
        themePreference,
        desktopMode,
      } = response.data
      login({ fullName, email, city, themePreference, desktopMode }, token)
      navigate('/dashboard')

    } catch (err) {
      const msg = err.response?.data?.message
      setError(msg || 'Registration failed. Email may already be used.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-linear-to-br from-green-50
                    to-green-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-lg p-8
                      w-full max-w-md">

        {/* Logo */}
        <div className="flex items-center justify-center gap-3 mb-6">
          <img src={logo} alt="logo" className="w-10 h-10" />
          <h1 className="text-2xl font-bold text-green-800">
            Cultivation Help
          </h1>
        </div>

        <h2 className="text-xl font-semibold text-gray-700 mb-6">
          Create your account
        </h2>

        {/* Error */}
        {error && (
          <div className="bg-red-50 text-red-600 text-sm px-4 py-3
                          rounded-lg mb-4 border border-red-200">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">

          {/* Full name */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              Full Name *
            </label>
            <input
              name="fullName"
              value={form.fullName}
              onChange={handleChange}
              required
              placeholder="e.g. Kamal Perera"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          {/* Email */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              Email *
            </label>
            <input
              name="email"
              type="email"
              value={form.email}
              onChange={handleChange}
              required
              placeholder="farmer@example.com"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          {/* Phone */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              Phone
            </label>
            <input
              name="phone"
              value={form.phone}
              onChange={handleChange}
              placeholder="e.g. 0771234567"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          {/* City */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              City
            </label>
            <input
              name="city"
              value={form.city}
              onChange={handleChange}
              placeholder="e.g. Ratnapura"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              Password *
            </label>
            <input
              name="password"
              type="password"
              value={form.password}
              onChange={handleChange}
              required
              placeholder="Min 8 characters"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          {/* Confirm password */}
          <div>
            <label className="block text-sm font-medium
                              text-gray-600 mb-1">
              Confirm Password *
            </label>
            <input
              name="confirmPassword"
              type="password"
              value={form.confirmPassword}
              onChange={handleChange}
              required
              placeholder="Repeat your password"
              className="w-full border border-gray-300 rounded-lg
                         px-4 py-2.5 text-sm focus:outline-none
                         focus:ring-2 focus:ring-green-400"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-green-600 hover:bg-green-700
                       text-white font-semibold py-2.5 rounded-lg
                       transition-colors disabled:opacity-50
                       disabled:cursor-not-allowed mt-2"
          >
            {loading ? 'Creating account...' : 'Create Account'}
          </button>
        </form>

        {/* Login link */}
        <p className="text-center text-sm text-gray-500 mt-6">
          Already have an account?{' '}
          <Link to="/login"
                className="text-green-600 font-medium hover:underline">
            Sign in here
          </Link>
        </p>
      </div>
    </div>
  )
}