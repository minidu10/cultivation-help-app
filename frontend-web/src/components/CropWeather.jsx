import { useEffect, useState } from 'react'
import { getCurrentWeatherByLocation, getDailyForecastByLocation } from '../api/weather'

const card = {
  background: 'var(--bg-card)', border: '1px solid var(--border)',
  borderRadius: '16px', padding: '24px',
}

/** Current weather and the five-day forecast for one crop's field. */
export default function CropWeather({ location }) {
  const place = location?.trim()
  const [state, setState] = useState({ place: null, error: '', current: null, days: [] })

  useEffect(() => {
    if (!place) return undefined
    let cancelled = false
    Promise.all([getCurrentWeatherByLocation(place), getDailyForecastByLocation(place)])
      .then(([cur, daily]) => {
        if (!cancelled) setState({ place, error: '', current: cur.data, days: daily.data?.days ?? [] })
      })
      .catch(() => {
        if (!cancelled) setState({ place, error: `Weather is not available for ${place}.`, current: null, days: [] })
      })
    return () => { cancelled = true }
  }, [place])

  const { error, current, days } = state
  const loading = state.place !== place
  const muted = { fontSize: '14px', color: 'var(--text-muted)', margin: 0 }

  return (
    <section aria-labelledby="crop-weather-title" style={{ ...card, marginBottom: '20px' }}>
      <h2 id="crop-weather-title" style={{ fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', margin: '0 0 4px' }}>Field weather</h2>
      <p style={{ ...muted, fontSize: '13px', marginBottom: '16px' }}>{place || 'No field location set for this crop.'}</p>

      {!place ? null : loading ? (
        <p style={muted}>Loading weather…</p>
      ) : error ? (
        <p style={{ ...muted, color: 'var(--loss)' }}>{error}</p>
      ) : (
        <>
          {current && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flexWrap: 'wrap', marginBottom: '16px' }}>
              {current.iconUrl && <img src={current.iconUrl} alt="" style={{ width: 52, height: 52 }} />}
              <div>
                <div style={{ fontSize: '32px', fontWeight: 700, color: 'var(--text-primary)', lineHeight: 1.1 }}>{Math.round(current.temperatureC ?? 0)}°C</div>
                <div style={muted}>{current.description || ''}</div>
              </div>
              <dl style={{ display: 'grid', gridTemplateColumns: 'auto auto', gap: '2px 12px', fontSize: '13px', margin: '0 0 0 auto' }}>
                <dt style={{ color: 'var(--text-muted)' }}>Feels like</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{Math.round(current.feelsLikeC ?? 0)}°C</dd>
                <dt style={{ color: 'var(--text-muted)' }}>Humidity</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{current.humidity ?? 0}%</dd>
                <dt style={{ color: 'var(--text-muted)' }}>Wind</dt><dd style={{ margin: 0, color: 'var(--text-primary)' }}>{current.windSpeed ?? 0} m/s</dd>
              </dl>
            </div>
          )}
          {days.length > 0 && (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(76px, 1fr))', gap: '8px' }}>
              {days.slice(0, 5).map((day) => (
                <div key={day.date} style={{ textAlign: 'center', background: 'var(--bg-tile)', borderRadius: '12px', padding: '10px 4px' }}>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                    {new Date(`${day.date}T00:00:00`).toLocaleDateString('en-GB', { weekday: 'short' })}
                  </div>
                  {day.iconUrl && <img src={day.iconUrl} alt={day.description || ''} style={{ width: 32, height: 32, margin: '2px auto', display: 'block' }} />}
                  <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-primary)' }}>
                    {Math.round(day.maxTempC ?? 0)}° <span style={{ fontWeight: 400, color: 'var(--text-muted)' }}>{Math.round(day.minTempC ?? 0)}°</span>
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--accent-blue)' }}>{day.rainChancePercent ?? 0}%</div>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </section>
  )
}
