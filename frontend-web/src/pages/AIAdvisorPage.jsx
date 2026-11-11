import { Fragment, useEffect, useRef, useState } from 'react'
import Layout from '../components/Layout'
import { SendIcon } from '../components/Icons'
import { askAI, getAIHealth, getCrops } from '../api/crops'
import { apiError } from '../utils/password'
import logo from '../assets/logo.png'

const SUGGESTED_QUESTIONS = [
  'What is the best fertilizer for rice cultivation?',
  'How do I control pests in vegetable farming?',
  'When is the best time to harvest Samba rice?',
  'How can I reduce my farming expenses?',
  'What crops are most profitable in Sri Lanka?',
  'How much water does rice need per acre?',
]

const GREETING = "Hello! I'm your AI farming advisor. I can help you with crop cultivation, fertilizers, pest control, harvest timing, and farm finances. What would you like to know?"

// The server caps context at 2,000 characters; staying under it means
// nothing important is cut off mid-crop.
const MAX_CONTEXT = 1900
const FINISHED = ['HARVESTED', 'FAILED']

/**
 * One line per crop, active ones first: the same context the Android app
 * sends. It goes after whatever the farmer typed in Farm Context, so the
 * advisor knows what is growing even when that box is empty.
 */
function describeCrops(crops) {
  const ordered = [...crops].sort((a, b) => Number(FINISHED.includes(a.status)) - Number(FINISHED.includes(b.status)))
  return ordered.map((crop) => [
    crop.name,
    crop.variety && `variety ${crop.variety}`,
    crop.status && crop.status.toLowerCase().replaceAll('_', ' '),
    crop.plantingDate && `planted ${crop.plantingDate}`,
    crop.fieldSizeAcres && `${crop.fieldSizeAcres} acres`,
    crop.fieldLocation && `at ${crop.fieldLocation}`,
  ].filter(Boolean).join(', ') + '.')
}

function buildContext(typed, cropLines) {
  let text = typed.trim()
  for (const line of cropLines) {
    const next = text ? `${text}\n${line}` : line
    if (next.length > MAX_CONTEXT) break
    text = next
  }
  return text.slice(0, MAX_CONTEXT)
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

function Avatar({ size = 32 }) {
  return (
    <span aria-hidden="true" style={{ width: size, height: size, borderRadius: '50%', background: 'var(--bg-card)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <img src={logo} alt="" style={{ width: '72%', height: '72%' }} />
    </span>
  )
}

function UserAvatar() {
  return (
    <span aria-hidden="true" style={{ width: 32, height: 32, borderRadius: '50%', background: 'color-mix(in srgb, var(--accent-lime) 16%, transparent)', color: 'var(--accent-lime)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="8" r="4" /><path d="M4 21a8 8 0 0 1 16 0" /></svg>
    </span>
  )
}

function Message({ msg }) {
  const mine = msg.role === 'user'
  return (
    <div style={{ display: 'flex', justifyContent: mine ? 'flex-end' : 'flex-start', alignItems: 'flex-start', gap: '10px' }}>
      {!mine && <Avatar />}
      <div style={{
        maxWidth: 'min(75%, 680px)', padding: '12px 16px', fontSize: '15px', lineHeight: 1.6, overflowWrap: 'anywhere',
        borderRadius: mine ? '18px 18px 4px 18px' : '18px 18px 18px 4px',
        background: mine ? 'var(--accent-lime)' : msg.error ? 'color-mix(in srgb, var(--loss) 10%, var(--bg-card))' : 'var(--bg-tile)',
        color: mine ? 'var(--on-accent)' : msg.error ? 'var(--loss)' : 'var(--text-primary)',
      }}>
        {mine ? msg.text : <AnswerText text={msg.text} />}
        {msg.model && (
          <div style={{ marginTop: '10px', paddingTop: '8px', borderTop: '1px solid var(--border)', fontSize: '12px', color: 'var(--text-muted)' }}>
            Answered by {msg.model}
          </div>
        )}
      </div>
      {mine && <UserAvatar />}
    </div>
  )
}

export default function AIAdvisorPage() {
  const [messages, setMessages] = useState([{ role: 'ai', text: GREETING }])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [cropContext, setCropContext] = useState('')
  const [cropLines, setCropLines] = useState([])
  // null while the first health check is in flight.
  const [health, setHealth] = useState(null)
  const listRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    let cancelled = false
    getAIHealth()
      .then(({ data }) => { if (!cancelled) setHealth({ up: data.status === 'UP', configured: data.configured, model: data.model }) })
      .catch(() => { if (!cancelled) setHealth({ up: false, configured: false, model: null }) })
    // Without the crop list the advisor still answers, just less specifically.
    getCrops()
      .then(({ data }) => { if (!cancelled) setCropLines(describeCrops(data)) })
      .catch(() => {})
    return () => { cancelled = true }
  }, [])

  useEffect(() => {
    const list = listRef.current
    if (list) list.scrollTop = list.scrollHeight
  }, [messages, loading])

  const sendMessage = async (question) => {
    const q = (question ?? input).trim()
    if (!q || loading) return

    setMessages((prev) => [...prev, { role: 'user', text: q }])
    setInput('')
    setLoading(true)

    try {
      const res = await askAI(q, buildContext(cropContext, cropLines))
      const answer = res.data?.answer?.trim()
      setMessages((prev) => [...prev, answer
        ? { role: 'ai', text: answer, model: res.data.model }
        : { role: 'ai', text: 'The advisor sent back an empty answer. Please try asking again.', error: true }])
    } catch (err) {
      setMessages((prev) => [...prev, { role: 'ai', text: apiError(err, 'Sorry, I could not connect to the AI service. Please try again in a moment.'), error: true }])
    } finally {
      setLoading(false)
      inputRef.current?.focus()
    }
  }

  const handleKey = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  // A fixed "Online" badge is worse than none: it keeps claiming the advisor
  // works while the service is down, and farmers keep typing into a dead box.
  const status = health === null
    ? { color: 'var(--text-faint)', label: 'Checking…' }
    : !health.up
      ? { color: 'var(--loss)', label: 'Offline' }
      : !health.configured
        ? { color: 'var(--accent-amber)', label: 'Not configured' }
        : { color: 'var(--profit)', label: health.model ? `Online · ${health.model}` : 'Online' }

  return (
    <Layout>
      <div className="advisor-layout">

        {/* ── Left column ── */}
        <div className="advisor-side">
          <section className="advisor-panel">
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
              <Avatar size={42} />
              <div style={{ minWidth: 0 }}>
                <h2 style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)', margin: 0 }}>AI Advisor</h2>
                <div role="status" style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '2px' }}>
                  <span aria-hidden="true" style={{ width: 8, height: 8, borderRadius: '50%', background: status.color, flexShrink: 0 }} />
                  <span style={{ fontSize: '13px', color: 'var(--text-muted)', overflowWrap: 'anywhere' }}>{status.label}</span>
                </div>
              </div>
            </div>
            <p style={{ fontSize: '14px', color: 'var(--text-muted)', lineHeight: 1.6, margin: 0 }}>
              Ask about cultivation, pests, fertilizers, and farm finances.
            </p>
          </section>

          <section className="advisor-panel">
            <label htmlFor="farm-context" style={{ display: 'block', fontSize: '15px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '4px' }}>Farm context</label>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '0 0 10px' }}>Help AI give better advice by describing your farm</p>
            <textarea
              id="farm-context"
              value={cropContext}
              onChange={(e) => setCropContext(e.target.value)}
              rows={3}
              maxLength={1000}
              placeholder="e.g. Growing Samba rice, 2.5 acres, North Field"
              className="agro-input"
              style={{ resize: 'vertical', fontSize: '14px', lineHeight: 1.5 }}
            />
          </section>

          <section className="advisor-panel">
            <h2 style={{ fontSize: '15px', fontWeight: 700, color: 'var(--text-primary)', margin: '0 0 12px' }}>Try asking</h2>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {SUGGESTED_QUESTIONS.map((q) => (
                <button key={q} type="button" className="suggest-btn" onClick={() => sendMessage(q)} disabled={loading}>{q}</button>
              ))}
            </div>
          </section>
        </div>

        {/* ── Chat ── */}
        <section className="advisor-chat" aria-label="Chat with AgroMaster AI">
          <header style={{ padding: '16px 22px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '12px', flexShrink: 0 }}>
            <Avatar size={38} />
            <div>
              <div style={{ fontSize: '16px', fontWeight: 700, color: 'var(--text-primary)' }}>AgroMaster AI</div>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Expert farming advisor for Sri Lanka</div>
            </div>
          </header>

          <div ref={listRef} aria-live="polite" style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {messages.map((msg, i) => <Message key={i} msg={msg} />)}

            {loading && (
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                <Avatar />
                <div aria-label="The advisor is typing" style={{ background: 'var(--bg-tile)', borderRadius: '18px 18px 18px 4px', padding: '15px 18px', display: 'flex', gap: '5px', alignItems: 'center' }}>
                  {[0, 150, 300].map((delay) => (
                    <span key={delay} style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--accent-lime)', animation: 'typing-bounce 1s ease infinite', animationDelay: `${delay}ms` }} />
                  ))}
                </div>
              </div>
            )}
          </div>

          <form onSubmit={(e) => { e.preventDefault(); sendMessage() }} style={{ padding: '14px 18px 12px', borderTop: '1px solid var(--border)', flexShrink: 0 }}>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-end' }}>
              <textarea
                ref={inputRef}
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKey}
                rows={2}
                maxLength={1000}
                disabled={loading}
                aria-label="Your question"
                placeholder="Ask a farming question… (Enter to send)"
                className="agro-input"
                style={{ flex: 1, resize: 'none', fontSize: '15px', lineHeight: 1.5 }}
              />
              <button type="submit" disabled={!input.trim() || loading} className="agro-btn" style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', flexShrink: 0 }}>
                <SendIcon size={18} />
                {loading ? 'Sending…' : 'Send'}
              </button>
            </div>
            <p style={{ fontSize: '12px', color: 'var(--text-faint)', margin: '8px 2px 0' }}>
              Press Enter to send · Shift+Enter for new line
            </p>
          </form>
        </section>
      </div>
    </Layout>
  )
}
