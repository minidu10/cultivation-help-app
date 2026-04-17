import { useEffect, useState } from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend, PieChart, Pie, Cell
} from 'recharts'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import { getCrops, getDueReminders, getProfitLoss, updateCropReminder } from '../api/crops'
import { getCropInsights } from '../api/crops'
import {
  getCurrentWeather,
  getCurrentWeatherByLocation,
  getWeatherForecast,
} from '../api/weather'

const COLORS = ['#16a34a', '#dc2626', '#2563eb', '#d97706', '#7c3aed']

export default function DashboardPage() {
  const [crops, setCrops] = useState([])
  const [profitData, setProfitData] = useState([])
  const [loading, setLoading] = useState(true)
  const [insights, setInsights] = useState({})
  const [loadingInsights, setLoadingInsights] = useState(false)
  const [weatherCurrent, setWeatherCurrent] = useState(null)
  const [weatherForecast, setWeatherForecast] = useState([])
  const [loadingWeather, setLoadingWeather] = useState(true)
  const [weatherError, setWeatherError] = useState('')
  const [cropWeatherById, setCropWeatherById] = useState({})
  const [dueReminders, setDueReminders] = useState([])

  useEffect(() => {
    loadDashboard()
    loadWeather()
    loadDueReminders()
  }, [])

  const fetchWeatherByCoords = async (lat, lon) => {
    const [currentRes, forecastRes] = await Promise.all([
      getCurrentWeather(lat, lon),
      getWeatherForecast(lat, lon, 5),
    ])

    setWeatherCurrent(currentRes.data)
    setWeatherForecast(forecastRes.data?.items ?? [])
  }

  const loadWeather = async () => {
    setLoadingWeather(true)
    setWeatherError('')

    // Fallback to Colombo if location permission is blocked.
    const fallbackLat = 6.9271
    const fallbackLon = 79.8612

    try {
      if (!navigator.geolocation) {
        await fetchWeatherByCoords(fallbackLat, fallbackLon)
        return
      }

      await new Promise((resolve) => {
        navigator.geolocation.getCurrentPosition(
          async (position) => {
            try {
              const { latitude, longitude } = position.coords
              await fetchWeatherByCoords(latitude, longitude)
              resolve()
            } catch {
              try {
                await fetchWeatherByCoords(fallbackLat, fallbackLon)
              } catch {
                setWeatherError('Unable to load weather now.')
              }
              resolve()
            }
          },
          async () => {
            try {
              await fetchWeatherByCoords(fallbackLat, fallbackLon)
            } catch {
              setWeatherError('Unable to load weather now.')
            }
            resolve()
          },
          { enableHighAccuracy: false, timeout: 7000, maximumAge: 300000 }
        )
      })
    } finally {
      setLoadingWeather(false)
    }
  }

  const loadDashboard = async () => {
    try {
      const cropsRes = await getCrops()
      const cropList = cropsRes.data
      setCrops(cropList)
      loadCropWeather(cropList)

      // Load profit/loss for each crop
      const plData = await Promise.all(
        cropList.map(async (crop) => {
          try {
            const pl = await getProfitLoss(crop.id)
            return {
              cropId: crop.id,
              name: crop.name,
              fieldLocation: crop.fieldLocation,
              expenses: Number(pl.data.totalExpenses),
              revenue: Number(pl.data.totalRevenue),
              profit: Number(pl.data.netProfit),
              result: pl.data.result,
            }
          } catch {
            return {
              cropId: crop.id,
              name: crop.name,
              fieldLocation: crop.fieldLocation,
              expenses: 0,
              revenue: 0,
              profit: 0,
              result: 'N/A',
            }
          }
        })
      )
      setProfitData(plData)
      loadInsights(plData, cropList)
    } catch (err) {
      console.error('Dashboard load failed:', err)
    } finally {
      setLoading(false)
    }
  }

  const loadCropWeather = async (cropList) => {
    const weatherEntries = await Promise.all(
      cropList.map(async (crop) => {
        if (!crop.fieldLocation || !crop.fieldLocation.trim()) {
          return [crop.id, null]
        }

        try {
          const res = await getCurrentWeatherByLocation(crop.fieldLocation)
          return [crop.id, res.data]
        } catch {
          return [crop.id, null]
        }
      })
    )

    setCropWeatherById(Object.fromEntries(weatherEntries))
  }
  const loadInsights = async (plData, cropList) => {
    setLoadingInsights(true)
    const results = {}
    const cropMapByName = Object.fromEntries(cropList.map((c) => [c.name, c]))

    for (const crop of plData) {
      const cropMeta = cropMapByName[crop.name]
      if (cropMeta && cropMeta.aiInsightsEnabled === false) {
        results[crop.name] = '__AI_OFF__'
        continue
      }

      try {
        const res = await getCropInsights({
          crop_name: crop.name,
          total_expenses: crop.expenses,
          total_revenue: crop.revenue,
          net_profit: crop.profit,
          status: crop.result,
        })
        results[crop.name] = res.data.insights
      } catch {
        results[crop.name] = null
      }
    }

    setInsights(results)
    setLoadingInsights(false)
  }

  const loadDueReminders = async () => {
    try {
      const res = await getDueReminders()
      setDueReminders(res.data)
    } catch {
      setDueReminders([])
    }
  }

  const markReminderDone = async (reminderId) => {
    const reminder = dueReminders.find((item) => item.id === reminderId)
    if (!reminder) return

    try {
      await updateCropReminder(reminder.cropId, reminderId, { completed: true })
      setDueReminders((prev) => prev.filter((item) => item.id !== reminderId))
    } catch {
      // Ignore to keep dashboard flow smooth when reminder update fails.
    }
  }

  // Summary totals
  const totalRevenue = profitData.reduce((s, d) => s + d.revenue, 0)
  const totalExpenses = profitData.reduce((s, d) => s + d.expenses, 0)
  const netProfit = totalRevenue - totalExpenses
  const activeCrops = crops.filter(
    (c) => c.status !== 'HARVESTED' && c.status !== 'FAILED'
  ).length

  const weatherAlerts = []
  if ((weatherCurrent?.temperatureC ?? 0) >= 34) {
    weatherAlerts.push('High heat today. Check irrigation timing and mulch moisture retention.')
  }
  if ((weatherCurrent?.rainMm ?? 0) > 0) {
    weatherAlerts.push('Rain has started. Avoid pesticide spraying until conditions clear.')
  }
  if (weatherForecast.some((f) => (f.rainChancePercent ?? 0) >= 60)) {
    weatherAlerts.push('Strong rain chance in forecast. Plan drainage and postpone field spraying.')
  }

  // Pie chart data — expense vs revenue
  const pieData = [
    { name: 'Total Revenue', value: totalRevenue },
    { name: 'Total Expenses', value: totalExpenses },
  ]

  const renderInsightContent = (rawInsight) => {
    const lines = rawInsight
      .split('\n')
      .map((line) => line.replace(/\*\*/g, '').trim())
      .filter((line) => line.length > 0)

    return lines.map((line, idx) => {
      if (line.startsWith('* ')) {
        return (
          <div key={idx} className="flex items-start gap-2 text-sm text-gray-700">
            <span className="mt-1 text-green-600">•</span>
            <p className="leading-7">{line.replace(/^\*\s+/, '')}</p>
          </div>
        )
      }

      if (/^\d+\./.test(line)) {
        return (
          <p key={idx} className="text-sm font-semibold text-gray-800 leading-7 mt-1">
            {line}
          </p>
        )
      }

      return (
        <p key={idx} className="text-sm text-gray-700 leading-7">
          {line}
        </p>
      )
    })
  }

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <p className="text-gray-400 animate-pulse">Loading dashboard...</p>
        </div>
      </Layout>
    )
  }

  return (
    <Layout>
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-500 mt-1">
          Your farm performance at a glance
        </p>
      </div>

      {/* Weather */}
      <div className="bg-white rounded-xl border border-gray-200 p-5 mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base font-semibold text-gray-700">
            Weather Overview
          </h2>
          <button
            onClick={loadWeather}
            className="text-sm text-green-700 hover:text-green-800 font-medium"
          >
            Refresh
          </button>
        </div>

        {loadingWeather ? (
          <p className="text-gray-400 text-sm animate-pulse">Loading weather...</p>
        ) : weatherError ? (
          <p className="text-red-500 text-sm">{weatherError}</p>
        ) : weatherCurrent ? (
          <>
            <div className="flex flex-wrap items-center gap-4 mb-4">
              {weatherCurrent.iconUrl && (
                <img
                  src={weatherCurrent.iconUrl}
                  alt={weatherCurrent.description || 'weather icon'}
                  className="w-14 h-14"
                />
              )}
              <div>
                <p className="text-lg font-semibold text-gray-800">
                  {weatherCurrent.location || 'Current Location'}
                </p>
                <p className="text-sm text-gray-500 capitalize">
                  {weatherCurrent.description || 'No description'}
                </p>
              </div>
              <div className="ml-auto grid grid-cols-2 gap-3 text-sm">
                <p><span className="text-gray-500">Temp:</span> {Math.round(weatherCurrent.temperatureC ?? 0)}°C</p>
                <p><span className="text-gray-500">Feels:</span> {Math.round(weatherCurrent.feelsLikeC ?? 0)}°C</p>
                <p><span className="text-gray-500">Humidity:</span> {weatherCurrent.humidity ?? 0}%</p>
                <p><span className="text-gray-500">Wind:</span> {weatherCurrent.windSpeed ?? 0} m/s</p>
              </div>
            </div>

            {weatherForecast.length > 0 && (
              <div className="grid grid-cols-2 md:grid-cols-5 gap-2 mb-4">
                {weatherForecast.map((item, idx) => (
                  <div key={idx} className="bg-gray-50 rounded-lg p-3 text-center">
                    <p className="text-xs text-gray-500 mb-1">{item.dateTime?.slice(5, 16) || '-'}</p>
                    {item.iconUrl && (
                      <img src={item.iconUrl} alt={item.description || 'forecast icon'} className="w-10 h-10 mx-auto" />
                    )}
                    <p className="text-sm font-medium text-gray-700">{Math.round(item.temperatureC ?? 0)}°C</p>
                    <p className="text-xs text-blue-600">Rain {item.rainChancePercent ?? 0}%</p>
                  </div>
                ))}
              </div>
            )}

            {weatherAlerts.length > 0 && (
              <div className="space-y-2">
                {weatherAlerts.map((alert, idx) => (
                  <p key={idx} className="text-sm bg-amber-50 border border-amber-200 text-amber-700 rounded-lg px-3 py-2">
                    {alert}
                  </p>
                ))}
              </div>
            )}
          </>
        ) : (
          <p className="text-gray-400 text-sm">No weather data available.</p>
        )}
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard
          title="Total Revenue"
          value={`Rs. ${totalRevenue.toLocaleString()}`}
          sub="All crops"
          color="green"
        />
        <StatCard
          title="Total Expenses"
          value={`Rs. ${totalExpenses.toLocaleString()}`}
          sub="All crops"
          color="red"
        />
        <StatCard
          title="Net Profit"
          value={`Rs. ${netProfit.toLocaleString()}`}
          sub={netProfit >= 0 ? '✅ Profitable' : '❌ Loss'}
          color={netProfit >= 0 ? 'green' : 'red'}
        />
        <StatCard
          title="Active Crops"
          value={activeCrops}
          sub={`${crops.length} total`}
          color="blue"
        />
      </div>

      <div className="bg-white rounded-xl border border-gray-200 p-5 mb-8">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-semibold text-gray-700">Today Reminders</h2>
          <button
            onClick={loadDueReminders}
            className="text-xs text-green-700 hover:text-green-800 font-medium"
          >
            Refresh
          </button>
        </div>
        {dueReminders.length === 0 ? (
          <p className="text-sm text-gray-400">No due reminders right now.</p>
        ) : (
          <div className="space-y-2">
            {dueReminders.map((item) => (
              <div key={item.id} className="flex items-center justify-between gap-3 border border-gray-100 rounded-lg p-3">
                <div>
                  <p className="text-sm font-semibold text-gray-800">{item.title}</p>
                  <p className="text-xs text-gray-500">
                    {item.type?.replaceAll('_', ' ')} • {item.reminderAt?.replace('T', ' ').slice(0, 16)}
                  </p>
                </div>
                <button
                  onClick={() => markReminderDone(item.id)}
                  className="text-xs px-2 py-1 rounded bg-green-100 text-green-700 hover:bg-green-200"
                >
                  Done
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">

        {/* Bar chart — revenue vs expenses per crop */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Revenue vs Expenses by Crop
          </h2>
          {profitData.length === 0 ? (
            <p className="text-gray-400 text-sm text-center py-10">
              No crop data yet — add crops and expenses to see charts
            </p>
          ) : (
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={profitData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip
                  formatter={(value) => `Rs. ${value.toLocaleString()}`}
                />
                <Legend />
                <Bar dataKey="revenue" name="Revenue"
                     fill="#16a34a" radius={[4, 4, 0, 0]} />
                <Bar dataKey="expenses" name="Expenses"
                     fill="#dc2626" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Pie chart — revenue vs expenses overall */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Revenue vs Expenses Overview
          </h2>
          {totalRevenue === 0 && totalExpenses === 0 ? (
            <p className="text-gray-400 text-sm text-center py-10">
              No financial data yet
            </p>
          ) : (
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={pieData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={4}
                  dataKey="value"
                  label={({ name, percent }) =>
                    `${name} ${(percent * 100).toFixed(0)}%`
                  }
                >
                  {pieData.map((_, index) => (
                    <Cell key={index} fill={COLORS[index]} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value) => `Rs. ${value.toLocaleString()}`}
                />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* Crop profit/loss table */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <h2 className="text-base font-semibold text-gray-700 mb-4">
          Crop Performance
        </h2>
        {profitData.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-6">
            No crops added yet
          </p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 border-b border-gray-100">
                <th className="pb-2 font-medium">Crop</th>
                <th className="pb-2 font-medium">Revenue</th>
                <th className="pb-2 font-medium">Expenses</th>
                <th className="pb-2 font-medium">Net Profit</th>
                <th className="pb-2 font-medium">Result</th>
              </tr>
            </thead>
            <tbody>
              {profitData.map((row, i) => (
                <tr key={i}
                    className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="py-3 font-medium text-gray-800">
                    {row.name}
                  </td>
                  <td className="py-3 text-green-600">
                    Rs. {row.revenue.toLocaleString()}
                  </td>
                  <td className="py-3 text-red-500">
                    Rs. {row.expenses.toLocaleString()}
                  </td>
                  <td className="py-3 font-semibold">
                    Rs. {row.profit.toLocaleString()}
                  </td>
                  <td className="py-3">
                    <span className={`px-2 py-1 rounded-full text-xs
                      font-medium ${
                        row.result === 'PROFIT'
                          ? 'bg-green-100 text-green-700'
                          : row.result === 'LOSS'
                          ? 'bg-red-100 text-red-700'
                          : 'bg-gray-100 text-gray-500'
                      }`}>
                      {row.result}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
      {/* AI Insights */}
     {profitData.length > 0 && (
        <div className="mt-6">
          <div className="flex items-center gap-2 mb-4">
            <h2 className="text-base font-semibold text-gray-700">
              🤖 AI Insights
            </h2>
            <span className="text-xs bg-green-100 text-green-700
                            px-2 py-1 rounded-full font-medium">
              Powered by Groq
            </span>
          </div>

          {loadingInsights ? (
            <div className="bg-white rounded-xl border border-gray-200
                            p-8 text-center">
              <p className="text-gray-400 animate-pulse text-sm">
                🤖 AI is analysing your crops...
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {profitData.map((crop, i) => (
                <div key={i}
                    className={`bg-white rounded-xl border border-gray-200 p-5 ${
                      profitData.length === 1 ? 'md:col-span-2' : ''
                    }`}>
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-lg">🌾</span>
                    <h3 className="font-semibold text-gray-800">
                      {crop.name}
                    </h3>
                    <span className={`ml-auto text-xs px-2 py-1
                                    rounded-full font-medium ${
                      crop.result === 'PROFIT'
                        ? 'bg-green-100 text-green-700'
                        : 'bg-red-100 text-red-700'
                    }`}>
                      {crop.result}
                    </span>
                  </div>

                  <div className="mb-3 bg-sky-50 border border-sky-100 rounded-lg p-3">
                    <p className="text-xs text-sky-700 font-medium mb-1">Field Weather</p>
                    {cropWeatherById[crop.cropId] ? (
                      <div className="flex items-center gap-2 text-sm text-sky-900">
                        {cropWeatherById[crop.cropId].iconUrl && (
                          <img
                            src={cropWeatherById[crop.cropId].iconUrl}
                            alt={cropWeatherById[crop.cropId].description || 'weather icon'}
                            className="w-8 h-8"
                          />
                        )}
                        <div>
                          <p className="font-medium">
                            {Math.round(cropWeatherById[crop.cropId].temperatureC ?? 0)}°C
                            {' '}
                            {cropWeatherById[crop.cropId].description || ''}
                          </p>
                          <p className="text-xs text-sky-700">
                            {cropWeatherById[crop.cropId].location || crop.fieldLocation || 'Field location'}
                          </p>
                        </div>
                      </div>
                    ) : (
                      <p className="text-xs text-sky-700">
                        Weather not available for {crop.fieldLocation || 'this field location'}.
                      </p>
                    )}
                  </div>

                  {insights[crop.name] && insights[crop.name] !== '__AI_OFF__' ? (
                    <div className="rounded-lg border border-gray-100 bg-gray-50/70 p-3 space-y-2 wrap-break-word">
                      {renderInsightContent(insights[crop.name])}
                    </div>
                  ) : insights[crop.name] === '__AI_OFF__' ? (
                    <p className="text-sm text-amber-700 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2">
                      AI off by farmer for this crop.
                    </p>
                  ) : (
                    <p className="text-sm text-gray-400">
                      No insights available
                    </p>
                  )}

                  <div className="mt-4 pt-3 border-t border-gray-100
                                  grid grid-cols-3 gap-2 text-center">
                    <div>
                      <p className="text-xs text-gray-400">Revenue</p>
                      <p className="text-sm font-semibold text-green-600">
                        Rs. {crop.revenue.toLocaleString()}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400">Expenses</p>
                      <p className="text-sm font-semibold text-red-500">
                        Rs. {crop.expenses.toLocaleString()}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400">Profit</p>
                      <p className={`text-sm font-semibold ${
                        crop.profit >= 0
                          ? 'text-green-700' : 'text-red-600'
                      }`}>
                        Rs. {crop.profit.toLocaleString()}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </Layout>
  )
}