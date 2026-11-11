// Line icons, drawn in the alert's own colour.
const ICON_PATHS = {
  rain: ['M7 15a4 4 0 0 1-.6-7.95A5.5 5.5 0 0 1 17.2 8.6 3.5 3.5 0 0 1 17 15', 'M8 18l-1 3', 'M12 18l-1 3', 'M16 18l-1 3'],
  wind: ['M3 8h11a3 3 0 1 0-3-3', 'M3 12h16a3 3 0 1 1-3 3', 'M3 16h8'],
  drop: ['M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z'],
  heat: ['M12 14V4a2 2 0 1 0-4 0v10a4 4 0 1 0 4 0z', 'M16 7h4', 'M16 11h3'],
}

const TYPE_ICON = {
  RAIN_WASHOFF: 'rain',
  SPRAY_WIND: 'wind',
  IRRIGATION_RAIN: 'drop',
  HARVEST_RAIN: 'rain',
  HEAT_STRESS: 'heat',
}

function AlertIcon({ type, color }) {
  const paths = ICON_PATHS[TYPE_ICON[type]] || ICON_PATHS.rain
  return (
    <svg aria-hidden="true" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 1 }}>
      {paths.map((d) => <path key={d} d={d} />)}
    </svg>
  )
}

const TYPE_TITLE = {
  RAIN_WASHOFF: 'Rain may wash it off',
  SPRAY_WIND: 'Too windy to spray',
  IRRIGATION_RAIN: 'Rain will do the watering',
  HARVEST_RAIN: 'Rain on harvest day',
  HEAT_STRESS: 'Heat stress',
}

const SEVERITY_COLOR = { HIGH: 'var(--accent-red)', MEDIUM: 'var(--accent-amber)' }

const font = 'var(--font-body)'

/** "Sat 25 Oct, 9:00 AM" from the server's zone-less local time. */
function formatSuggestion(localDateTime) {
  const date = new Date(localDateTime)
  const day = date.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short' })
  const time = date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
  return `${day}, ${time}`
}

/**
 * Tasks the forecast puts at risk, worst first, each with a one-tap fix
 * where the server found a better time. Renders nothing when all is well.
 */
export default function WeatherAlerts({ alerts, onMove, movingId }) {
  if (!alerts?.length) return null

  return (
    <section
      aria-label="Weather alerts"
      style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--radius-card)', padding: '20px 22px', marginBottom: '20px' }}
    >
      <div style={{ fontFamily: font, fontWeight: 700, fontSize: '17px', color: 'var(--text-primary)', marginBottom: '4px' }}>
        Weather alerts for your plans
      </div>
      <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-muted)', margin: '0 0 14px' }}>
        Planned jobs the 5-day forecast puts at risk.
      </p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {alerts.map((alert) => {
          const color = SEVERITY_COLOR[alert.severity] || SEVERITY_COLOR.MEDIUM
          const key = `${alert.type}-${alert.reminderId ?? alert.location}-${alert.date}`
          const canMove = alert.reminderId && alert.suggestedAt
          return (
            <div
              key={key}
              style={{ display: 'flex', gap: '12px', alignItems: 'flex-start', padding: '14px 16px', borderRadius: '12px', background: `color-mix(in srgb, ${color} 9%, var(--bg-card))` }}
            >
              <AlertIcon type={alert.type} color={color} />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: font, fontSize: '14px', fontWeight: 700, color }}>
                  {TYPE_TITLE[alert.type] || 'Weather risk'}
                  {alert.reminderTitle ? ` · ${alert.reminderTitle}` : ''}
                </div>
                <p style={{ fontFamily: font, fontSize: '14px', color: 'var(--text-primary)', margin: '4px 0 0', lineHeight: 1.5 }}>
                  {alert.message}
                </p>
                {canMove && (
                  <button
                    type="button"
                    onClick={() => onMove(alert)}
                    disabled={movingId === alert.reminderId}
                    className="agro-btn"
                    style={{ marginTop: '10px', padding: '8px 14px', fontSize: '13px' }}
                  >
                    {movingId === alert.reminderId ? 'Moving…' : `Move to ${formatSuggestion(alert.suggestedAt)}`}
                  </button>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </section>
  )
}
