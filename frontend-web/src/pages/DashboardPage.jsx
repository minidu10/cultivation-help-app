import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import WeatherAlerts from '../components/WeatherAlerts'
import {
  BellIcon, CheckCircleIcon, PaymentsIcon, ReceiptIcon, SproutIcon, TrendDownIcon, TrendUpIcon,
} from '../components/Icons'
import { REMINDER_ICONS } from '../components/iconMaps'
import { card } from '../components/surfaces'
import { useAuth } from '../context/AuthContext'
import { useIsMobile } from '../hooks/useIsMobile'
import { getDashboardSummary, updateCropReminder, getCropInsight } from '../api/crops'
import {
  getCurrentWeather, getCurrentWeatherByLocation,
  getDailyForecast, getDailyForecastByLocation, getWeatherAlerts,
} from '../api/weather'
import { formatDateTime, humanize, rupees } from '../utils/format'

// Recharts writes colours as SVG attributes, where CSS variables do not
// resolve, so the theme's colours are read once and passed as values.
const FALLBACK_COLORS = { profit: '#15803d', loss: '#dc2626', muted: '#424940', grid: '#d7ddd3' }
const FALLBACK_PALETTE = ['#2f8f46', '#f59e0b', '#3f7fae', '#4ade80', '#8b6f5a', '#3a8f8a']

function readChartColors() {
  const css = getComputedStyle(document.documentElement)
  const read = (name, fallback) => css.getPropertyValue(name).trim() || fallback
  return {
    profit: read('--profit', FALLBACK_COLORS.profit),
    loss: read('--loss', FALLBACK_COLORS.loss),
    muted: read('--text-muted', FALLBACK_COLORS.muted),
    grid: read('--border', FALLBACK_COLORS.grid),
    // One colour per crop in the pie charts.
    palette: FALLBACK_PALETTE.map((fallback, i) => read(`--chart-${i + 1}`, fallback)),
  }
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

const shortRupees = (value) => (Math.abs(value) >= 1000 ? `${Math.round(value / 1000)}k` : `${value}`)

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload || !payload.length) return null
  return (
    <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '10px', padding: '8px 12px', fontSize: '13px', color: 'var(--text-primary)', boxShadow: '0 4px 16px rgba(0,0,0,0.08)' }}>
      {label && <p style={{ fontWeight: 600, margin: '0 0 2px' }}>{label}</p>}
      {payload.map((p) => (
        <p key={p.dataKey} style={{ margin: 0 }}>{p.name}: {rupees(p.value)}</p>
      ))}
    </div>
  )
}

const panel = { ...card, padding: '20px 22px' }
const panelTitle = { fontWeight: 700, fontSize: '17px', color: 'var(--text-primary)', margin: 0 }
const panelSub = { fontSize: '14px', color: 'var(--text-muted)', margin: '2px 0 0' }
const emptyText = { fontSize: '14px', color: 'var(--text-muted)', padding: '20px 0 8px', margin: 0 }
const textButton = { background: 'none', border: 'none', color: 'var(--accent-lime)', cursor: 'pointer', fontFamily: 'var(--font-body)', fontSize: '14px', fontWeight: 600, padding: '4px 0' }

function Legend({ color, label }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: 'var(--text-muted)' }}>
      <span aria-hidden="true" style={{ width: 10, height: 10, borderRadius: 3, background: color }} />
      {label}
    </span>
  )
}

/** A donut of each crop's share, with the total in the middle and the amounts listed under it. */
function ShareDonut({ title, rows, total, colors, emptyMessage }) {
  return (
    <div style={{ minWidth: 0 }}>
      <h3 style={{ fontSize: '15px', fontWeight: 600, color: 'var(--text-primary)', margin: 0 }}>{title}</h3>
      {rows.length === 0 ? (
        <p style={emptyText}>{emptyMessage}</p>
      ) : (
        <>
          <div style={{ position: 'relative' }}>
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie data={rows} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={60} outerRadius={88} paddingAngle={2} stroke="none">
                  {rows.map((row, i) => <Cell key={row.cropId} fill={colors[i % colors.length]} />)}
                </Pie>
                <Tooltip content={<CustomTooltip />} />
              </PieChart>
            </ResponsiveContainer>
            <div aria-hidden="true" style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', pointerEvents: 'none' }}>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Total</span>
              <span style={{ fontSize: '15px', fontWeight: 700, color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(total)}</span>
            </div>
          </div>
          <ul style={{ listStyle: 'none', margin: '4px 0 0', padding: 0 }}>
            {rows.map((row, i) => (
              <li key={row.cropId} style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '8px 0', borderTop: '1px solid var(--border)', fontSize: '14px' }}>
                <span aria-hidden="true" style={{ width: 10, height: 10, borderRadius: 3, background: colors[i % colors.length], flexShrink: 0 }} />
                <span style={{ flex: 1, minWidth: 0, color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{row.name}</span>
                <span style={{ fontWeight: 600, color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.value)}</span>
                <span style={{ width: '40px', textAlign: 'right', color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>{total > 0 ? `${Math.round((row.value / total) * 100)}%` : '0%'}</span>
              </li>
            ))}
          </ul>
        </>
      )}
    </div>
  )
}

function ResultChip({ result }) {
  return <span className={result === 'PROFIT' ? 'badge-green' : result === 'LOSS' ? 'badge-red' : 'badge-gray'}>{humanize(result)}</span>
}

/** Reminders as rows like the Android app's: icon, title, crop and time, and a done button. */
function ReminderRows({ reminders, cropNames, onDone }) {
  const now = new Date()
  return (
    <ul style={{ listStyle: 'none', margin: 0, padding: 0 }}>
      {reminders.map((item) => {
        const Icon = REMINDER_ICONS[item.type] || BellIcon
        const overdue = new Date(item.reminderAt) < now
        return (
          <li key={item.id} style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '11px 0', borderTop: '1px solid var(--border)' }}>
            <span className="record-icon" style={{ width: 36, height: 36, background: 'color-mix(in srgb, var(--accent-lime) 13%, transparent)', color: 'var(--accent-lime)', flexShrink: 0 }}><Icon size={18} /></span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <Link to={`/crops/${item.cropId}`} style={{ fontSize: '15px', fontWeight: 600, color: 'var(--text-primary)', textDecoration: 'none' }}>{item.title}</Link>
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '2px 0 0' }}>
                {[cropNames[item.cropId], formatDateTime(item.reminderAt)].filter(Boolean).join(' · ')}
                {overdue && <span style={{ color: 'var(--loss)', fontWeight: 600 }}> · Overdue</span>}
              </p>
            </div>
            <button type="button" className="icon-btn" onClick={() => onDone(item)} aria-label={`Mark ${item.title} done`} title="Mark done">
              <CheckCircleIcon size={22} />
            </button>
          </li>
        )
      })}
    </ul>
  )
}

export default function DashboardPage() {
  const { user } = useAuth()
  const isMobile = useIsMobile()
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
  const [upcomingReminders, setUpcomingReminders] = useState([])
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
      await Promise.all([loadAlerts(), loadReminders()])
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
        cropId: crop.cropId, name: crop.cropName, status: crop.status, fieldLocation: crop.fieldLocation,
        aiInsightsEnabled: crop.aiInsightsEnabled,
        expenses: Number(crop.totalExpenses), revenue: Number(crop.totalRevenue),
        profit: Number(crop.netProfit), result: crop.result,
      }))
      setTotals(data.totals)
      setProfitData(rows)
      setDueReminders(data.dueReminders ?? [])
      setUpcomingReminders(data.upcomingReminders ?? [])
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

  // Moving a task can shift it between "due now" and "this week", so both
  // lists come back from the summary rather than being patched here.
  const loadReminders = async () => {
    try {
      const { data } = await getDashboardSummary()
      setDueReminders(data.dueReminders ?? [])
      setUpcomingReminders(data.upcomingReminders ?? [])
    } catch {
      // Keep what is on screen.
    }
  }

  const markReminderDone = async (reminder) => {
    try {
      await updateCropReminder(reminder.cropId, reminder.id, { completed: true })
      setDueReminders((prev) => prev.filter((item) => item.id !== reminder.id))
      setUpcomingReminders((prev) => prev.filter((item) => item.id !== reminder.id))
    } catch {
      // Leave the reminder in place so the user can retry.
    }
  }

  const totalRevenue = Number(totals?.totalRevenue ?? 0)
  const totalExpenses = Number(totals?.totalExpenses ?? 0)
  const netProfit = Number(totals?.netProfit ?? 0)
  const activeCrops = totals?.activeCrops ?? 0
  const totalCrops = totals?.totalCrops ?? 0
  const profitWord = netProfit >= 0 ? 'Profit' : 'Loss'
  const netSub = totalRevenue > 0 ? `${profitWord}, ${((netProfit / totalRevenue) * 100).toFixed(1)}% of revenue` : profitWord
  const cropNames = Object.fromEntries(profitData.map((row) => [row.cropId, row.name]))
  const revenueRows = profitData.filter((row) => row.revenue > 0).map((row) => ({ cropId: row.cropId, name: row.name, value: row.revenue }))
  const expenseRows = profitData.filter((row) => row.expenses > 0).map((row) => ({ cropId: row.cropId, name: row.name, value: row.expenses }))
  const firstName = (user?.fullName || '').trim().split(' ')[0]

  const renderInsightContent = (rawInsight) => {
    const lines = rawInsight.split('\n').map(l => l.replace(/\*\*/g, '').trim()).filter(l => l.length > 0)
    return lines.map((line, idx) => {
      if (line.startsWith('* ')) return (
        <div key={idx} style={{ display: 'flex', gap: '8px', alignItems: 'flex-start', marginBottom: '4px' }}>
          <span aria-hidden="true" style={{ color: 'var(--accent-lime)', marginTop: '1px' }}>•</span>
          <p style={{ fontSize: '14px', color: 'var(--text-primary)', lineHeight: 1.55, margin: 0 }}>{line.replace(/^\*\s+/, '')}</p>
        </div>
      )
      if (/^\d+\./.test(line)) return (
        <p key={idx} style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-primary)', margin: '6px 0 2px' }}>{line}</p>
      )
      return <p key={idx} style={{ fontSize: '14px', color: 'var(--text-muted)', lineHeight: 1.55, margin: '2px 0' }}>{line}</p>
    })
  }

  if (loading) {
    return (
      <Layout title={null}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '60vh', flexDirection: 'column', gap: '16px' }}>
          <div style={{ width: 36, height: 36, border: '3px solid var(--border)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <p style={{ color: 'var(--text-muted)', fontSize: '14px' }}>Loading dashboard…</p>
        </div>
      </Layout>
    )
  }

  return (
    <Layout title={null}>
      <header style={{ marginBottom: '20px' }}>
        <h1 style={{ fontSize: '26px', fontWeight: 800, color: 'var(--text-primary)', margin: 0 }}>{firstName ? `Ayubowan, ${firstName}` : 'Ayubowan'}</h1>
        <p style={{ ...panelSub, fontSize: '15px' }}>Here is how your farm is doing</p>
      </header>

      <div className="stat-tiles stat-tiles-4" style={{ '--tiles': 4, marginBottom: '20px' }}>
        <StatCard title="Harvest revenue" value={rupees(totalRevenue)} tone="good" icon={<PaymentsIcon />} sub="Sales from all crops" />
        <StatCard title="Total expenses" value={rupees(totalExpenses)} tone="bad" icon={<ReceiptIcon />} sub="Costs across all crops" />
        <StatCard title="Net profit" value={rupees(netProfit)} tone={netProfit >= 0 ? 'good' : 'bad'} icon={netProfit >= 0 ? <TrendUpIcon /> : <TrendDownIcon />} sub={netSub} />
        <StatCard title="Active crops" value={`${activeCrops}`} tone="brand" icon={<SproutIcon />} sub={`of ${totalCrops} crops`} />
      </div>

      {/* Weather risks to planned tasks sit high up: they are the only thing here that asks the farmer to do something */}
      <WeatherAlerts alerts={alerts} onMove={moveReminder} movingId={movingReminderId} />

      <div className="split" style={{ marginBottom: '20px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', minWidth: 0 }}>
          <section aria-labelledby="chart-title" style={panel}>
            <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'baseline', gap: '8px 16px' }}>
              <h2 id="chart-title" style={panelTitle}>Revenue vs expenses</h2>
              <div style={{ display: 'flex', gap: '16px' }}>
                <Legend color={chartColors.profit} label="Revenue" />
                <Legend color={chartColors.loss} label="Expenses" />
              </div>
            </div>
            {profitData.length === 0 ? (
              <p style={emptyText}>Add a crop and record its expenses and harvests to see them here.</p>
            ) : (
              <div style={{ marginTop: '16px' }}>
                <ResponsiveContainer width="100%" height={250}>
                  <BarChart data={profitData.slice(0, 8)} margin={{ top: 4, right: 4, bottom: 0, left: 0 }} barGap={4}>
                    <CartesianGrid vertical={false} stroke={chartColors.grid} />
                    <XAxis
                      dataKey="name"
                      interval={0}
                      tickFormatter={(name) => (isMobile && name.length > 9 ? `${name.slice(0, 8)}…` : name)}
                      tick={{ fill: chartColors.muted, fontSize: 12 }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis tickFormatter={shortRupees} tick={{ fill: chartColors.muted, fontSize: 12 }} axisLine={false} tickLine={false} width={44} />
                    <Tooltip content={<CustomTooltip />} cursor={{ fill: 'var(--bg-row-hover)' }} />
                    <Bar dataKey="revenue" name="Revenue" fill={chartColors.profit} radius={[4, 4, 0, 0]} maxBarSize={26} />
                    <Bar dataKey="expenses" name="Expenses" fill={chartColors.loss} radius={[4, 4, 0, 0]} maxBarSize={26} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </section>

          <section aria-labelledby="share-title" style={panel}>
            <h2 id="share-title" style={panelTitle}>Share by crop</h2>
            <p style={{ ...panelSub, marginBottom: '14px' }}>Where your revenue came from and where your costs went</p>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 240px), 1fr))', gap: '24px 32px' }}>
              <ShareDonut title="Revenue by crop" rows={revenueRows} total={totalRevenue} colors={chartColors.palette} emptyMessage="No harvests sold yet." />
              <ShareDonut title="Expenses by crop" rows={expenseRows} total={totalExpenses} colors={chartColors.palette} emptyMessage="No expenses recorded yet." />
            </div>
          </section>

          <section aria-labelledby="crops-title" style={panel}>
            <h2 id="crops-title" style={{ ...panelTitle, marginBottom: '8px' }}>Your crops</h2>
            {profitData.length === 0 ? (
              <p style={emptyText}>No crops added yet.</p>
            ) : isMobile ? (
              <ul style={{ listStyle: 'none', margin: 0, padding: 0 }}>
                {profitData.map((row) => (
                  <li key={row.cropId} style={{ padding: '12px 0', borderTop: '1px solid var(--border)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <Link to={`/crops/${row.cropId}`} style={{ flex: 1, minWidth: 0, fontSize: '15px', fontWeight: 600, color: 'var(--text-primary)', textDecoration: 'none' }}>{row.name}</Link>
                      <span style={{ fontWeight: 700, color: row.profit >= 0 ? 'var(--profit)' : 'var(--loss)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.profit)}</span>
                    </div>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '3px 0 0' }}>
                      {[humanize(row.status), `Revenue ${rupees(row.revenue)}`, `Expenses ${rupees(row.expenses)}`].filter(Boolean).join(' · ')}
                    </p>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="table-scroll">
                <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: '520px', fontSize: '14px' }}>
                  <thead>
                    <tr>
                      {['Crop', 'Revenue', 'Expenses', 'Profit', ''].map((h, i) => (
                        <th key={i} scope="col" style={{ padding: '10px 10px 10px 0', fontWeight: 500, color: 'var(--text-muted)', textAlign: i === 0 ? 'left' : 'right' }}>{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {profitData.map((row) => (
                      <tr key={row.cropId} style={{ borderTop: '1px solid var(--border)' }}>
                        <th scope="row" style={{ padding: '12px 10px 12px 0', textAlign: 'left', fontWeight: 400 }}>
                          <Link to={`/crops/${row.cropId}`} style={{ fontWeight: 600, color: 'var(--text-primary)', textDecoration: 'none' }}>{row.name}</Link>
                          {row.status && <span style={{ display: 'block', fontSize: '13px', color: 'var(--text-muted)' }}>{humanize(row.status)}</span>}
                        </th>
                        <td style={{ padding: '12px 10px 12px 0', textAlign: 'right', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.revenue)}</td>
                        <td style={{ padding: '12px 10px 12px 0', textAlign: 'right', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.expenses)}</td>
                        <td style={{ padding: '12px 10px 12px 0', textAlign: 'right', fontWeight: 700, color: row.profit >= 0 ? 'var(--profit)' : 'var(--loss)', fontVariantNumeric: 'tabular-nums' }}>{rupees(row.profit)}</td>
                        <td style={{ padding: '12px 0', textAlign: 'right' }}><ResultChip result={row.result} /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', minWidth: 0 }}>
          <section aria-labelledby="weather-title" style={panel}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: '12px', marginBottom: '12px' }}>
              <div style={{ minWidth: 0 }}>
                <h2 id="weather-title" style={panelTitle}>Weather</h2>
                <p style={panelSub}>{weatherCurrent?.location || user?.city || 'Your location'}</p>
              </div>
              <button type="button" onClick={loadWeather} style={textButton}>Refresh</button>
            </div>

            {loadingWeather ? (
              <p style={emptyText}>Loading weather…</p>
            ) : weatherError ? (
              <p style={{ fontSize: '14px', color: 'var(--loss)', padding: '12px 0', margin: 0 }}>{weatherError}</p>
            ) : weatherCurrent ? (
              <>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap', marginBottom: '14px' }}>
                  {weatherCurrent.iconUrl && <img src={weatherCurrent.iconUrl} alt="" style={{ width: 52, height: 52 }} />}
                  <div>
                    <div style={{ fontSize: '32px', fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1.1 }}>{Math.round(weatherCurrent.temperatureC ?? 0)}°C</div>
                    <div style={{ fontSize: '14px', color: 'var(--text-muted)' }}>{weatherCurrent.description || ''}</div>
                  </div>
                  <dl style={{ display: 'grid', gridTemplateColumns: 'auto auto', gap: '2px 12px', fontSize: '13px', margin: '0 0 0 auto' }}>
                    <dt style={{ color: 'var(--text-muted)' }}>Feels like</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{Math.round(weatherCurrent.feelsLikeC ?? 0)}°C</dd>
                    <dt style={{ color: 'var(--text-muted)' }}>Humidity</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{weatherCurrent.humidity ?? 0}%</dd>
                    <dt style={{ color: 'var(--text-muted)' }}>Wind</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{weatherCurrent.windSpeed ?? 0} m/s</dd>
                  </dl>
                </div>

                {weatherForecast.length > 0 && (
                  <div style={{ display: 'grid', gridTemplateColumns: `repeat(${Math.min(weatherForecast.length, 5)}, minmax(0, 1fr))`, gap: '6px' }}>
                    {weatherForecast.slice(0, 5).map((day) => (
                      <div key={day.date} style={{ textAlign: 'center', background: 'var(--bg-tile)', borderRadius: '12px', padding: '8px 2px' }}>
                        <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                          {new Date(`${day.date}T00:00:00`).toLocaleDateString('en-GB', { weekday: 'short' })}
                        </div>
                        {day.iconUrl && <img src={day.iconUrl} alt={day.description || ''} style={{ width: 30, height: 30, margin: '2px auto', display: 'block' }} />}
                        <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>
                          {Math.round(day.maxTempC ?? 0)}° <span style={{ fontWeight: 400, color: 'var(--text-muted)' }}>{Math.round(day.minTempC ?? 0)}°</span>
                        </div>
                        <div style={{ fontSize: '12px', color: 'var(--accent-blue)' }}>{day.rainChancePercent ?? 0}%</div>
                      </div>
                    ))}
                  </div>
                )}
              </>
            ) : (
              <p style={emptyText}>No weather data available.</p>
            )}
          </section>

          <section aria-labelledby="reminders-title" style={panel}>
            <h2 id="reminders-title" style={panelTitle}>Reminders</h2>
            <h3 style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-muted)', margin: '14px 0 4px' }}>Due now</h3>
            {dueReminders.length === 0
              ? <p style={{ ...emptyText, padding: '4px 0 0' }}>Nothing due right now.</p>
              : <ReminderRows reminders={dueReminders} cropNames={cropNames} onDone={markReminderDone} />}
            {upcomingReminders.length > 0 && (
              <>
                <h3 style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-muted)', margin: '18px 0 4px' }}>This week</h3>
                <ReminderRows reminders={upcomingReminders} cropNames={cropNames} onDone={markReminderDone} />
              </>
            )}
          </section>
        </div>
      </div>

      {profitData.length > 0 && (
        <section aria-labelledby="insights-title">
          <h2 id="insights-title" style={{ ...panelTitle, fontSize: '19px' }}>AI advice for each crop</h2>
          <p style={{ ...panelSub, marginBottom: '14px' }}>Based on each crop's figures and the weather at its field</p>

          {loadingInsights ? (
            <div style={{ ...panel, textAlign: 'center', padding: '40px' }}>
              <div style={{ width: 28, height: 28, border: '3px solid var(--border)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite', margin: '0 auto 12px' }} />
              <p style={{ fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>Reading your crops…</p>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: isMobile || profitData.length === 1 ? 'minmax(0, 1fr)' : 'repeat(2, minmax(0, 1fr))', gap: '20px' }}>
              {profitData.map((crop) => {
                const weather = cropWeatherById[crop.cropId]
                const insight = insights[crop.cropId]
                return (
                  <article key={crop.cropId} style={panel}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
                      <h3 style={{ ...panelTitle, fontSize: '16px' }}>{crop.name}</h3>
                      <span style={{ marginLeft: 'auto' }}><ResultChip result={crop.result} /></span>
                    </div>
                    <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '0 0 12px' }}>
                      {weather
                        ? `${weather.location || crop.fieldLocation || 'Field'}: ${Math.round(weather.temperatureC ?? 0)}°C, ${weather.description || ''}`
                        : `Weather not available for ${crop.fieldLocation || 'this field'}.`}
                    </p>

                    {insight && insight !== '__AI_OFF__' ? (
                      <div style={{ background: 'var(--bg-tile)', borderRadius: '12px', padding: '12px 14px' }}>
                        {renderInsightContent(insight)}
                      </div>
                    ) : insight === '__AI_OFF__' ? (
                      <p style={{ fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>
                        AI advice is off for this crop. <Link to={`/crops/${crop.cropId}`} style={{ color: 'var(--accent-lime)', fontWeight: 600 }}>Turn it on</Link>
                      </p>
                    ) : (
                      <p style={{ fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>No advice available right now.</p>
                    )}
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
