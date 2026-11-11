const TONE_COLOR = {
  good: 'var(--accent-lime)',
  bad: 'var(--accent-red)',
  neutral: 'var(--text-primary)',
}

/** One figure on a tinted tile: label, value, and an optional line under it. */
export default function StatCard({ title, value, sub, tone = 'neutral', subTone }) {
  return (
    <div style={{ background: 'var(--bg-tile)', borderRadius: 'var(--radius-control)', padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: '4px', minWidth: 0 }}>
      <div>
        <span style={{ fontSize: '14px', color: 'var(--text-muted)' }}>{title}</span>
      </div>
      <div style={{ fontSize: '28px', fontWeight: 700, lineHeight: 1.2, color: TONE_COLOR[tone] || TONE_COLOR.neutral, letterSpacing: '-0.01em', fontVariantNumeric: 'tabular-nums', overflowWrap: 'break-word' }}>
        {value}
      </div>
      {sub && (
        <div style={{ fontSize: '13px', color: subTone ? TONE_COLOR[subTone] : 'var(--text-muted)' }}>{sub}</div>
      )}
    </div>
  )
}
