import { useState } from 'react'
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

export default function AIAdvisorPage() {
  const [messages, setMessages] = useState([
    {
      role: 'ai',
      text: `Hello! 👋 I'm your AI farming advisor. I can help you with crop cultivation, fertilizers, pest control, harvest timing, and farm finances. What would you like to know?`,
    }
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [cropContext, setCropContext] = useState('')

  const sendMessage = async (question) => {
    const q = question || input.trim()
    if (!q || loading) return

    // Add user message
    setMessages((prev) => [...prev, { role: 'user', text: q }])
    setInput('')
    setLoading(true)

    try {
      const res = await askAI(q, cropContext)
      setMessages((prev) => [
        ...prev,
        { role: 'ai', text: res.data.answer, mode: res.data.mode }
      ])
    } catch (err) {
      setMessages((prev) => [
        ...prev,
        {
          role: 'ai',
          text: 'Sorry, I could not connect to the AI service. Make sure the AI server is running on port 8000.',
          error: true,
        }
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
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">
          🤖 AI Crop Advisor
        </h1>
        <p className="text-gray-500 mt-1">
          Ask anything about farming — powered by Groq AI
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">

        {/* Sidebar — context + suggestions */}
        <div className="lg:col-span-1 space-y-4">

          {/* Crop context */}
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <h2 className="text-sm font-semibold text-gray-700 mb-2">
              📍 Your crop context
            </h2>
            <p className="text-xs text-gray-400 mb-2">
              Optional — helps AI give better advice
            </p>
            <textarea
              value={cropContext}
              onChange={(e) => setCropContext(e.target.value)}
              rows={3}
              placeholder="e.g. Growing Samba rice, 2.5 acres, North Field"
              className="w-full border border-gray-300 rounded-lg
                         px-3 py-2 text-xs focus:outline-none
                         focus:ring-2 focus:ring-green-400 resize-none"
            />
          </div>

          {/* Suggested questions */}
          <div className="bg-white rounded-xl border border-gray-200 p-4">
            <h2 className="text-sm font-semibold text-gray-700 mb-3">
              💡 Try asking
            </h2>
            <div className="space-y-2">
              {SUGGESTED_QUESTIONS.map((q, i) => (
                <button
                  key={i}
                  onClick={() => sendMessage(q)}
                  disabled={loading}
                  className="w-full text-left text-xs text-green-700
                             bg-green-50 hover:bg-green-100 border
                             border-green-200 rounded-lg px-3 py-2
                             transition-colors disabled:opacity-40"
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Chat area */}
        <div className="lg:col-span-3 flex flex-col bg-white
                        rounded-xl border border-gray-200
                        overflow-hidden" style={{ height: '600px' }}>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto p-5 space-y-4">
            {messages.map((msg, i) => (
              <div
                key={i}
                className={`flex ${
                  msg.role === 'user' ? 'justify-end' : 'justify-start'
                }`}
              >
                {/* AI avatar */}
                {msg.role === 'ai' && (
                  <div className="w-8 h-8 rounded-full bg-green-600
                                  flex items-center justify-center
                                  text-white text-sm flex-shrink-0
                                  mr-3 mt-1">
                    🌾
                  </div>
                )}

                <div
                  className={`max-w-lg rounded-2xl px-4 py-3 text-sm
                    leading-relaxed ${
                      msg.role === 'user'
                        ? 'bg-green-600 text-white rounded-tr-sm'
                        : msg.error
                        ? 'bg-red-50 text-red-600 border border-red-200'
                        : 'bg-gray-100 text-gray-800 rounded-tl-sm'
                    }`}
                >
                  {/* Format AI response — preserve line breaks */}
                  {msg.text.split('\n').map((line, j) => (
                    <span key={j}>
                      {line}
                      {j < msg.text.split('\n').length - 1 && <br />}
                    </span>
                  ))}

                  {/* Mode badge */}
                  {msg.mode && (
                    <div className="mt-2 pt-2 border-t border-gray-200">
                      <span className="text-xs text-gray-400">
                        Powered by {msg.mode}
                      </span>
                    </div>
                  )}
                </div>

                {/* User avatar */}
                {msg.role === 'user' && (
                  <div className="w-8 h-8 rounded-full bg-gray-300
                                  flex items-center justify-center
                                  text-gray-600 text-sm flex-shrink-0
                                  ml-3 mt-1">
                    👤
                  </div>
                )}
              </div>
            ))}

            {/* Typing indicator */}
            {loading && (
              <div className="flex justify-start">
                <div className="w-8 h-8 rounded-full bg-green-600
                                flex items-center justify-center
                                text-white text-sm flex-shrink-0
                                mr-3 mt-1">
                  🌾
                </div>
                <div className="bg-gray-100 rounded-2xl rounded-tl-sm
                                px-4 py-3">
                  <div className="flex gap-1 items-center h-5">
                    <div className="w-2 h-2 bg-gray-400 rounded-full
                                    animate-bounce"
                         style={{ animationDelay: '0ms' }} />
                    <div className="w-2 h-2 bg-gray-400 rounded-full
                                    animate-bounce"
                         style={{ animationDelay: '150ms' }} />
                    <div className="w-2 h-2 bg-gray-400 rounded-full
                                    animate-bounce"
                         style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Input area */}
          <div className="border-t border-gray-200 p-4">
            <div className="flex gap-3">
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKey}
                rows={2}
                disabled={loading}
                placeholder="Ask a farming question... (Enter to send)"
                className="flex-1 border border-gray-300 rounded-xl
                           px-4 py-2.5 text-sm focus:outline-none
                           focus:ring-2 focus:ring-green-400 resize-none
                           disabled:opacity-50"
              />
              <button
                onClick={() => sendMessage()}
                disabled={!input.trim() || loading}
                className="bg-green-600 hover:bg-green-700 text-white
                           px-5 rounded-xl font-medium text-sm
                           disabled:opacity-40 transition-colors
                           flex items-center gap-2"
              >
                {loading ? '...' : 'Send →'}
              </button>
            </div>
            <p className="text-xs text-gray-400 mt-2">
              Press Enter to send · Shift+Enter for new line
            </p>
          </div>
        </div>
      </div>
    </Layout>
  )
}