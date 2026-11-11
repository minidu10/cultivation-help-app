const TONE_COLOR = {
  good: 'var(--profit)',
  bad: 'var(--loss)',
  brand: 'var(--accent-lime)',
  neutral: 'var(--text-primary)',
}

/**
 * One figure on a card, laid out like the Android app's stat tile: the label
 * with an icon beside it, the value in the tile's colour, then a short line.
 */
export default function StatCard({ title, value, sub, tone = 'neutral', icon }) {
  const color = TONE_COLOR[tone] || TONE_COLOR.neutral
  return (
    <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--radius-card)', padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: '6px', minWidth: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px' }}>
        <span style={{ fontSize: '14px', fontWeight: 500, color: 'var(--text-muted)' }}>{title}</span>
        {icon && <span style={{ color: tone === 'neutral' ? 'var(--text-muted)' : color }}>{icon}</span>}
      </div>
      <div style={{ fontSize: 'clamp(19px, 4.6vw, 26px)', fontWeight: 700, lineHeight: 1.2, color, fontVariantNumeric: 'tabular-nums', overflowWrap: 'break-word' }}>
        {value}
      </div>
      {sub && <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{sub}</div>}
    </div>
  )
}
