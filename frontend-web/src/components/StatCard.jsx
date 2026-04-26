const ICON_MAP = { green: '🌾', red: '💸', blue: '📈', amber: '⚠️' }
const COLOR_MAP = { green: 'var(--accent-lime)', red: 'var(--accent-red)', blue: 'var(--accent-blue)', amber: 'var(--accent-amber)' }

export default function StatCard({ title, value, sub, color = 'green', icon }) {
  const accent = COLOR_MAP[color] || 'var(--accent-lime)'
  const displayIcon = icon || ICON_MAP[color] || '📊'

  return (
    <div
      style={{
        background: 'var(--bg-card)',
        border: '1px solid var(--border)',
        borderRadius: '16px', padding: '24px',
        backdropFilter: 'blur(12px)',
        transition: 'all 0.3s', flex: 1,
        cursor: 'default',
      }}
      onMouseEnter={e => {
        e.currentTarget.style.borderColor = 'var(--border-hover)'
        e.currentTarget.style.transform = 'translateY(-2px)'
        e.currentTarget.style.boxShadow = '0 8px 32px rgba(74,222,128,0.08)'
      }}
      onMouseLeave={e => {
        e.currentTarget.style.borderColor = 'var(--border)'
        e.currentTarget.style.transform = 'translateY(0)'
        e.currentTarget.style.boxShadow = 'none'
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
        <span style={{ fontFamily: 'Inter', fontSize: '13px', color: 'var(--text-muted)', fontWeight: 500 }}>
          {title}
        </span>
        <span style={{ fontSize: '20px' }}>{displayIcon}</span>
      </div>
      <div style={{
        fontFamily: 'Space Grotesk, sans-serif',
        fontSize: '28px', fontWeight: 800,
        color: accent, letterSpacing: '-1px', marginBottom: '8px',
      }}>{value}</div>
      {sub && (
        <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-faint)' }}>{sub}</div>
      )}
    </div>
  )
}
