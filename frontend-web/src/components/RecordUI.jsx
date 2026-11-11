import { useEffect, useId } from 'react'
import { PencilIcon, PlusIcon, TrashIcon } from './Icons'
import { card } from './surfaces'

// Pieces shared by the expense and harvest pages, modelled on the Android
// app's record list: a crop picker and add button, then one card holding a
// row per record, each with an icon, its details and the amount.

const fieldLabel = { display: 'block', fontSize: '13px', fontWeight: 500, color: 'var(--text-muted)', marginBottom: '6px' }

const TONE_COLOR = { good: 'var(--profit)', bad: 'var(--loss)', brand: 'var(--accent-lime)', neutral: 'var(--text-primary)' }

export function CropPicker({ crops, value, onChange }) {
  const id = useId()
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0, flex: '0 1 auto' }}>
      <label htmlFor={id} style={{ fontSize: '14px', fontWeight: 500, color: 'var(--text-muted)' }}>Crop</label>
      <select id={id} value={value} onChange={(e) => onChange(e.target.value)} className="agro-input" style={{ width: 'auto', minWidth: 0, maxWidth: '100%', padding: '10px 14px', fontWeight: 600, fontSize: '15px', cursor: 'pointer' }}>
        {crops.map((crop) => <option key={crop.id} value={crop.id}>{crop.name}{crop.variety ? ` (${crop.variety})` : ''}</option>)}
      </select>
    </div>
  )
}

export function AddButton({ children, ...rest }) {
  return (
    <button type="button" className="agro-btn" style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '11px 18px' }} {...rest}>
      <PlusIcon size={18} />
      {children}
    </button>
  )
}

export function Toolbar({ children }) {
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '12px', marginBottom: '20px' }}>
      {children}
    </div>
  )
}

export function Tiles({ children }) {
  return <div className="stat-tiles" style={{ marginBottom: '20px' }}>{children}</div>
}

/** A titled card with the records as a divided list. */
export function RecordList({ title, aside, children }) {
  return (
    <section style={card} aria-label={title}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: '12px', padding: '18px 20px 6px' }}>
        <h2 style={{ fontSize: '17px', fontWeight: 700, color: 'var(--text-primary)', margin: 0 }}>{title}</h2>
        {aside && <span style={{ fontSize: '14px', color: 'var(--text-muted)' }}>{aside}</span>}
      </div>
      <ul style={{ listStyle: 'none', margin: 0, padding: '0 0 6px' }}>{children}</ul>
    </section>
  )
}

export function RecordRow({ icon, tone = 'brand', title, details, note, amount, amountTone = 'neutral', editLabel, deleteLabel, onEdit, onDelete }) {
  const color = TONE_COLOR[tone]
  return (
    <li className="record-row">
      <span className="record-icon" style={{ background: `color-mix(in srgb, ${color} 13%, transparent)`, color }}>{icon}</span>
      <div style={{ minWidth: 0 }}>
        <p style={{ margin: 0, fontSize: '15px', fontWeight: 600, color: 'var(--text-primary)', overflowWrap: 'anywhere' }}>{title}</p>
        <p style={{ margin: '2px 0 0', fontSize: '13px', color: 'var(--text-muted)' }}>{details}</p>
        {note && <p style={{ margin: '2px 0 0', fontSize: '13px', color: 'var(--text-faint)' }}>{note}</p>}
      </div>
      <span className="record-amount" style={{ color: TONE_COLOR[amountTone] }}>{amount}</span>
      <div className="record-actions">
        <button type="button" className="icon-btn" onClick={onEdit} aria-label={editLabel} title="Edit"><PencilIcon size={18} /></button>
        <button type="button" className="icon-btn icon-btn-danger" onClick={onDelete} aria-label={deleteLabel} title="Delete"><TrashIcon size={18} /></button>
      </div>
    </li>
  )
}

export function EmptyState({ title, text, action }) {
  return (
    <div style={{ ...card, padding: '48px 24px', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
      <p style={{ margin: 0, fontSize: '17px', fontWeight: 600, color: 'var(--text-primary)' }}>{title}</p>
      {text && <p style={{ margin: 0, fontSize: '14px', color: 'var(--text-muted)', maxWidth: '420px' }}>{text}</p>}
      {action && <div style={{ marginTop: '10px' }}>{action}</div>}
    </div>
  )
}

/** The add and edit form. Escape closes it, like the Android bottom sheet's back gesture. */
export function Modal({ title, onClose, children }) {
  const titleId = useId()
  useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose])

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(12, 20, 13, 0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: '16px' }}>
      <div role="dialog" aria-modal="true" aria-labelledby={titleId} className="modal-card" style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--radius-card)', padding: '26px', width: '520px', maxWidth: '100%', maxHeight: '90vh', overflowY: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
          <h2 id={titleId} style={{ fontWeight: 700, fontSize: '20px', color: 'var(--text-primary)', margin: 0 }}>{title}</h2>
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Close">
            <svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round"><path d="M6 6l12 12" /><path d="M18 6L6 18" /></svg>
          </button>
        </div>
        {children}
      </div>
    </div>
  )
}

/** A labelled form control; `wide` makes it span both columns of the form. */
export function Field({ label, wide, children }) {
  return (
    <label className={wide ? 'span-2' : undefined} style={{ display: 'block' }}>
      <span style={fieldLabel}>{label}</span>
      {children}
    </label>
  )
}

export function FormActions({ submitting, submitLabel, onCancel }) {
  return (
    <div style={{ display: 'flex', gap: '10px', justifyContent: 'flex-end', marginTop: '22px' }}>
      <button type="button" onClick={onCancel} className="ghost-btn">Cancel</button>
      <button type="submit" disabled={submitting} className="agro-btn">{submitting ? 'Saving…' : submitLabel}</button>
    </div>
  )
}
