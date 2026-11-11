import { useEffect, useState } from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, PieChart, Pie, Cell
} from 'recharts'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import WeatherAlerts from '../components/WeatherAlerts'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import { getDashboardSummary, getDueReminders, updateCropReminder, getCropInsight } from '../api/crops'
import {
  getCurrentWeather, getCurrentWeatherByLocation,
  getDailyForecast, getDailyForecastByLocation, getWeatherAlerts,
} from '../api/weather'

// Recharts writes colours as SVG attributes, where CSS variables do not
// resolve, so the theme's chart colours are read once and passed as values.
const FALLBACK_CHART_COLORS = ['#2f8f46', '#f59e0b', '#3f7fae', '#4ade80', '#8b6f5a', '#3a8f8a']

function readChartColors() {
  const css = getComputedStyle(document.documentElement)
  return FALLBACK_CHART_COLORS.map((fallback, i) => css.getPropertyValue(`--chart-${i + 1}`).trim() || fallback)
}

// Colombo, for when neither a saved city nor the browser's position works.
const FALLBACK_LAT = 6.9271
const FALLBACK_LON = 79.8612

/** Resolves to the browser's coordinates, or null if unavailable or refused. */
function browserPosition() {
  return new Promise((resolve) => {
    if (!navigator.geolocation) { resolve(null); return }
    navigator.geolocation.getCurrentPosition(
      (position) => resolve(position.coords),
      () => resolve(null),
      { enableHighAccuracy: false, timeout: 7000, maximumAge: 300000 },
    )
  })
}

async function succeeds(attempt) {
  try { await attempt(); return true } catch { return false }
}

const font = 'var(--font-body)'
const rupees = (value) => `Rs. ${Number(value).toLocaleString()}`
const shortRupees = (value) => (Math.abs(value) >= 1000 ? `${Math.round(value / 1000)}k` : `${value}`)

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload || !payload.length) return null
  return (
    <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '10px', padding: '8px 12px', fontFamily: font, fontSize: '13px', color: 'var(--text-primary)', boxShadow: '0 4px 16px rgba(0,0,0,0.08)' }}>
      {label && <p style={{ fontWeight: 600, margin: '0 0 2px' }}>{label}</p>}
      {payload.map((p, i) => (
        <p key={i} style={{ margin: 0 }}>{p.name}: {rupees(p.value)}</p>
      ))}
    </div>
  )
}

const card = {
  background: 'var(--bg-card)',
  border: '1px solid var(--border)',
  borderRadius: 'var(--radius-card)',
  padding: '22px 24px',
  minWidth: 0,
}

const cardTitle = { fontFamily: font, fontWeight: 700, fontSize: '17px', color: 'var(--text-primary)', margin: 0 }
const cardSub = { fontFamily: font, fontSize: '14px', color: 'var(--text-muted)', margin: '2px 0 0' }
const emptyText = { fontFamily: font, fontSize: '14px', color: 'var(--text-faint)', padding: '28px 0', textAlign: 'center' }
const textButton = { background: 'none', border: 'none', color: 'var(--accent-lime)', cursor: 'pointer', fontFamily: font, fontSize: '13px', fontWeight: 600, padding: '4px 0' }

/** A colour key with the amount and share, as a list under a chart. */
function ShareList({ rows, colors, total }) {
  return (
    <ul style={{ listStyle: 'none', margin: '8px 0 0', padding: 0 }}>
      {rows.map((row, i) => (
        <li key={row.cropId} style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '9px 0', borderBottom: i < rows.length - 1 ? '1px solid var(--border)' : 'none', fontFamily: font, fontSize: '14px' }}>
          <span aria-hidden="true" style={{ width: 10, height: 10, borderRadius: '3px', background: colors[i % colors.length], flexShrink: 0 }} />
          <span style={{ flex: 1, minWidth: 0, color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{row.name}</span>
          <span style={{ fontWeight: 600, color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.value)}</span>
          <span style={{ width: 44, textAlign: 'right', color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>{total > 0 ? `${Math.round((row.value / total) * 100)}%` : '0%'}</span>
        </li>
      ))}
    </ul>
  )
}

export default function DashboardPage() {
  const { user } = useAuth()
  const isMobile = useIsMobile()
  const isNarrow = useIsMobile(520)
  const [chartColors] = useState(readChartColors)
  const [totals, setTotals] = useState(null)
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
  const [alerts, setAlerts] = useState([])
  const [movingReminderId, setMovingReminderId] = useState(null)

  useEffect(() => {
    loadDashboard()
    loadWeather()
    loadAlerts()
  }, [])

  const fetchWeatherByCoords = async (lat, lon) => {
    const [currentRes, dailyRes] = await Promise.all([
      getCurrentWeather(lat, lon),
      getDailyForecast(lat, lon),
    ])
    setWeatherCurrent(currentRes.data)
    setWeatherForecast(dailyRes.data?.days ?? [])
  }

  const fetchWeatherByLocation = async (location) => {
    const [currentRes, dailyRes] = await Promise.all([
      getCurrentWeatherByLocation(location),
      getDailyForecastByLocation(location),
    ])
    setWeatherCurrent(currentRes.data)
    setWeatherForecast(dailyRes.data?.days ?? [])
  }

  // Fetched alongside the summary rather than inside it, so a slow forecast
  // never holds up the figures. Failing quietly is right: alerts are advice.
  const loadAlerts = async () => {
    try { const res = await getWeatherAlerts(); setAlerts(res.data) }
    catch { setAlerts([]) }
  }

  const moveReminder = async (alert) => {
    setMovingReminderId(alert.reminderId)
    try {
      await updateCropReminder(alert.cropId, alert.reminderId, { reminderAt: alert.suggestedAt })
      await Promise.all([loadAlerts(), loadDueReminders()])
    } catch {
      // Leave the alert in place so the user can retry.
    } finally {
      setMovingReminderId(null)
    }
  }

  // Saved city first, then the browser's position, then Colombo. Each step
  // only runs if the one before it failed, and the card always ends up with
  // either weather or a message: previously a failed lookup on the city or
  // fallback path rejected unhandled and left the card blank.
  const loadWeather = async () => {
    setLoadingWeather(true)
    setWeatherError('')
    const savedCity = user?.city?.trim()
    try {
      if (savedCity && await succeeds(() => fetchWeatherByLocation(savedCity))) return
      const position = await browserPosition()
      if (position && await succeeds(() => fetchWeatherByCoords(position.latitude, position.longitude))) return
      if (await succeeds(() => fetchWeatherByCoords(FALLBACK_LAT, FALLBACK_LON))) return
      setWeatherError('Unable to load weather now.')
    } finally { setLoadingWeather(false) }
  }

  // One request for every figure on the page. The server sums per crop in
  // two grouped queries instead of the browser asking once per crop.
  const loadDashboard = async () => {
    try {
      const { data } = await getDashboardSummary()
      const rows = data.crops.map((crop) => ({
        cropId: crop.cropId, name: crop.cropName, fieldLocation: crop.fieldLocation,
        aiInsightsEnabled: crop.aiInsightsEnabled,
        expenses: Number(crop.totalExpenses), revenue: Number(crop.totalRevenue),
        profit: Number(crop.netProfit), result: crop.result,
      }))
      setTotals(data.totals)
      setProfitData(rows)
      setDueReminders(data.dueReminders)
      loadCropWeather(rows)
      loadInsights(rows)
    } catch (err) {
      console.error('Dashboard load failed:', err)
    } finally { setLoading(false) }
  }

  const loadCropWeather = async (rows) => {
    const weatherEntries = await Promise.all(
      rows.map(async (crop) => {
        if (!crop.fieldLocation?.trim()) return [crop.cropId, null]
        try { const res = await getCurrentWeatherByLocation(crop.fieldLocation); return [crop.cropId, res.data] }
        catch { return [crop.cropId, null] }
      })
    )
    setCropWeatherById(Object.fromEntries(weatherEntries))
  }

  // The backend caches each insight against a fingerprint of the crop's
  // figures, so this is normally a plain database read. Only a crop whose
  // expenses, harvests or status actually changed costs any tokens.
  // Keyed by crop id: keying by name let two crops called "Paddy" overwrite
  // each other's insight.
  const loadInsights = async (rows) => {
    setLoadingInsights(true)

    // Fetched together rather than one after another: the old sequential loop
    // made the dashboard wait for every crop in turn.
    const entries = await Promise.all(rows.map(async (crop) => {
      if (crop.aiInsightsEnabled === false) return [crop.cropId, '__AI_OFF__']
      try {
        const res = await getCropInsight(crop.cropId)
        return [crop.cropId, res.data.insights]
      } catch {
        return [crop.cropId, null]
      }
    }))

    setInsights(Object.fromEntries(entries))
    setLoadingInsights(false)
  }

  // The card's Refresh button only needs the reminders, not the whole summary.
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
    } catch {
      // Leave the reminder in place so the user can retry.
    }
  }

  const totalRevenue = Number(totals?.totalRevenue ?? 0)
  const totalExpenses = Number(totals?.totalExpenses ?? 0)
  const netProfit = Number(totals?.netProfit ?? 0)
  const activeCrops = totals?.activeCrops ?? 0
  const totalCrops = totals?.totalCrops ?? 0
  const margin = totalRevenue > 0 ? `${((netProfit / totalRevenue) * 100).toFixed(1)}%` : 'None yet'

  const incomeRows = profitData.filter((row) => row.revenue > 0).map((row) => ({ cropId: row.cropId, name: row.name, value: row.revenue }))
  const expenseRows = profitData.filter((row) => row.expenses > 0).map((row) => ({ cropId: row.cropId, name: row.name, value: row.expenses }))

  const renderInsightContent = (rawInsight) => {
    const lines = rawInsight.split('\n').map(l => l.replace(/\*\*/g, '').trim()).filter(l => l.length > 0)
    return lines.map((line, idx) => {
      if (line.startsWith('* ')) return (
        <div key={idx} style={{ display: 'flex', gap: '8px', alignItems: 'flex-start', marginBottom: '4px' }}>
          <span aria-hidden="true" style={{ color: 'var(--accent-lime)', marginTop: '1px' }}>•</span>
          <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-primary)', lineHeight: 1.55, margin: 0 }}>{line.replace(/^\*\s+/, '')}</p>
        </div>
      )
      if (/^\d+\./.test(line)) return (
        <p key={idx} style={{ fontFamily: font, fontSize: '14px', fontWeight: 600, color: 'var(--text-primary)', margin: '6px 0 2px' }}>{line}</p>
      )
      return <p key={idx} style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-muted)', lineHeight: 1.55, margin: '2px 0' }}>{line}</p>
    })
  }

  if (loading) {
    return (
      <Layout title={null}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '60vh', flexDirection: 'column', gap: '16px' }}>
          <div style={{ width: 36, height: 36, border: '3px solid var(--border)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ fontFamily: font, color: 'var(--text-muted)', fontSize: '14px' }}>Loading dashboard…</p>
        </div>
      </Layout>
    )
  }

  return (
    <Layout title={null}>
      {/* Weather risks to planned tasks come first, because they need acting on */}
      <WeatherAlerts alerts={alerts} onMove={moveReminder} movingId={movingReminderId} />

      {/* ── Profit & loss ── */}
      <section aria-labelledby="pl-title" style={{ ...card, marginBottom: '20px', padding: isMobile ? '20px 18px' : '26px 28px' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'flex-start', gap: '8px 24px', marginBottom: '20px' }}>
          <div>
            <h1 id="pl-title" style={{ ...cardTitle, fontSize: '22px' }}>Profit &amp; loss</h1>
            <p style={cardSub}>Income and expenses for each crop, across all your records</p>
          </div>
          <span style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-muted)', padding: '6px 12px', border: '1px solid var(--border)', borderRadius: '8px' }}>
            {`${totalCrops} crops, ${activeCrops} active`}
          </span>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: `repeat(${isNarrow ? 1 : isMobile ? 2 : 4}, minmax(0, 1fr))`, gap: '12px', marginBottom: '28px' }}>
          <StatCard title="Harvest income" value={rupees(totalRevenue)} sub="Sales from all crops" />
          <StatCard title="Total expenses" value={rupees(totalExpenses)} sub="Costs across all crops" />
          <StatCard title="Net profit" value={rupees(netProfit)} tone={netProfit >= 0 ? 'good' : 'bad'} sub={netProfit >= 0 ? 'Profit' : 'Loss'} subTone={netProfit >= 0 ? 'good' : 'bad'} />
          <StatCard title="Margin" value={margin} tone={totalRevenue > 0 ? (netProfit >= 0 ? 'good' : 'bad') : 'neutral'} sub="of income kept" />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: isMobile ? 'minmax(0, 1fr)' : 'repeat(2, minmax(0, 1fr))', gap: isMobile ? '32px' : '48px' }}>
          <div style={{ minWidth: 0 }}>
            <h2 style={{ ...cardTitle, fontSize: '16px' }}>Income by crop</h2>
            {incomeRows.length === 0 ? (
              <p style={emptyText}>No harvests sold yet</p>
            ) : (
              <>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie data={incomeRows} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={62} outerRadius={92} paddingAngle={2} stroke="none">
                      {incomeRows.map((row, i) => <Cell key={row.cropId} fill={chartColors[i % chartColors.length]} />)}
                    </Pie>
                    <Tooltip content={<CustomTooltip />} />
                  </PieChart>
                </ResponsiveContainer>
                <ShareList rows={incomeRows} colors={chartColors} total={totalRevenue} />
              </>
            )}
          </div>

          <div style={{ minWidth: 0 }}>
            <h2 style={{ ...cardTitle, fontSize: '16px' }}>Expenses by crop</h2>
            {expenseRows.length === 0 ? (
              <p style={emptyText}>No expenses recorded yet</p>
            ) : (
              <>
                <ResponsiveContainer width="100%" height={Math.max(160, expenseRows.length * 52 + 40)}>
                  <BarChart data={expenseRows} layout="vertical" margin={{ top: 12, right: 16, bottom: 4, left: 8 }}>
                    <CartesianGrid horizontal={false} stroke="var(--border)" />
                    <XAxis type="number" tickFormatter={shortRupees} tick={{ fill: 'var(--text-muted)', fontSize: 12 }} axisLine={false} tickLine={false} />
                    <YAxis type="category" dataKey="name" width={96} tick={{ fill: 'var(--text-primary)', fontSize: 13 }} axisLine={false} tickLine={false} />
                    <Tooltip content={<CustomTooltip />} cursor={{ fill: 'var(--bg-row-hover)' }} />
                    <Bar dataKey="value" name="Expenses" radius={[0, 4, 4, 0]} barSize={22}>
                      {expenseRows.map((row, i) => <Cell key={row.cropId} fill={chartColors[i % chartColors.length]} />)}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
                <ShareList rows={expenseRows} colors={chartColors} total={totalExpenses} />
              </>
            )}
          </div>
        </div>
      </section>

      {/* ── Reminders and weather ── */}
      <div style={{ display: 'grid', gridTemplateColumns: isMobile ? 'minmax(0, 1fr)' : 'repeat(2, minmax(0, 1fr))', gap: '20px', marginBottom: '20px' }}>
        <section aria-labelledby="due-title" style={card}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '12px' }}>
            <h2 id="due-title" style={cardTitle}>Today's reminders</h2>
            <button type="button" onClick={loadDueReminders} style={textButton}>Refresh</button>
          </div>
          {dueReminders.length === 0 ? (
            <p style={emptyText}>No due reminders right now.</p>
          ) : (
            <ul style={{ listStyle: 'none', margin: 0, padding: 0 }}>
              {dueReminders.map((item, i) => (
                <li key={item.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', padding: '12px 0', borderBottom: i < dueReminders.length - 1 ? '1px solid var(--border)' : 'none' }}>
                  <div style={{ minWidth: 0 }}>
                    <p style={{ fontFamily: font, fontSize: '15px', fontWeight: 600, color: 'var(--text-primary)', margin: 0 }}>{item.title}</p>
                    <p style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', margin: '2px 0 0' }}>
                      {item.type?.replaceAll('_', ' ').toLowerCase()}, {item.reminderAt?.replace('T', ' ').slice(0, 16)}
                    </p>
                  </div>
                  <button type="button" onClick={() => markReminderDone(item.id)} style={{ background: 'var(--bg-tile)', border: 'none', borderRadius: '8px', padding: '7px 12px', color: 'var(--accent-lime)', fontFamily: font, fontSize: '13px', fontWeight: 600, cursor: 'pointer', flexShrink: 0 }}>
                    Mark done
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>

        <section aria-labelledby="weather-title" style={card}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: '12px', marginBottom: '12px' }}>
            <div>
              <h2 id="weather-title" style={cardTitle}>Weather</h2>
              <p style={cardSub}>{weatherCurrent?.location || user?.city || 'Your location'}</p>
            </div>
            <button type="button" onClick={loadWeather} style={textButton}>Refresh</button>
          </div>

          {loadingWeather ? (
            <p style={emptyText}>Loading weather…</p>
          ) : weatherError ? (
            <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--accent-red)', padding: '12px 0' }}>{weatherError}</p>
          ) : weatherCurrent ? (
            <>
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flexWrap: 'wrap', marginBottom: '16px' }}>
                {weatherCurrent.iconUrl && <img src={weatherCurrent.iconUrl} alt="" style={{ width: 52, height: 52 }} />}
                <div>
                  <div style={{ fontFamily: font, fontSize: '34px', fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1.1 }}>{Math.round(weatherCurrent.temperatureC ?? 0)}°C</div>
                  <div style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-muted)' }}>{weatherCurrent.description || ''}</div>
                </div>
                <dl style={{ marginLeft: 'auto', display: 'grid', gridTemplateColumns: 'auto auto', gap: '2px 12px', fontFamily: font, fontSize: '13px' }}>
                  <dt style={{ color: 'var(--text-muted)' }}>Feels like</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{Math.round(weatherCurrent.feelsLikeC ?? 0)}°C</dd>
                  <dt style={{ color: 'var(--text-muted)' }}>Humidity</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{weatherCurrent.humidity ?? 0}%</dd>
                  <dt style={{ color: 'var(--text-muted)' }}>Wind</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{weatherCurrent.windSpeed ?? 0} m/s</dd>
                </dl>
              </div>

              {weatherForecast.length > 0 && (
                <div style={{ display: 'grid', gridTemplateColumns: `repeat(${Math.min(weatherForecast.length, 5)}, minmax(0, 1fr))`, gap: '8px' }}>
                  {weatherForecast.slice(0, 5).map((day) => (
                    <div key={day.date} style={{ textAlign: 'center', background: 'var(--bg-tile)', borderRadius: '10px', padding: '10px 4px' }}>
                      <div style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-muted)' }}>
                        {new Date(`${day.date}T00:00:00`).toLocaleDateString('en-GB', { weekday: 'short' })}
                      </div>
                      {day.iconUrl && <img src={day.iconUrl} alt={day.description || ''} style={{ width: 32, height: 32, margin: '2px auto', display: 'block' }} />}
                      <div style={{ fontFamily: font, fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>
                        {Math.round(day.maxTempC ?? 0)}° <span style={{ fontWeight: 400, color: 'var(--text-muted)' }}>{Math.round(day.minTempC ?? 0)}°</span>
                      </div>
                      <div style={{ fontFamily: font, fontSize: '12px', color: 'var(--accent-blue)' }}>{day.rainChancePercent ?? 0}% rain</div>
                    </div>
                  ))}
                </div>
              )}
            </>
          ) : (
            <p style={emptyText}>No weather data available.</p>
          )}
        </section>
      </div>

      {/* ── Crop performance ── */}
      <section aria-labelledby="crops-title" style={{ ...card, marginBottom: '28px' }}>
        <h2 id="crops-title" style={{ ...cardTitle, marginBottom: '12px' }}>Crop performance</h2>
        {profitData.length === 0 ? (
          <p style={emptyText}>No crops added yet</p>
        ) : (
          <div className="table-scroll">
            <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: '520px', fontFamily: font, fontSize: '14px' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border)' }}>
                  {['Crop', 'Income', 'Expenses', 'Profit', 'Result'].map((h, i) => (
                    <th key={h} scope="col" style={{ padding: '10px 12px', fontWeight: 600, color: 'var(--text-muted)', textAlign: i === 0 || i === 4 ? 'left' : 'right' }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {profitData.map((row, i) => (
                  <tr key={row.cropId} style={{ borderBottom: i < profitData.length - 1 ? '1px solid var(--border)' : 'none' }}>
                    <th scope="row" style={{ padding: '12px', fontWeight: 600, color: 'var(--text-primary)', textAlign: 'left' }}>{row.name}</th>
                    <td style={{ padding: '12px', textAlign: 'right', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.revenue)}</td>
                    <td style={{ padding: '12px', textAlign: 'right', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.expenses)}</td>
                    <td style={{ padding: '12px', textAlign: 'right', fontWeight: 600, color: row.profit >= 0 ? 'var(--accent-lime)' : 'var(--accent-red)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.profit)}</td>
                    <td style={{ padding: '12px' }}>
                      <span className={row.result === 'PROFIT' ? 'badge-green' : row.result === 'LOSS' ? 'badge-red' : 'badge-gray'}>{row.result}</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* ── AI insights ── */}
      {profitData.length > 0 && (
        <section aria-labelledby="insights-title">
          <h2 id="insights-title" style={{ ...cardTitle, fontSize: '19px', marginBottom: '4px' }}>AI insights</h2>
          <p style={{ ...cardSub, marginBottom: '14px' }}>Advice for each crop, based on its figures and the weather at the field</p>

          {loadingInsights ? (
            <div style={{ ...card, textAlign: 'center', padding: '40px' }}>
              <div style={{ width: 28, height: 28, border: '3px solid var(--border)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite', margin: '0 auto 12px' }} />
              <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-muted)' }}>Reading your crops…</p>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: isMobile || profitData.length === 1 ? 'minmax(0, 1fr)' : 'repeat(2, minmax(0, 1fr))', gap: '20px' }}>
              {profitData.map((crop) => {
                const weather = cropWeatherById[crop.cropId]
                return (
                  <article key={crop.cropId} style={card}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
                      <h3 style={{ ...cardTitle, fontSize: '16px' }}>{crop.name}</h3>
                      <span className={crop.result === 'PROFIT' ? 'badge-green' : 'badge-red'} style={{ marginLeft: 'auto' }}>{crop.result}</span>
                    </div>

                    <p style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', margin: '0 0 12px' }}>
                      {weather
                        ? `${weather.location || crop.fieldLocation || 'Field'}: ${Math.round(weather.temperatureC ?? 0)}°C, ${weather.description || ''}`
                        : `Weather not available for ${crop.fieldLocation || 'this field location'}.`}
                    </p>

                    {insights[crop.cropId] && insights[crop.cropId] !== '__AI_OFF__' ? (
                      <div style={{ background: 'var(--bg-tile)', borderRadius: '10px', padding: '12px 14px' }}>
                        {renderInsightContent(insights[crop.cropId])}
                      </div>
                    ) : insights[crop.cropId] === '__AI_OFF__' ? (
                      <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--accent-amber)', margin: 0 }}>
                        AI off by farmer for this crop.
                      </p>
                    ) : (
                      <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-faint)', margin: 0 }}>No insights available</p>
                    )}

                    <dl style={{ marginTop: '14px', paddingTop: '12px', borderTop: '1px solid var(--border)', display: 'grid', gridTemplateColumns: 'repeat(3, minmax(0, 1fr))', gap: '8px', fontFamily: font }}>
                      {[
                        { label: 'Income', value: crop.revenue, color: 'var(--text-primary)' },
                        { label: 'Expenses', value: crop.expenses, color: 'var(--text-primary)' },
                        { label: 'Profit', value: crop.profit, color: crop.profit >= 0 ? 'var(--accent-lime)' : 'var(--accent-red)' },
                      ].map(s => (
                        <div key={s.label}>
                          <dt style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{s.label}</dt>
                          <dd style={{ margin: 0, fontSize: '14px', fontWeight: 600, color: s.color, fontVariantNumeric: 'tabular-nums' }}>{rupees(s.value)}</dd>
                        </div>
                      ))}
                    </dl>
                  </article>
                )
              })}
            </div>
          )}
        </section>
      )}
    </Layout>
  )
}
