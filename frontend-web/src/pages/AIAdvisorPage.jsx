import { Fragment, useEffect, useRef, useState } from 'react'
import Layout from '../components/Layout'
import { SendIcon } from '../components/Icons'
import { askAI, getAIHealth, getCrops } from '../api/crops'
import { apiError } from '../utils/password'
import logo from '../assets/logo.png'

const SUGGESTIONS = [
  'How much urea should I apply to paddy?',
  'How do I control fall armyworm in maize?',
  'When should I irrigate chilli in the dry season?',
  'How can I cut my production costs?',
]

// The server caps context at 2,000 characters; staying under it means
// nothing important is cut off mid-crop.
const MAX_CONTEXT = 1900
const FINISHED = ['HARVESTED', 'FAILED']

/**
 * One line per crop, active ones first: the same context the Android app
 * sends, so the farmer never types "I grow paddy in Polonnaruwa" before
 * every question.
 */
function describeCrops(crops) {
  const ordered = [...crops].sort((a, b) => Number(FINISHED.includes(a.status)) - Number(FINISHED.includes(b.status)))
  let text = ''
  for (const crop of ordered) {
    const parts = [
      crop.name,
      crop.variety && `variety ${crop.variety}`,
      crop.status && crop.status.toLowerCase().replaceAll('_', ' '),
      crop.plantingDate && `planted ${crop.plantingDate}`,
      crop.fieldSizeAcres && `${crop.fieldSizeAcres} acres`,
      crop.fieldLocation && `at ${crop.fieldLocation}`,
    ].filter(Boolean)
    const line = `${parts.join(', ')}.\n`
    if (text.length + line.length > MAX_CONTEXT) break
    text += line
  }
  return text.trim()
}

/** Answers come back with light markdown: bold runs and "* " bullets. */
function AnswerText({ text }) {
  return text.split('\n').map((raw, i) => {
    const bullet = /^\s*[*-]\s+/.test(raw)
    const line = raw.replace(/^\s*[*-]\s+/, '')
    const pieces = line.split(/\*\*(.+?)\*\*/g).map((piece, j) => (j % 2 ? <strong key={j}>{piece}</strong> : <Fragment key={j}>{piece}</Fragment>))
    if (!line.trim()) return <div key={i} style={{ height: '8px' }} />
    return bullet
      ? <div key={i} style={{ display: 'flex', gap: '8px' }}><span aria-hidden="true">•</span><span>{pieces}</span></div>
      : <div key={i}>{pieces}</div>
  })
}

function Bubble({ message }) {
  const mine = message.role === 'user'
  const background = mine ? 'var(--accent-lime)' : message.error ? 'color-mix(in srgb, var(--loss) 12%, var(--bg-card))' : 'var(--bg-tile)'
  const color = mine ? 'var(--on-accent)' : message.error ? 'var(--loss)' : 'var(--text-primary)'
  return (
    <div style={{ display: 'flex', justifyContent: mine ? 'flex-end' : 'flex-start', alignItems: 'flex-end', gap: '8px' }}>
      {!mine && <img src={logo} alt="" width="28" height="28" style={{ display: 'block', flexShrink: 0 }} />}
      <div style={{
        maxWidth: 'min(78%, 680px)', background, color, padding: '11px 15px', fontSize: '15px', lineHeight: 1.55,
        borderRadius: mine ? '18px 18px 4px 18px' : '18px 18px 18px 4px', overflowWrap: 'anywhere',
      }}>
        {message.pending ? (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', color: 'var(--text-muted)' }}>
            <span aria-hidden="true" style={{ width: 14, height: 14, border: '2px solid var(--border-hover)', borderTopColor: 'var(--accent-lime)', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
            Thinking…
          </span>
        ) : mine ? message.text : <AnswerText text={message.text} />}
      </div>
    </div>
  )
}

export default function AIAdvisorPage() {
  const [messages, setMessages] = useState([])
  const [input, setInput] = useState('')
  const [thinking, setThinking] = useState(false)
  // null while the first health check is in flight.
  const [health, setHealth] = useState(null)
  const [cropContext, setCropContext] = useState('')
  const listRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    let cancelled = false
    getAIHealth()
      .then(({ data }) => { if (!cancelled) setHealth({ up: data.status === 'UP', configured: data.configured }) })
      .catch(() => { if (!cancelled) setHealth({ up: false, configured: false }) })
    // Without the crop list the advisor still answers, just less specifically.
    getCrops()
      .then(({ data }) => { if (!cancelled) setCropContext(describeCrops(data)) })
      .catch(() => {})
    return () => { cancelled = true }
  }, [])

  useEffect(() => {
    const list = listRef.current
    if (list) list.scrollTop = list.scrollHeight
  }, [messages, thinking])

  const send = async (text) => {
    const question = (text ?? input).trim()
    if (!question || thinking) return
    setMessages((prev) => [...prev, { role: 'user', text: question }])
    setInput('')
    setThinking(true)
    try {
      const res = await askAI(question, cropContext)
      const answer = res.data?.answer?.trim()
      setMessages((prev) => [...prev, answer
        ? { role: 'ai', text: answer }
        : { role: 'ai', text: 'The advisor sent back an empty answer. Try asking again.', error: true }])
    } catch (err) {
      setMessages((prev) => [...prev, { role: 'ai', text: apiError(err, 'The advisor could not answer just now. Check your connection and try again.'), error: true }])
    } finally {
      setThinking(false)
      inputRef.current?.focus()
    }
  }

  const handleKey = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      send()
    }
  }

  // A fixed "Online" badge is worse than none: it keeps claiming the advisor
  // works while the service is down, and farmers keep typing into a dead box.
  const status = health === null
    ? { color: 'var(--text-faint)', label: 'Checking…' }
    : !health.up
      ? { color: 'var(--loss)', label: 'Offline' }
      : !health.configured
        ? { color: 'var(--accent-amber)', label: 'Not set up' }
        : { color: 'var(--profit)', label: 'Online' }

  return (
    <Layout title={null}>
      <section className="advisor-card" aria-labelledby="advisor-title">
        <header style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '16px 20px', borderBottom: '1px solid var(--border)' }}>
          <img src={logo} alt="" width="40" height="40" style={{ display: 'block', flexShrink: 0 }} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <h1 id="advisor-title" style={{ fontSize: '20px', fontWeight: 700, color: 'var(--text-primary)', margin: 0 }}>AI farm advisor</h1>
            <p style={{ margin: '2px 0 0', fontSize: '13px', color: 'var(--text-muted)' }}>Fertilizer, pests, irrigation and costs, for the crops you grow</p>
          </div>
          <span role="status" style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', borderRadius: '999px', background: 'var(--bg-tile)', fontSize: '13px', fontWeight: 500, color: 'var(--text-primary)', flexShrink: 0 }}>
            <span aria-hidden="true" style={{ width: 8, height: 8, borderRadius: '50%', background: status.color }} />
            {status.label}
          </span>
        </header>

        <div ref={listRef} style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
          {messages.length === 0 ? (
            <div style={{ margin: 'auto', maxWidth: '560px', textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px', padding: '12px 0' }}>
              <img src={logo} alt="" width="56" height="56" style={{ display: 'block' }} />
              <h2 style={{ fontSize: '19px', fontWeight: 700, color: 'var(--text-primary)', margin: 0 }}>Ask about your farm</h2>
              <p style={{ margin: 0, fontSize: '15px', color: 'var(--text-muted)', lineHeight: 1.6 }}>
                Ask anything about fertilizer, pests, irrigation or costs. Your crop list is shared with the advisor so answers fit your farm.
              </p>
              <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: '8px', marginTop: '8px' }}>
                {SUGGESTIONS.map((s) => (
                  <button key={s} type="button" className="chip-btn" onClick={() => send(s)} disabled={thinking}>{s}</button>
                ))}
              </div>
            </div>
          ) : (
            messages.map((m, i) => <Bubble key={i} message={m} />)
          )}
          {thinking && <Bubble message={{ role: 'ai', pending: true }} />}
        </div>

        <form onSubmit={(e) => { e.preventDefault(); send() }} style={{ borderTop: '1px solid var(--border)', padding: '14px 16px 10px' }}>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-end' }}>
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKey}
              rows={Math.min(4, Math.max(1, input.split('\n').length))}
              maxLength={1000}
              aria-label="Your question"
              placeholder="Ask a farming question…"
              className="agro-input"
              style={{ flex: 1, resize: 'none', fontSize: '15px', lineHeight: 1.5 }}
            />
            <button type="submit" className="send-btn" disabled={!input.trim() || thinking} aria-label="Send">
              <SendIcon size={20} />
            </button>
          </div>
          <p style={{ margin: '8px 2px 0', fontSize: '12px', color: 'var(--text-faint)' }}>Enter to send, Shift + Enter for a new line. AI answers can be wrong, so check before you spray or spend.</p>
        </form>
      </section>
    </Layout>
  )
}
