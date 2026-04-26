import { useEffect, useState } from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend, PieChart, Pie, Cell
} from 'recharts'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import { getCrops, getDueReminders, getProfitLoss, updateCropReminder, getCropInsights } from '../api/crops'
import {
  getCurrentWeather, getCurrentWeatherByLocation,
  getWeatherForecast, getWeatherForecastByLocation,
} from '../api/weather'

const CHART_COLORS = ['#4ade80', '#f87171', '#60a5fa', '#f59e0b', '#c084fc']

const CUSTOM_TOOLTIP_STYLE = {
  background: 'var(--bg-card)',
  border: '1px solid rgba(74,222,128,0.2)',
  borderRadius: '10px',
  fontFamily: 'Inter, sans-serif',
  fontSize: '13px',
  color: 'var(--text-primary)',
}

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload || !payload.length) return null
  return (
    <div style={CUSTOM_TOOLTIP_STYLE}>
      <p style={{ padding: '8px 12px 4px', fontFamily: 'Space Grotesk', fontWeight: 700, borderBottom: '1px solid rgba(74,222,128,0.1)', marginBottom: '4px' }}>{label}</p>
      {payload.map((p, i) => (
        <p key={i} style={{ padding: '2px 12px', color: p.color }}>
          {p.name}: Rs. {Number(p.value).toLocaleString()}
        </p>
      ))}
      <div style={{ height: 4 }} />
    </div>
  )
}

export default function DashboardPage() {
  const { user } = useAuth()
  const isMobile = useIsMobile()
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
    const fallbackLat = 6.9271, fallbackLon = 79.8612
    const savedCity = user?.city?.trim()
    try {
      if (savedCity) {
        const [currentRes, forecastRes] = await Promise.all([
          getCurrentWeatherByLocation(savedCity),
          getWeatherForecastByLocation(savedCity, 5),
        ])
        setWeatherCurrent(currentRes.data)
        setWeatherForecast(forecastRes.data?.items ?? [])
        return
      }
      if (!navigator.geolocation) { await fetchWeatherByCoords(fallbackLat, fallbackLon); return }
      await new Promise((resolve) => {
        navigator.geolocation.getCurrentPosition(
          async (position) => {
            try { await fetchWeatherByCoords(position.coords.latitude, position.coords.longitude) }
            catch { try { await fetchWeatherByCoords(fallbackLat, fallbackLon) } catch { setWeatherError('Unable to load weather now.') } }
            resolve()
          },
          async () => {
            try { await fetchWeatherByCoords(fallbackLat, fallbackLon) } catch { setWeatherError('Unable to load weather now.') }
            resolve()
          },
          { enableHighAccuracy: false, timeout: 7000, maximumAge: 300000 }
        )
      })
    } finally { setLoadingWeather(false) }
  }

  const loadDashboard = async () => {
    try {
      const cropsRes = await getCrops()
      const cropList = cropsRes.data
      setCrops(cropList)
      loadCropWeather(cropList)
      const plData = await Promise.all(
        cropList.map(async (crop) => {
          try {
            const pl = await getProfitLoss(crop.id)
            return {
              cropId: crop.id, name: crop.name, fieldLocation: crop.fieldLocation,
              expenses: Number(pl.data.totalExpenses), revenue: Number(pl.data.totalRevenue),
              profit: Number(pl.data.netProfit), result: pl.data.result,
            }
          } catch {
            return { cropId: crop.id, name: crop.name, fieldLocation: crop.fieldLocation, expenses: 0, revenue: 0, profit: 0, result: 'N/A' }
          }
        })
      )
      setProfitData(plData)
      loadInsights(plData, cropList)
    } catch (err) {
      console.error('Dashboard load failed:', err)
    } finally { setLoading(false) }
  }

  const loadCropWeather = async (cropList) => {
    const weatherEntries = await Promise.all(
      cropList.map(async (crop) => {
        if (!crop.fieldLocation?.trim()) return [crop.id, null]
        try { const res = await getCurrentWeatherByLocation(crop.fieldLocation); return [crop.id, res.data] }
        catch { return [crop.id, null] }
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
      if (cropMeta && cropMeta.aiInsightsEnabled === false) { results[crop.name] = '__AI_OFF__'; continue }
      try {
        const res = await getCropInsights({ crop_name: crop.name, total_expenses: crop.expenses, total_revenue: crop.revenue, net_profit: crop.profit, status: crop.result })
        results[crop.name] = res.data.insights
      } catch { results[crop.name] = null }
    }
    setInsights(results)
    setLoadingInsights(false)
  }

  const loadDueReminders = async () => {
    try { const res = await getDueReminders(); setDueReminders(res.data) }
    catch { setDueReminders([]) }
  }

  const markReminderDone = async (reminderId) => {
    const reminder = dueReminders.find((item) => item.id === reminderId)
    if (!reminder) return
    try {
      await updateCropReminder(reminder.cropId, reminderId, { completed: true })
      setDueReminders((prev) => prev.filter((item) => item.id !== reminderId))
    } catch {}
  }

  const totalRevenue = profitData.reduce((s, d) => s + d.revenue, 0)
  const totalExpenses = profitData.reduce((s, d) => s + d.expenses, 0)
  const netProfit = totalRevenue - totalExpenses
  const activeCrops = crops.filter(c => c.status !== 'HARVESTED' && c.status !== 'FAILED').length

  const weatherAlerts = []
  if ((weatherCurrent?.temperatureC ?? 0) >= 34) weatherAlerts.push('High heat today. Check irrigation timing and mulch moisture retention.')
  if ((weatherCurrent?.rainMm ?? 0) > 0) weatherAlerts.push('Rain has started. Avoid pesticide spraying until conditions clear.')
  if (weatherForecast.some(f => (f.rainChancePercent ?? 0) >= 60)) weatherAlerts.push('Strong rain chance in forecast. Plan drainage and postpone field spraying.')

  const pieData = [
    { name: 'Revenue', value: totalRevenue },
    { name: 'Expenses', value: totalExpenses },
  ]

  const cardStyle = {
    background: 'var(--bg-card)',
    border: '1px solid var(--border)',
    borderRadius: '16px',
    backdropFilter: 'blur(12px)',
    padding: '24px',
  }

  const renderInsightContent = (rawInsight) => {
    const lines = rawInsight.split('\n').map(l => l.replace(/\*\*/g, '').trim()).filter(l => l.length > 0)
    return lines.map((line, idx) => {
      if (line.startsWith('* ')) return (
        <div key={idx} style={{ display: 'flex', gap: '8px', alignItems: 'flex-start', marginBottom: '4px' }}>
          <span style={{ color: '#4ade80', marginTop: '2px' }}>•</span>
          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-primary)', lineHeight: 1.6, margin: 0 }}>{line.replace(/^\*\s+/, '')}</p>
        </div>
      )
      if (/^\d+\./.test(line)) return (
        <p key={idx} style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)', margin: '6px 0 2px' }}>{line}</p>
      )
      return <p key={idx} style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', lineHeight: 1.6, margin: '2px 0' }}>{line}</p>
    })
  }

  if (loading) {
    return (
      <Layout>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '60vh', flexDirection: 'column', gap: '16px' }}>
          <div style={{ width: 40, height: 40, border: '3px solid rgba(74,222,128,0.2)', borderTopColor: '#4ade80', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ fontFamily: 'Inter', color: 'var(--text-muted)', fontSize: '14px' }}>Loading dashboard…</p>
        </div>
      </Layout>
    )
  }

  return (
    <Layout>
      {/* Stat cards */}
      <div style={{ display: 'grid', gridTemplateColumns: isMobile ? 'repeat(2, 1fr)' : 'repeat(4, 1fr)', gap: '12px', marginBottom: '20px' }}>
        <StatCard title="Harvest Revenue" value={`Rs. ${totalRevenue.toLocaleString()}`} sub="All crops" color="green" icon="📦" />
        <StatCard title="Total Expenses"  value={`Rs. ${totalExpenses.toLocaleString()}`} sub="All crops" color="red" icon="💸" />
        <StatCard title="Net Profit"      value={`Rs. ${netProfit.toLocaleString()}`} sub={netProfit >= 0 ? 'Profitable ✓' : 'Loss'} color={netProfit >= 0 ? 'green' : 'red'} icon="📈" />
        <StatCard title="Active Crops"    value={activeCrops} sub={`${crops.length} total`} color="blue" icon="🌾" />
      </div>

      {/* Charts row */}
      <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '2fr 1fr', gap: '16px', marginBottom: '20px' }}>

        {/* Bar chart */}
        <div style={cardStyle}>
          <div style={{ marginBottom: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)' }}>Revenue vs Expenses</div>
              <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>Per crop · Rs.</div>
            </div>
            <div style={{ display: 'flex', gap: '16px' }}>
              {[{ label: 'Revenue', color: '#4ade80' }, { label: 'Expenses', color: '#f87171' }].map(l => (
                <div key={l.label} style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <div style={{ width: 10, height: 10, borderRadius: '2px', background: l.color }} />
                  <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>{l.label}</span>
                </div>
              ))}
            </div>
          </div>
          {profitData.length === 0 ? (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', textAlign: 'center', padding: '40px 0' }}>
              No crop data yet — add crops and expenses to see charts
            </p>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={profitData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(74,222,128,0.08)" />
                <XAxis dataKey="name" tick={{ fill: 'var(--text-muted)', fontSize: 11, fontFamily: 'Inter' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fill: 'var(--text-muted)', fontSize: 11, fontFamily: 'Inter' }} axisLine={false} tickLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Bar dataKey="revenue" name="Revenue" fill="#4ade80" radius={[4, 4, 0, 0]} opacity={0.85} />
                <Bar dataKey="expenses" name="Expenses" fill="#f87171" radius={[4, 4, 0, 0]} opacity={0.75} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Weather widget */}
        <div style={cardStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '4px' }}>Weather</div>
              <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)' }}>{user?.city || 'Current Location'}</div>
            </div>
            {!loadingWeather && weatherCurrent && (
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontFamily: 'Space Grotesk', fontSize: '36px', fontWeight: 800, color: 'var(--text-primary)', lineHeight: 1 }}>
                  {Math.round(weatherCurrent.temperatureC ?? 0)}°
                </div>
                <div style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)' }}>{weatherCurrent.description || ''}</div>
              </div>
            )}
            <button onClick={loadWeather} style={{ background: 'none', border: 'none', color: '#4ade80', cursor: 'pointer', fontFamily: 'Inter', fontSize: '12px' }}>Refresh</button>
          </div>

          {loadingWeather ? (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', padding: '20px 0' }}>Loading weather…</p>
          ) : weatherError ? (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: '#f87171' }}>{weatherError}</p>
          ) : weatherCurrent ? (
            <>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px', padding: '12px', background: 'rgba(74,222,128,0.06)', borderRadius: '10px', border: '1px solid rgba(74,222,128,0.12)' }}>
                {weatherCurrent.iconUrl && <img src={weatherCurrent.iconUrl} alt="" style={{ width: 40, height: 40 }} />}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px 16px' }}>
                  <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>Feels: {Math.round(weatherCurrent.feelsLikeC ?? 0)}°C</span>
                  <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>Humidity: {weatherCurrent.humidity ?? 0}%</span>
                  <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>Wind: {weatherCurrent.windSpeed ?? 0} m/s</span>
                </div>
              </div>

              {weatherForecast.length > 0 && (
                <div style={{ display: 'grid', gridTemplateColumns: `repeat(${Math.min(weatherForecast.length, 5)}, 1fr)`, gap: '6px', marginBottom: '12px' }}>
                  {weatherForecast.slice(0, 5).map((item, idx) => (
                    <div key={idx} style={{ textAlign: 'center', background: 'var(--bg-input)', borderRadius: '10px', padding: '8px 4px', border: '1px solid var(--border)' }}>
                      <div style={{ fontFamily: 'Inter', fontSize: '10px', color: 'var(--text-muted)', marginBottom: '4px' }}>{item.dateTime?.slice(5, 13) || '-'}</div>
                      {item.iconUrl && <img src={item.iconUrl} alt="" style={{ width: 28, height: 28, margin: '0 auto 4px', display: 'block' }} />}
                      <div style={{ fontFamily: 'Space Grotesk', fontSize: '12px', fontWeight: 700, color: 'var(--text-primary)' }}>{Math.round(item.temperatureC ?? 0)}°</div>
                      <div style={{ fontFamily: 'Inter', fontSize: '10px', color: '#60a5fa' }}>{item.rainChancePercent ?? 0}%</div>
                    </div>
                  ))}
                </div>
              )}

              {weatherAlerts.map((alert, idx) => (
                <div key={idx} style={{ marginTop: '8px', padding: '10px 12px', background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.2)', borderRadius: '10px' }}>
                  <span style={{ fontFamily: 'Inter', fontSize: '12px', color: '#f59e0b' }}>⚠ {alert}</span>
                </div>
              ))}
            </>
          ) : (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>No weather data available.</p>
          )}
        </div>
      </div>

      {/* Reminders + Pie chart row */}
      <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr', gap: '16px', marginBottom: '20px' }}>

        {/* Today's Reminders */}
        <div style={cardStyle}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
            <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)' }}>Today's Reminders</div>
            <button onClick={loadDueReminders} style={{ background: 'none', border: 'none', color: '#4ade80', cursor: 'pointer', fontFamily: 'Inter', fontSize: '12px' }}>Refresh</button>
          </div>
          {dueReminders.length === 0 ? (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', padding: '16px 0' }}>No due reminders right now.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {dueReminders.map(item => (
                <div key={item.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', padding: '10px 12px', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px' }}>
                  <div>
                    <p style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)', margin: 0 }}>{item.title}</p>
                    <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)', margin: '2px 0 0' }}>
                      {item.type?.replaceAll('_', ' ')} · {item.reminderAt?.replace('T', ' ').slice(0, 16)}
                    </p>
                  </div>
                  <button onClick={() => markReminderDone(item.id)} style={{
                    background: 'rgba(74,222,128,0.12)', border: '1px solid rgba(74,222,128,0.3)',
                    borderRadius: '6px', padding: '4px 10px', color: '#4ade80',
                    fontFamily: 'Inter', fontSize: '12px', cursor: 'pointer', flexShrink: 0,
                  }}>Done ✓</button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Pie chart */}
        <div style={cardStyle}>
          <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', marginBottom: '4px' }}>Revenue vs Expenses</div>
          <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '12px' }}>Overall overview</div>
          {totalRevenue === 0 && totalExpenses === 0 ? (
            <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', textAlign: 'center', padding: '40px 0' }}>No financial data yet</p>
          ) : (
            <>
              <ResponsiveContainer width="100%" height={180}>
                <PieChart>
                  <Pie data={pieData} cx="50%" cy="50%" innerRadius={50} outerRadius={78} paddingAngle={4} dataKey="value">
                    {pieData.map((_, index) => (
                      <Cell key={index} fill={CHART_COLORS[index]} opacity={0.9} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => `Rs. ${value.toLocaleString()}`} contentStyle={CUSTOM_TOOLTIP_STYLE} />
                </PieChart>
              </ResponsiveContainer>
              {/* Legend below chart */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: '12px' }}>
                {pieData.map((entry, index) => {
                  const total = totalRevenue + totalExpenses
                  const pct = total > 0 ? ((entry.value / total) * 100).toFixed(0) : 0
                  return (
                    <div key={entry.name} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <div style={{ width: 10, height: 10, borderRadius: '50%', background: CHART_COLORS[index], flexShrink: 0 }} />
                        <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>{entry.name}</span>
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <span style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)' }}>{pct}%</span>
                        <span style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 700, color: CHART_COLORS[index] }}>Rs. {entry.value.toLocaleString()}</span>
                      </div>
                    </div>
                  )
                })}
              </div>
            </>
          )}
        </div>
      </div>

      {/* Crop performance table */}
      <div style={{ ...cardStyle, marginBottom: '20px' }}>
        <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', marginBottom: '18px' }}>Crop Performance</div>
        {profitData.length === 0 ? (
          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)', textAlign: 'center', padding: '24px 0' }}>No crops added yet</p>
        ) : (
          <div className="table-scroll">
          <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: '480px' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid rgba(74,222,128,0.1)' }}>
                {['Crop', 'Revenue', 'Expenses', 'Net Profit', 'Result'].map(h => (
                  <th key={h} style={{ padding: '10px 14px', fontFamily: 'Inter', fontSize: '12px', fontWeight: 600, color: 'var(--text-muted)', textAlign: 'left', textTransform: 'uppercase', letterSpacing: '0.5px' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {profitData.map((row, i) => (
                <tr key={i}
                  style={{ borderBottom: i < profitData.length - 1 ? '1px solid rgba(74,222,128,0.06)' : 'none', transition: 'background 0.2s' }}
                  onMouseEnter={e => e.currentTarget.style.background = 'rgba(74,222,128,0.04)'}
                  onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                >
                  <td style={{ padding: '12px 14px', fontFamily: 'Space Grotesk', fontSize: '14px', fontWeight: 600, color: 'var(--text-primary)' }}>{row.name}</td>
                  <td style={{ padding: '12px 14px', fontFamily: 'Space Grotesk', fontSize: '14px', color: '#4ade80' }}>Rs. {row.revenue.toLocaleString()}</td>
                  <td style={{ padding: '12px 14px', fontFamily: 'Space Grotesk', fontSize: '14px', color: '#f87171' }}>Rs. {row.expenses.toLocaleString()}</td>
                  <td style={{ padding: '12px 14px', fontFamily: 'Space Grotesk', fontSize: '14px', fontWeight: 700, color: row.profit >= 0 ? '#4ade80' : '#f87171' }}>Rs. {row.profit.toLocaleString()}</td>
                  <td style={{ padding: '12px 14px' }}>
                    <span className={row.result === 'PROFIT' ? 'badge-green' : row.result === 'LOSS' ? 'badge-red' : 'badge-gray'}>{row.result}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
        )}
      </div>

      {/* AI Insights */}
      {profitData.length > 0 && (
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
            <div style={{
              width: 32, height: 32, borderRadius: '8px',
              background: 'linear-gradient(135deg, rgba(74,222,128,0.3), rgba(22,163,74,0.2))',
              border: '1px solid rgba(74,222,128,0.4)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: '16px', animation: 'pulse-glow 2s ease-in-out infinite',
            }}>🤖</div>
            <span style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)' }}>AI Insights</span>
            <span style={{ background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.3)', borderRadius: '100px', padding: '3px 10px', fontFamily: 'Inter', fontSize: '11px', color: '#4ade80' }}>Powered by Groq</span>
          </div>

          {loadingInsights ? (
            <div style={{ ...cardStyle, textAlign: 'center', padding: '48px' }}>
              <div style={{ width: 32, height: 32, border: '3px solid rgba(74,222,128,0.2)', borderTopColor: '#4ade80', borderRadius: '50%', animation: 'spin 0.8s linear infinite', margin: '0 auto 12px' }} />
              <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)' }}>🤖 AI is analysing your crops…</p>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: isMobile || profitData.length === 1 ? '1fr' : '1fr 1fr', gap: '16px' }}>
              {profitData.map((crop, i) => (
                <div key={i} style={cardStyle}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '14px' }}>
                    <span style={{ fontSize: '18px' }}>🌾</span>
                    <span style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)' }}>{crop.name}</span>
                    <span className={crop.result === 'PROFIT' ? 'badge-green' : 'badge-red'} style={{ marginLeft: 'auto' }}>{crop.result}</span>
                  </div>

                  {/* Field weather */}
                  <div style={{ marginBottom: '12px', padding: '10px 12px', background: 'rgba(96,165,250,0.08)', border: '1px solid rgba(96,165,250,0.15)', borderRadius: '10px' }}>
                    <p style={{ fontFamily: 'Inter', fontSize: '11px', color: '#60a5fa', fontWeight: 600, marginBottom: '4px' }}>Field Weather</p>
                    {cropWeatherById[crop.cropId] ? (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        {cropWeatherById[crop.cropId].iconUrl && <img src={cropWeatherById[crop.cropId].iconUrl} alt="" style={{ width: 28, height: 28 }} />}
                        <div>
                          <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-primary)', margin: 0 }}>
                            {Math.round(cropWeatherById[crop.cropId].temperatureC ?? 0)}°C {cropWeatherById[crop.cropId].description || ''}
                          </p>
                          <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)', margin: '2px 0 0' }}>
                            {cropWeatherById[crop.cropId].location || crop.fieldLocation || 'Field location'}
                          </p>
                        </div>
                      </div>
                    ) : (
                      <p style={{ fontFamily: 'Inter', fontSize: '12px', color: 'rgba(96,165,250,0.6)' }}>
                        Weather not available for {crop.fieldLocation || 'this field location'}.
                      </p>
                    )}
                  </div>

                  {/* Insight text */}
                  {insights[crop.name] && insights[crop.name] !== '__AI_OFF__' ? (
                    <div style={{ background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '12px' }}>
                      {renderInsightContent(insights[crop.name])}
                    </div>
                  ) : insights[crop.name] === '__AI_OFF__' ? (
                    <p style={{ fontFamily: 'Inter', fontSize: '13px', color: '#f59e0b', background: 'rgba(245,158,11,0.08)', border: '1px solid rgba(245,158,11,0.2)', borderRadius: '8px', padding: '10px 12px', margin: 0 }}>
                      AI off by farmer for this crop.
                    </p>
                  ) : (
                    <p style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-faint)' }}>No insights available</p>
                  )}

                  {/* Mini financials */}
                  <div style={{ marginTop: '14px', paddingTop: '12px', borderTop: '1px solid rgba(74,222,128,0.08)', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '8px', textAlign: 'center' }}>
                    {[
                      { label: 'Revenue', value: `Rs. ${crop.revenue.toLocaleString()}`, color: '#4ade80' },
                      { label: 'Expenses', value: `Rs. ${crop.expenses.toLocaleString()}`, color: '#f87171' },
                      { label: 'Profit', value: `Rs. ${crop.profit.toLocaleString()}`, color: crop.profit >= 0 ? '#4ade80' : '#f87171' },
                    ].map(s => (
                      <div key={s.label}>
                        <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)', margin: '0 0 2px' }}>{s.label}</p>
                        <p style={{ fontFamily: 'Space Grotesk', fontSize: '13px', fontWeight: 700, color: s.color, margin: 0 }}>{s.value}</p>
                      </div>
                    ))}
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
