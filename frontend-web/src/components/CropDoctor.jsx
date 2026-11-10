import { useEffect, useRef, useState } from 'react'
import { deleteDiagnosis, diagnosePhoto, getDiagnoses, getThumbnail } from '../api/diagnoses'
import { resizePhoto } from '../utils/resizePhoto'

const font = 'Inter, system-ui, -apple-system, Segoe UI, sans-serif'
const heading = 'Space Grotesk, Inter, system-ui, Segoe UI, sans-serif'

const cardStyle = { background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: '16px', backdropFilter: 'blur(12px)', padding: '24px', marginBottom: '20px' }

const SEVERITY = {
  none: { label: 'Healthy', color: '#4ade80' },
  low: { label: 'Mild', color: '#a3e635' },
  moderate: { label: 'Moderate', color: '#f59e0b' },
  severe: { label: 'Severe', color: '#f87171' },
}

function apiMessage(err, fallback) {
  return err?.response?.data?.message || fallback
}

/** A thumbnail fetched with the session's token and shown from a blob URL. */
function Thumbnail({ url, alt }) {
  const [src, setSrc] = useState(null)

  useEffect(() => {
    if (!url) return undefined
    let objectUrl = null
    let cancelled = false
    getThumbnail(url)
      .then((res) => {
        if (cancelled) return
        objectUrl = URL.createObjectURL(res.data)
        setSrc(objectUrl)
      })
      .catch(() => {})
    return () => {
      cancelled = true
      if (objectUrl) URL.revokeObjectURL(objectUrl)
    }
  }, [url])

  return (
    <div style={{ width: 56, height: 56, borderRadius: '10px', overflow: 'hidden', background: 'var(--bg-input)', flexShrink: 0 }}>
      {src && <img src={src} alt={alt} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />}
    </div>
  )
}

function List({ title, items, tone }) {
  if (!items?.length) return null
  return (
    <div style={{ marginTop: '12px' }}>
      <div style={{ fontFamily: font, fontSize: '12px', fontWeight: 700, color: tone || 'var(--text-primary)', textTransform: 'uppercase', letterSpacing: '0.4px', marginBottom: '4px' }}>{title}</div>
      <ul style={{ margin: 0, paddingLeft: '18px' }}>
        {items.map((item) => (
          <li key={item} style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', lineHeight: 1.6 }}>{item}</li>
        ))}
      </ul>
    </div>
  )
}

/** The full answer for one photo. */
export function DiagnosisResult({ result }) {
  if (!result.isPlant) {
    return (
      <div role="status" style={{ padding: '14px 16px', borderRadius: '12px', background: 'rgba(245,158,11,0.1)', border: '1px solid rgba(245,158,11,0.3)' }}>
        <div style={{ fontFamily: font, fontSize: '14px', fontWeight: 700, color: '#f59e0b' }}>We could not see a plant clearly</div>
        <ul style={{ margin: '6px 0 0', paddingLeft: '18px', fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', lineHeight: 1.6 }}>
          <li>Fill the frame with one affected leaf or fruit</li>
          <li>Take it in daylight, without flash</li>
          <li>Hold the phone steady so the spots are sharp</li>
        </ul>
      </div>
    )
  }

  const severity = SEVERITY[result.severity] || SEVERITY.moderate
  const percent = Math.round((result.confidence ?? 0) * 100)
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: '10px', flexWrap: 'wrap' }}>
        <div style={{ fontFamily: heading, fontSize: '20px', fontWeight: 800, color: 'var(--text-primary)' }}>{result.condition}</div>
        <span style={{ fontFamily: font, fontSize: '11px', fontWeight: 700, color: severity.color, background: `${severity.color}20`, border: `1px solid ${severity.color}50`, borderRadius: '100px', padding: '2px 10px' }}>
          {severity.label}
        </span>
      </div>
      {result.cropGuess && (
        <div style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-faint)', marginTop: '2px' }}>Looks like {result.cropGuess}</div>
      )}
      <div style={{ marginTop: '10px' }}>
        <div style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-muted)', marginBottom: '4px' }}>Confidence {percent}%</div>
        <div role="meter" aria-label="Confidence" aria-valuenow={percent} aria-valuemin={0} aria-valuemax={100}
          style={{ height: '6px', borderRadius: '6px', background: 'var(--bg-input)', overflow: 'hidden' }}>
          <div style={{ width: `${percent}%`, height: '100%', background: percent >= 70 ? '#4ade80' : percent >= 50 ? '#f59e0b' : '#f87171' }} />
        </div>
      </div>

      {result.seeExpert && (
        <div role="alert" style={{ marginTop: '12px', padding: '10px 12px', borderRadius: '10px', background: 'rgba(96,165,250,0.12)', border: '1px solid rgba(96,165,250,0.35)', fontFamily: font, fontSize: '13px', color: '#60a5fa' }}>
          Show this to your local Agrarian Service Centre or agriculture extension officer before you spray anything.
        </div>
      )}

      <List title="What we see" items={result.symptoms} />
      <List title="Organic treatment" items={result.treatmentOrganic} tone="#4ade80" />
      <List title="Chemical options" items={result.treatmentChemical} tone="#f59e0b" />
      {result.treatmentChemical?.length > 0 && (
        <p style={{ fontFamily: font, fontSize: '11px', color: 'var(--text-faint)', margin: '4px 0 0' }}>
          Follow the product label for dose and waiting period, and wear gloves and a mask.
        </p>
      )}
      <List title="Prevention" items={result.prevention} />
    </div>
  )
}

/**
 * Photograph a sick leaf, get a likely diagnosis. Results are kept per crop,
 * so the farmer can see whether a treatment worked.
 */
export default function CropDoctor({ cropId }) {
  const [history, setHistory] = useState([])
  const [result, setResult] = useState(null)
  const [openId, setOpenId] = useState(null)
  const [note, setNote] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const input = useRef(null)

  useEffect(() => {
    let cancelled = false
    getDiagnoses(cropId)
      .then((res) => { if (!cancelled) setHistory(res.data) })
      .catch(() => {})
    return () => { cancelled = true }
  }, [cropId])

  const onPhoto = async (event) => {
    const file = event.target.files?.[0]
    event.target.value = ''
    if (!file) return
    setBusy(true)
    setError('')
    setResult(null)
    try {
      const photo = await resizePhoto(file)
      const { data } = await diagnosePhoto(cropId, photo, note)
      setResult(data)
      setNote('')
      if (data.id) setHistory((prev) => [data, ...prev])
    } catch (err) {
      setError(apiMessage(err, 'The photo could not be checked. Please try again.'))
    } finally {
      setBusy(false)
    }
  }

  const remove = async (diagnosis) => {
    if (!window.confirm(`Delete the ${diagnosis.condition} check from ${new Date(diagnosis.createdAt).toLocaleDateString('en-GB')}?`)) return
    try {
      await deleteDiagnosis(cropId, diagnosis.id)
      setHistory((prev) => prev.filter((d) => d.id !== diagnosis.id))
      if (result?.id === diagnosis.id) setResult(null)
    } catch (err) {
      setError(apiMessage(err, 'Could not delete that check.'))
    }
  }

  return (
    <section aria-label="Crop doctor" style={cardStyle}>
      <div style={{ fontFamily: heading, fontWeight: 700, fontSize: '16px', color: 'var(--text-primary)', marginBottom: '4px' }}>🩺 Crop doctor</div>
      <p style={{ fontFamily: font, fontSize: '13px', color: 'var(--text-muted)', margin: '0 0 14px' }}>
        Photograph a sick leaf, fruit or stem and get a likely cause with treatment options.
      </p>

      <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'center' }}>
        <input
          value={note}
          onChange={(e) => setNote(e.target.value)}
          maxLength={300}
          placeholder="Optional: what you noticed (e.g. spots spreading after rain)"
          aria-label="Note about the photo"
          style={{ flex: '1 1 260px', boxSizing: 'border-box', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 14px', fontFamily: font, fontSize: '14px', color: 'var(--text-primary)' }}
        />
        <input
          ref={input}
          type="file"
          accept="image/jpeg,image/png"
          capture="environment"
          onChange={onPhoto}
          aria-label="Choose a photo"
          style={{ display: 'none' }}
        />
        <button type="button" className="agro-btn" disabled={busy} onClick={() => input.current?.click()} style={{ padding: '10px 18px', fontSize: '14px' }}>
          {busy ? 'Checking the photo…' : '📷 Check a photo'}
        </button>
      </div>

      {busy && (
        <p role="status" style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-faint)', marginTop: '10px' }}>
          This can take up to a minute.
        </p>
      )}
      {error && (
        <div role="alert" style={{ marginTop: '12px', padding: '10px 12px', borderRadius: '10px', background: 'rgba(248,113,113,0.1)', border: '1px solid rgba(248,113,113,0.3)', fontFamily: font, fontSize: '13px', color: '#f87171' }}>
          {error}
        </div>
      )}

      {result && (
        <div style={{ marginTop: '16px', paddingTop: '16px', borderTop: '1px solid var(--border)' }}>
          <DiagnosisResult result={result} />
        </div>
      )}

      {history.length > 0 && (
        <div style={{ marginTop: '20px' }}>
          <div style={{ fontFamily: font, fontSize: '12px', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '8px' }}>Past checks</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {history.map((d) => (
              <div key={d.id} style={{ background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '12px', padding: '10px' }}>
                <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                  <Thumbnail url={d.thumbnailUrl} alt={`Photo checked for ${d.condition}`} />
                  <button
                    type="button"
                    onClick={() => setOpenId(openId === d.id ? null : d.id)}
                    aria-expanded={openId === d.id}
                    style={{ flex: 1, textAlign: 'left', background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}
                  >
                    <div style={{ fontFamily: font, fontSize: '14px', fontWeight: 600, color: 'var(--text-primary)' }}>{d.condition}</div>
                    <div style={{ fontFamily: font, fontSize: '12px', color: 'var(--text-faint)' }}>
                      {new Date(d.createdAt).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })} · {Math.round(d.confidence * 100)}% confidence
                    </div>
                  </button>
                  <button type="button" onClick={() => remove(d)} aria-label={`Delete ${d.condition} check`}
                    style={{ background: 'none', border: '1px solid var(--border)', borderRadius: '8px', padding: '5px 10px', fontFamily: font, fontSize: '12px', color: '#f87171', cursor: 'pointer' }}>
                    Delete
                  </button>
                </div>
                {openId === d.id && <div style={{ marginTop: '12px' }}><DiagnosisResult result={d} /></div>}
              </div>
            ))}
          </div>
        </div>
      )}

      <p style={{ fontFamily: font, fontSize: '11px', color: 'var(--text-faint)', margin: '16px 0 0' }}>
        AI suggestions can be wrong. Only a small copy of each photo is kept, without its location data.
      </p>
    </section>
  )
}
