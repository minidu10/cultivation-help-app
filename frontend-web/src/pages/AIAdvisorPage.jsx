import { useState, useRef, useEffect } from 'react'
import Layout from '../components/Layout'
import { askAI } from '../api/crops'

const SUGGESTED_QUESTIONS = [
  'What is the best fertilizer for rice cultivation?',
  'How do I control pests in vegetable farming?',
  'When is the best time to harvest Samba rice?',
  'How can I reduce my farming expenses?',
  'What crops are most profitable in Sri Lanka?',
  'How much water does rice need per acre?',
]

const cardStyle = {
  background: 'var(--bg-card)',
  border: '1px solid var(--border)',
  borderRadius: '16px',
  backdropFilter: 'blur(12px)',
}

export default function AIAdvisorPage() {
  const [messages, setMessages] = useState([
    {
      role: 'ai',
      text: `Hello! 👋 I'm your AI farming advisor. I can help you with crop cultivation, fertilizers, pest control, harvest timing, and farm finances. What would you like to know?`,
    },
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [cropContext, setCropContext] = useState('')
  const bottomRef = useRef(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  const sendMessage = async (question) => {
    const q = question || input.trim()
    if (!q || loading) return

    setMessages(prev => [...prev, { role: 'user', text: q }])
    setInput('')
    setLoading(true)

    try {
      const res = await askAI(q, cropContext)
      setMessages(prev => [...prev, { role: 'ai', text: res.data.answer, mode: res.data.mode }])
    } catch {
      setMessages(prev => [
        ...prev,
        { role: 'ai', text: 'Sorry, I could not connect to the AI service. Make sure the AI server is running on port 8000.', error: true },
      ])
    } finally {
      setLoading(false)
    }
  }

  const handleKey = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  return (
    <Layout>
      <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr', gap: '24px', height: 'calc(100vh - 140px)', minHeight: '500px' }}>

        {/* ── Left sidebar ── */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', overflowY: 'auto' }}>

          {/* Status */}
          <div style={{ ...cardStyle, padding: '20px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
              <div style={{ width: 40, height: 40, borderRadius: '10px', background: 'rgba(74,222,128,0.1)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>🤖</div>
              <div>
                <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)' }}>AI Advisor</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '5px', marginTop: '2px' }}>
                  <div style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent-lime)', boxShadow: '0 0 6px var(--accent-lime)' }} />
                  <span style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--accent-lime)' }}>Online · Powered by Groq</span>
                </div>
              </div>
            </div>
            <p style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', lineHeight: 1.6 }}>
              Ask about cultivation, pests, fertilizers, and farm finances.
            </p>
          </div>

          {/* Crop context */}
          <div style={{ ...cardStyle, padding: '20px' }}>
            <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '11px', color: 'var(--accent-lime)', textTransform: 'uppercase', letterSpacing: '1.5px', marginBottom: '8px' }}>Farm Context</div>
            <p style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', marginBottom: '10px' }}>Help AI give better advice by describing your farm</p>
            <textarea
              value={cropContext}
              onChange={e => setCropContext(e.target.value)}
              rows={3}
              placeholder="e.g. Growing Samba rice, 2.5 acres, North Field"
              style={{ width: '100%', boxSizing: 'border-box', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '8px', padding: '10px 12px', fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-primary)', outline: 'none', resize: 'none', transition: 'border-color 0.2s' }}
              onFocus={e => e.target.style.borderColor = 'var(--border-hover)'}
              onBlur={e => e.target.style.borderColor = 'var(--border)'}
            />
          </div>

          {/* Suggested questions */}
          <div style={{ ...cardStyle, padding: '20px' }}>
            <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '11px', color: 'var(--accent-lime)', textTransform: 'uppercase', letterSpacing: '1.5px', marginBottom: '12px' }}>Try Asking</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {SUGGESTED_QUESTIONS.map((q, i) => (
                <button
                  key={i}
                  onClick={() => sendMessage(q)}
                  disabled={loading}
                  style={{ textAlign: 'left', background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '8px', padding: '9px 12px', fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)', cursor: 'pointer', transition: 'all 0.2s', opacity: loading ? 0.4 : 1 }}
                  onMouseEnter={e => { if (!loading) { e.currentTarget.style.borderColor = 'var(--border-hover)'; e.currentTarget.style.color = 'var(--text-primary)' } }}
                  onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)' }}
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* ── Chat area ── */}
        <div style={{ ...cardStyle, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>

          {/* Header */}
          <div style={{ padding: '18px 24px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '12px', flexShrink: 0 }}>
            <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '18px', boxShadow: '0 0 12px rgba(74,222,128,0.3)', flexShrink: 0 }}>🌾</div>
            <div>
              <div style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: '15px', color: 'var(--text-primary)' }}>AgroMaster AI</div>
              <div style={{ fontFamily: 'Inter', fontSize: '12px', color: 'var(--text-muted)' }}>Expert farming advisor for Sri Lanka</div>
            </div>
          </div>

          {/* Messages */}
          <div style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {messages.map((msg, i) => (
              <div key={i} style={{ display: 'flex', justifyContent: msg.role === 'user' ? 'flex-end' : 'flex-start', alignItems: 'flex-start', gap: '10px' }}>
                {msg.role === 'ai' && (
                  <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '15px', flexShrink: 0, boxShadow: '0 0 8px rgba(74,222,128,0.25)' }}>🌾</div>
                )}
                <div style={{
                  maxWidth: '70%',
                  borderRadius: msg.role === 'user' ? '18px 18px 4px 18px' : '18px 18px 18px 4px',
                  padding: '12px 16px',
                  background: msg.role === 'user'
                    ? 'var(--accent-lime)'
                    : msg.error
                    ? 'rgba(248,113,113,0.1)'
                    : 'var(--bg-input)',
                  border: msg.role === 'user' ? 'none' : msg.error ? '1px solid rgba(248,113,113,0.3)' : '1px solid var(--border)',
                  color: msg.role === 'user' ? '#0a1a0f' : msg.error ? 'var(--accent-red)' : 'var(--text-primary)',
                  fontFamily: 'Inter',
                  fontSize: '14px',
                  lineHeight: 1.6,
                }}>
                  {msg.text.split('\n').map((line, j) => (
                    <span key={j}>{line}{j < msg.text.split('\n').length - 1 && <br />}</span>
                  ))}
                  {msg.mode && (
                    <div style={{ marginTop: '8px', paddingTop: '8px', borderTop: '1px solid var(--border)', fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-muted)' }}>
                      Powered by {msg.mode}
                    </div>
                  )}
                </div>
                {msg.role === 'user' && (
                  <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'rgba(74,222,128,0.12)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '15px', flexShrink: 0 }}>👤</div>
                )}
              </div>
            ))}

            {/* Typing indicator */}
            {loading && (
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '15px', flexShrink: 0 }}>🌾</div>
                <div style={{ background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '18px 18px 18px 4px', padding: '14px 18px' }}>
                  <div style={{ display: 'flex', gap: '5px', alignItems: 'center' }}>
                    {[0, 150, 300].map(delay => (
                      <div key={delay} style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--accent-lime)', animation: 'typing-bounce 1s ease infinite', animationDelay: `${delay}ms` }} />
                    ))}
                  </div>
                </div>
              </div>
            )}
            <div ref={bottomRef} />
          </div>

          {/* Input */}
          <div style={{ padding: '16px 20px', borderTop: '1px solid var(--border)', flexShrink: 0 }}>
            <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-end' }}>
              <textarea
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={handleKey}
                rows={2}
                disabled={loading}
                placeholder="Ask a farming question… (Enter to send)"
                style={{ flex: 1, background: 'var(--bg-input)', border: '1px solid var(--border)', borderRadius: '12px', padding: '10px 14px', fontFamily: 'Inter', fontSize: '14px', color: 'var(--text-primary)', outline: 'none', resize: 'none', transition: 'border-color 0.2s', opacity: loading ? 0.5 : 1 }}
                onFocus={e => e.target.style.borderColor = 'var(--border-hover)'}
                onBlur={e => e.target.style.borderColor = 'var(--border)'}
              />
              <button
                onClick={() => sendMessage()}
                disabled={!input.trim() || loading}
                className="agro-btn"
                style={{ padding: '10px 20px', fontSize: '14px', flexShrink: 0 }}
              >
                {loading ? '…' : 'Send'}
              </button>
            </div>
            <p style={{ fontFamily: 'Inter', fontSize: '11px', color: 'var(--text-faint)', marginTop: '8px' }}>
              Press Enter to send · Shift+Enter for new line
            </p>
          </div>
        </div>
      </div>
    </Layout>
  )
}
