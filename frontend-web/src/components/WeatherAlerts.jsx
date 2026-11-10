const TYPE_ICON = {
  RAIN_WASHOFF: '🌧️',
  SPRAY_WIND: '💨',
  IRRIGATION_RAIN: '💧',
  HARVEST_RAIN: '🌾',
  HEAT_STRESS: '🌡️',
}

const TYPE_TITLE = {
  RAIN_WASHOFF: 'Rain may wash it off',
  SPRAY_WIND: 'Too windy to spray',
  IRRIGATION_RAIN: 'Rain will do the watering',
  HARVEST_RAIN: 'Rain on harvest day',
  HEAT_STRESS: 'Heat stress',
}

const SEVERITY_COLOR = { HIGH: '#f87171', MEDIUM: '#f59e0b' }

const font = 'Inter, system-ui, -apple-system, Segoe UI, sans-serif'

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
      style={{ background: 'var(--bg-card)', border: '1px solid rgba(245,158,11,0.35)', borderRadius: '16px', padding: '20px', marginBottom: '20px' }}
    >
      <div style={{ fontFamily: 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif', fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', marginBottom: '14px' }}>
        Weather alerts for your plans
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {alerts.map((alert) => {
          const color = SEVERITY_COLOR[alert.severity] || SEVERITY_COLOR.MEDIUM
          const key = `${alert.type}-${alert.reminderId ?? alert.location}-${alert.date}`
          const canMove = alert.reminderId && alert.suggestedAt
          return (
            <div
              key={key}
              style={{ display: 'flex', gap: '12px', alignItems: 'flex-start', padding: '12px 14px', borderRadius: '12px', background: `${color}14`, border: `1px solid ${color}40` }}
            >
              <span aria-hidden="true" style={{ fontSize: '22px', lineHeight: 1 }}>{TYPE_ICON[alert.type] || '⚠️'}</span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: font, fontSize: '13px', fontWeight: 700, color }}>
                  {TYPE_TITLE[alert.type] || 'Weather risk'}
                  {alert.reminderTitle ? ` · ${alert.reminderTitle}` : ''}
                </div>
                <p style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', margin: '4px 0 0', lineHeight: 1.5 }}>
                  {alert.message}
                </p>
                {canMove && (
                  <button
                    type="button"
                    onClick={() => onMove(alert)}
                    disabled={movingId === alert.reminderId}
                    className="agro-btn"
                    style={{ marginTop: '10px', padding: '6px 14px', fontSize: '12px' }}
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
