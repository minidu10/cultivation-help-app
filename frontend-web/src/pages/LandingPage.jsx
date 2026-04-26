import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'

// ── Scroll-reveal hook ─────────────────────────────────────────
function useInView(threshold = 0.15) {
  const ref = useRef(null)
  const [inView, setInView] = useState(false)
  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setInView(true) }, { threshold })
    if (ref.current) obs.observe(ref.current)
    return () => obs.disconnect()
  }, [])
  return [ref, inView]
}

function FadeUp({ children, delay = 0 }) {
  const [ref, inView] = useInView()
  return (
    <div ref={ref} style={{
      opacity: inView ? 1 : 0,
      transform: inView ? 'translateY(0)' : 'translateY(40px)',
      transition: `opacity 0.7s ease ${delay}ms, transform 0.7s ease ${delay}ms`,
    }}>
      {children}
    </div>
  )
}

// ── Static data ────────────────────────────────────────────────
const FEATURES = [
  { icon: '🌾', title: 'Crop Management',    desc: 'Track every crop from seed to harvest with smart status monitoring and growth milestones.' },
  { icon: '💰', title: 'Expense Tracking',   desc: 'Log seeds, fertilizer, labor and equipment costs. Never lose track of where your money goes.' },
  { icon: '📦', title: 'Harvest Records',    desc: 'Record yield quantities and revenue with timestamped entries and historical comparisons.' },
  { icon: '📊', title: 'Profit Analytics',   desc: 'Real-time P&L charts with seasonal breakdowns and per-crop profitability scores.' },
  { icon: '🤖', title: 'AI Advisor',         desc: 'Get personalized crop recommendations and cost optimizations powered by advanced AI.' },
  { icon: '🌦️', title: 'Weather Integration',desc: 'Live weather data and 7-day forecasts tailored to your farm location in Sri Lanka.' },
]

const STEPS = [
  { num: '01', title: 'Register Your Farm',      desc: 'Create your free account and set up your farm profile in under 2 minutes.' },
  { num: '02', title: 'Log Your Activity',        desc: 'Add your crops, expenses, and harvests through our intuitive dashboard.' },
  { num: '03', title: 'Grow With AI Insights',    desc: 'Let AgroMaster analyze your data and guide you to higher yields and profits.' },
]

const STATS = [
  { value: '500+',   label: 'Active Farmers' },
  { value: 'LKR 2M+',label: 'Revenue Tracked' },
  { value: '94%',    label: 'Profit Improvement' },
  { value: '12',     label: 'Crop Types Supported' },
]

const TESTIMONIALS = [
  { name: 'Nimal Perera',    location: 'Anuradhapura', crop: 'Paddy farmer, 8 acres',  quote: 'AgroMaster helped me cut fertilizer costs by 30% in one season. I never knew data could be this powerful.' },
  { name: 'Kumari Silva',    location: 'Kurunegala',   crop: 'Coconut & Banana',        quote: 'The AI advisor told me exactly when to harvest. My coconut yield was the best in 5 years.' },
  { name: 'Ruwan Fernando',  location: 'Matale',       crop: 'Vegetable grower',        quote: 'Finally I can see profit and loss in real time. No more guessing at the end of the season.' },
]

// ── Hero background (always dark) ─────────────────────────────
function HeroBackground() {
  const stars = Array.from({ length: 30 }, (_, i) => ({
    top: `${3 + Math.random() * 45}%`,
    left: `${Math.random() * 100}%`,
    size: i % 5 === 0 ? 3 : 2,
    opacity: 0.15 + Math.random() * 0.4,
  }))

  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', zIndex: 0 }}>
      <style>{`
        @keyframes lp-sway  { 0%,100%{transform:rotate(-4deg) translateX(0)} 50%{transform:rotate(4deg) translateX(3px)} }
        @keyframes lp-sway2 { 0%,100%{transform:rotate(3deg)} 50%{transform:rotate(-5deg)} }
        @keyframes lp-spin  { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
        @keyframes lp-spin-slow { from{transform:rotate(0deg)} to{transform:rotate(360deg)} }
        @keyframes lp-cloud  { 0%{transform:translateX(0)} 100%{transform:translateX(120px)} }
        @keyframes lp-cloud2 { 0%{transform:translateX(0)} 100%{transform:translateX(-80px)} }
        .lp-stats-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:40px; }
        .lp-features-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:24px; }
        .lp-steps-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:48px; }
        .lp-testimonials-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:24px; }
        .lp-footer-inner { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; }
        @media(max-width:768px){
          .lp-stats-grid { grid-template-columns:repeat(2,1fr); gap:20px; }
          .lp-features-grid { grid-template-columns:1fr; }
          .lp-steps-grid { grid-template-columns:1fr; gap:32px; }
          .lp-testimonials-grid { grid-template-columns:1fr; }
          .lp-footer-inner { flex-direction:column; text-align:center; }
          .lp-section { padding:72px 20px !important; }
          .lp-hero-title { font-size:clamp(36px,10vw,72px) !important; letter-spacing:-1px !important; }
          .lp-windmill-left { display:none; }
          .lp-windmill-right { display:none; }
        }
      `}</style>

      {/* Sky */}
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, #020a05 0%, #041208 40%, #0a2010 70%, #0d2b1a 100%)' }} />

      {/* Stars */}
      {stars.map((s, i) => (
        <div key={i} style={{ position: 'absolute', top: s.top, left: s.left, width: s.size, height: s.size, borderRadius: '50%', background: '#e8f5e2', opacity: s.opacity }} />
      ))}

      {/* Moon */}
      <div style={{ position: 'absolute', top: '8%', right: '12%', width: 48, height: 48, borderRadius: '50%', background: 'radial-gradient(circle at 35% 35%, #fffbe8, #d4c97a)', boxShadow: '0 0 40px rgba(255,240,160,0.25), 0 0 80px rgba(255,240,160,0.1)' }} />

      {/* Drifting clouds */}
      <svg style={{ position: 'absolute', top: '12%', left: 0, width: '100%', height: '120px', opacity: 0.12 }} viewBox="0 0 1440 120">
        <g style={{ animation: 'lp-cloud 40s linear infinite' }}>
          <ellipse cx="200" cy="60" rx="120" ry="30" fill="#e8f5e2" />
          <ellipse cx="260" cy="50" rx="80"  ry="25" fill="#e8f5e2" />
          <ellipse cx="150" cy="65" rx="70"  ry="22" fill="#e8f5e2" />
        </g>
        <g style={{ animation: 'lp-cloud2 55s linear infinite' }}>
          <ellipse cx="900" cy="70" rx="100" ry="26" fill="#e8f5e2" />
          <ellipse cx="970" cy="58" rx="70"  ry="22" fill="#e8f5e2" />
          <ellipse cx="840" cy="72" rx="60"  ry="18" fill="#e8f5e2" />
        </g>
      </svg>

      {/* Glow */}
      <div style={{ position: 'absolute', top: 0, right: '8%', width: 500, height: 400, background: 'radial-gradient(ellipse, rgba(255,240,160,0.06) 0%, transparent 70%)', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', bottom: '25%', left: '50%', transform: 'translateX(-50%)', width: 900, height: 300, background: 'radial-gradient(ellipse, rgba(74,222,128,0.1) 0%, transparent 70%)', pointerEvents: 'none' }} />

      {/* Windmill left */}
      <svg viewBox="0 0 160 320" style={{ position: 'absolute', left: '5%', bottom: '16%', width: 110, height: 220, opacity: 0.92 }}>
        <polygon points="74,300 86,300 83,122 77,122" fill="white" opacity="0.88" />
        <polygon points="79,300 81,300 80.5,122 79.5,122" fill="white" opacity="0.25" />
        <rect x="68" y="113" width="26" height="11" rx="4" fill="white" opacity="0.92" />
        <g style={{ transformOrigin: '80px 118px', animation: 'lp-spin 4s linear infinite' }}>
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.92" />
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.92" transform="rotate(120,80,118)" />
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.92" transform="rotate(240,80,118)" />
        </g>
        <circle cx="80" cy="118" r="13" fill="white" />
        <circle cx="80" cy="118" r="13" fill="none" stroke="#111" strokeWidth="3" />
        <circle cx="80" cy="118" r="4" fill="#111" />
      </svg>

      {/* Windmill right — smaller, slower */}
      <svg viewBox="0 0 160 320" style={{ position: 'absolute', right: '8%', bottom: '18%', width: 72, height: 144, opacity: 0.78 }}>
        <polygon points="74,300 86,300 83,122 77,122" fill="white" opacity="0.82" />
        <polygon points="79,300 81,300 80.5,122 79.5,122" fill="white" opacity="0.2" />
        <rect x="68" y="113" width="26" height="11" rx="4" fill="white" opacity="0.85" />
        <g style={{ transformOrigin: '80px 118px', animation: 'lp-spin-slow 7s linear infinite' }}>
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.85" />
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.85" transform="rotate(120,80,118)" />
          <path d="M80,118 C83,108 85,82 83,40 C82,35 78,35 77,40 C75,82 77,108 80,118 Z" fill="white" opacity="0.85" transform="rotate(240,80,118)" />
        </g>
        <circle cx="80" cy="118" r="13" fill="white" />
        <circle cx="80" cy="118" r="13" fill="none" stroke="#111" strokeWidth="3" />
        <circle cx="80" cy="118" r="4" fill="#111" />
      </svg>

      {/* Paddy field */}
      <svg viewBox="0 0 1440 320" preserveAspectRatio="xMidYMax slice" style={{ position: 'absolute', bottom: 0, width: '100%', height: 320 }}>
        <defs>
          <linearGradient id="lp-fieldGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%"   stopColor="#4ade80" stopOpacity="0.5" />
            <stop offset="100%" stopColor="#0d2b1a" stopOpacity="1" />
          </linearGradient>
          <linearGradient id="lp-waterGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%"   stopColor="rgba(74,222,128,0.08)" />
            <stop offset="100%" stopColor="rgba(13,43,26,0.6)" />
          </linearGradient>
        </defs>
        <path d="M0,220 Q360,170 720,200 Q1080,230 1440,180 L1440,320 L0,320 Z" fill="url(#lp-fieldGrad)" opacity="0.4" />
        <path d="M0,260 Q300,230 600,250 Q900,270 1200,240 Q1350,228 1440,245 L1440,320 L0,320 Z" fill="#0d2b1a" opacity="0.9" />
        <rect x="0" y="280" width="1440" height="15" fill="url(#lp-waterGrad)" />
        <rect x="0" y="300" width="1440" height="20" fill="rgba(13,43,26,0.95)" />

        {/* Swaying stalks — back row */}
        {Array.from({ length: 55 }, (_, i) => {
          const x = (i / 54) * 1440
          const h = 45 + Math.sin(i * 1.9) * 18
          const y = 268 + Math.cos(i * 1.4) * 8
          const delay = `${(i % 8) * 0.18}s`
          const anim = i % 2 === 0 ? 'lp-sway' : 'lp-sway2'
          return (
            <g key={`b${i}`} style={{ transformOrigin: `${x}px ${y}px`, animation: `${anim} ${1.8 + Math.sin(i) * 0.6}s ease-in-out ${delay} infinite` }}>
              <line x1={x} y1={y} x2={x + Math.sin(i) * 4} y2={y - h} stroke="#4ade80" strokeWidth="1.8" strokeLinecap="round" opacity="0.55" />
              <ellipse cx={x + Math.sin(i) * 4} cy={y - h} rx="4.5" ry="11" fill="#4ade80" opacity="0.5" />
            </g>
          )
        })}
        {/* Front row */}
        {Array.from({ length: 30 }, (_, i) => {
          const x = (i / 29) * 1440 + 22
          const h = 30 + Math.sin(i * 2.5) * 12
          const delay = `${(i % 6) * 0.22}s`
          return (
            <g key={`f${i}`} style={{ transformOrigin: `${x}px 290px`, animation: `lp-sway ${2.2 + Math.cos(i) * 0.5}s ease-in-out ${delay} infinite` }}>
              <line x1={x} y1={290} x2={x} y2={290 - h} stroke="#22c55e" strokeWidth="2.5" strokeLinecap="round" opacity="0.7" />
              <ellipse cx={x} cy={290 - h} rx="5" ry="13" fill="#22c55e" opacity="0.65" />
            </g>
          )
        })}
      </svg>
    </div>
  )
}

// ── How-it-works connecting line ───────────────────────────────
function HowItWorksLine() {
  const [ref, inView] = useInView(0.3)
  return (
    <div ref={ref} style={{ position: 'absolute', top: 40, left: 'calc(16.6% + 30px)', right: 'calc(16.6% + 30px)', height: 2, background: 'rgba(74,222,128,0.15)', zIndex: 0 }}>
      <div style={{ height: '100%', background: 'linear-gradient(90deg, #4ade80, #16a34a)', width: inView ? '100%' : '0%', transition: 'width 1.2s ease 0.3s', boxShadow: '0 0 8px rgba(74,222,128,0.5)' }} />
    </div>
  )
}

// ── Navbar ─────────────────────────────────────────────────────
function NavBar({ onSignIn, onGetStarted }) {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)
  const [isMobile, setIsMobile] = useState(() => window.innerWidth < 768)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40)
    const onResize = () => setIsMobile(window.innerWidth < 768)
    window.addEventListener('scroll', onScroll)
    window.addEventListener('resize', onResize)
    return () => { window.removeEventListener('scroll', onScroll); window.removeEventListener('resize', onResize) }
  }, [])

  return (
    <>
      <nav style={{
        position: 'fixed', top: 0, left: 0, right: 0, zIndex: 100,
        background: scrolled || menuOpen ? 'rgba(10,26,15,0.97)' : 'transparent',
        backdropFilter: scrolled || menuOpen ? 'blur(16px)' : 'none',
        borderBottom: scrolled || menuOpen ? '1px solid rgba(74,222,128,0.1)' : 'none',
        transition: 'all 0.3s ease',
        padding: isMobile ? '0 20px' : '0 40px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        height: 64,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16 }}>🌿</div>
          <span style={{ fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 20, color: '#e8f5e2', letterSpacing: '-0.5px' }}>AgroMaster</span>
        </div>

        {isMobile ? (
          <button onClick={() => setMenuOpen(o => !o)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#e8f5e2', padding: 4, display: 'flex', alignItems: 'center' }}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
              {menuOpen ? <><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></> : <><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></>}
            </svg>
          </button>
        ) : (
          <div style={{ display: 'flex', gap: 32, alignItems: 'center' }}>
            {['Features', 'How It Works', 'Testimonials'].map(item => (
              <a key={item} href={`#${item.toLowerCase().replace(/ /g, '-')}`} style={{ color: 'rgba(232,245,226,0.7)', fontFamily: 'Inter, sans-serif', fontSize: 14, textDecoration: 'none', transition: 'color 0.2s' }}
                onMouseEnter={e => e.currentTarget.style.color = '#4ade80'}
                onMouseLeave={e => e.currentTarget.style.color = 'rgba(232,245,226,0.7)'}
              >{item}</a>
            ))}
            <button onClick={onSignIn} style={{ background: 'transparent', color: '#e8f5e2', border: '1px solid rgba(232,245,226,0.25)', borderRadius: 8, padding: '8px 20px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 600, fontSize: 14, cursor: 'pointer', transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = 'rgba(74,222,128,0.5)'; e.currentTarget.style.color = '#4ade80' }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(232,245,226,0.25)'; e.currentTarget.style.color = '#e8f5e2' }}
            >Sign In</button>
            <button onClick={onGetStarted} style={{ background: '#4ade80', color: '#0a1a0f', border: 'none', borderRadius: 8, padding: '8px 20px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 14, cursor: 'pointer', boxShadow: '0 0 20px rgba(74,222,128,0.4)', transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.background = '#86efac'; e.currentTarget.style.boxShadow = '0 0 30px rgba(74,222,128,0.6)' }}
              onMouseLeave={e => { e.currentTarget.style.background = '#4ade80'; e.currentTarget.style.boxShadow = '0 0 20px rgba(74,222,128,0.4)' }}
            >Get Started Free</button>
          </div>
        )}
      </nav>

      {/* Mobile dropdown menu */}
      {isMobile && menuOpen && (
        <div style={{ position: 'fixed', top: 64, left: 0, right: 0, zIndex: 99, background: 'rgba(10,26,15,0.97)', backdropFilter: 'blur(16px)', borderBottom: '1px solid rgba(74,222,128,0.1)', padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
          {['Features', 'How It Works', 'Testimonials'].map(item => (
            <a key={item} href={`#${item.toLowerCase().replace(/ /g, '-')}`} onClick={() => setMenuOpen(false)} style={{ color: 'rgba(232,245,226,0.8)', fontFamily: 'Inter, sans-serif', fontSize: 15, textDecoration: 'none', padding: '8px 0', borderBottom: '1px solid rgba(74,222,128,0.08)' }}>{item}</a>
          ))}
          <button onClick={() => { setMenuOpen(false); onSignIn() }} style={{ background: 'transparent', color: '#e8f5e2', border: '1px solid rgba(232,245,226,0.25)', borderRadius: 8, padding: '10px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 600, fontSize: 14, cursor: 'pointer', marginTop: 4 }}>Sign In</button>
          <button onClick={() => { setMenuOpen(false); onGetStarted() }} style={{ background: '#4ade80', color: '#0a1a0f', border: 'none', borderRadius: 8, padding: '10px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 14, cursor: 'pointer' }}>Get Started Free</button>
        </div>
      )}
    </>
  )
}

// ── Main page ──────────────────────────────────────────────────
export default function LandingPage() {
  const navigate = useNavigate()

  return (
    <div style={{ background: '#080f0a', minHeight: '100vh', color: '#e8f5e2', overflowX: 'hidden' }}>
      <NavBar onSignIn={() => navigate('/login')} onGetStarted={() => navigate('/register')} />

      {/* ── HERO ── */}
      <section style={{ position: 'relative', minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', paddingTop: 64 }}>
        <HeroBackground />
        <div style={{ position: 'relative', zIndex: 1, textAlign: 'center', maxWidth: 900, padding: '0 24px' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: 'rgba(74,222,128,0.1)', border: '1px solid rgba(74,222,128,0.3)', borderRadius: 100, padding: '6px 16px', marginBottom: 32, fontSize: 13, color: '#4ade80', fontFamily: 'Inter, sans-serif' }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: '#4ade80', display: 'inline-block', boxShadow: '0 0 8px #4ade80' }} />
            AI-powered precision farming for Sri Lanka
          </div>
          <h1 style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(48px, 8vw, 96px)', fontWeight: 800, lineHeight: 1.0, color: '#e8f5e2', letterSpacing: '-3px', marginBottom: 24 }}>
            GROW SMARTER.<br />
            <span style={{ color: '#4ade80', textShadow: '0 0 40px rgba(74,222,128,0.5)' }}>HARVEST MORE.</span>
          </h1>
          <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 18, lineHeight: 1.7, color: 'rgba(232,245,226,0.65)', maxWidth: 540, margin: '0 auto 48px' }}>
            AgroMaster combines real-time AI insights with expense tracking, crop analytics, and weather data — built for Sri Lankan farmers.
          </p>
          <div style={{ display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
            <button onClick={() => navigate('/register')} style={{ background: '#4ade80', color: '#0a1a0f', border: 'none', borderRadius: 10, padding: '16px 36px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 16, cursor: 'pointer', boxShadow: '0 0 40px rgba(74,222,128,0.5)', transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = '0 0 60px rgba(74,222,128,0.7)' }}
              onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 0 40px rgba(74,222,128,0.5)' }}
            >Get Started Free</button>
            <button onClick={() => navigate('/login')} style={{ background: 'transparent', color: '#e8f5e2', border: '1px solid rgba(232,245,226,0.25)', borderRadius: 10, padding: '16px 36px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 600, fontSize: 16, cursor: 'pointer', transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = 'rgba(74,222,128,0.5)'; e.currentTarget.style.color = '#4ade80' }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(232,245,226,0.25)'; e.currentTarget.style.color = '#e8f5e2' }}
            >Sign In</button>
          </div>
          {/* Scroll cue */}
          <div style={{ marginTop: 80, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, opacity: 0.5 }}>
            <div style={{ width: 1, height: 32, background: 'linear-gradient(#4ade80, transparent)' }} />
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
              <path d="M9 3v10M4 9l5 5 5-5" stroke="#4ade80" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
        </div>
      </section>

      {/* ── STATS ── */}
      <section className="lp-section" style={{ padding: '80px 40px', background: 'rgba(74,222,128,0.04)', borderTop: '1px solid rgba(74,222,128,0.08)', borderBottom: '1px solid rgba(74,222,128,0.08)' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto' }} className="lp-stats-grid">
          {STATS.map((s, i) => (
            <FadeUp key={i} delay={i * 100}>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(32px,4vw,52px)', fontWeight: 800, color: '#4ade80', textShadow: '0 0 30px rgba(74,222,128,0.4)', letterSpacing: '-2px' }}>{s.value}</div>
                <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 14, color: 'rgba(232,245,226,0.5)', marginTop: 8 }}>{s.label}</div>
              </div>
            </FadeUp>
          ))}
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section id="features" style={{ padding: '120px 40px' }}>
        <div style={{ maxWidth: 1200, margin: '0 auto' }}>
          <FadeUp>
            <div style={{ textAlign: 'center', marginBottom: 72 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, letterSpacing: '3px', textTransform: 'uppercase', color: '#4ade80', marginBottom: 16 }}>Everything you need</div>
              <h2 style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(32px,5vw,56px)', fontWeight: 800, color: '#e8f5e2', letterSpacing: '-2px', margin: 0 }}>Built for the field.</h2>
            </div>
          </FadeUp>
          <div className="lp-features-grid">
            {FEATURES.map((f, i) => (
              <FadeUp key={i} delay={i * 80}>
                <div style={{ background: 'rgba(13,43,26,0.5)', border: '1px solid rgba(74,222,128,0.12)', borderRadius: 16, padding: 32, backdropFilter: 'blur(12px)', transition: 'all 0.3s', cursor: 'default', height: '100%' }}
                  onMouseEnter={e => { e.currentTarget.style.borderColor = 'rgba(74,222,128,0.4)'; e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = '0 0 40px rgba(74,222,128,0.1)' }}
                  onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(74,222,128,0.12)'; e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = 'none' }}
                >
                  <div style={{ fontSize: 32, marginBottom: 16 }}>{f.icon}</div>
                  <h3 style={{ fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 18, color: '#e8f5e2', margin: '0 0 12px' }}>{f.title}</h3>
                  <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 14, lineHeight: 1.7, color: 'rgba(232,245,226,0.55)', margin: 0 }}>{f.desc}</p>
                </div>
              </FadeUp>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section id="how-it-works" style={{ padding: '120px 40px', background: 'rgba(26,15,7,0.3)' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto' }}>
          <FadeUp>
            <div style={{ textAlign: 'center', marginBottom: 80 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, letterSpacing: '3px', textTransform: 'uppercase', color: '#f59e0b', marginBottom: 16 }}>Simple process</div>
              <h2 style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(32px,5vw,56px)', fontWeight: 800, color: '#e8f5e2', letterSpacing: '-2px', margin: 0 }}>How It Works</h2>
            </div>
          </FadeUp>
          <div style={{ position: 'relative' }} className="lp-steps-grid">
            <HowItWorksLine />
            {STEPS.map((s, i) => (
              <FadeUp key={i} delay={i * 150}>
                <div style={{ textAlign: 'center', position: 'relative', zIndex: 1 }}>
                  <div style={{ width: 64, height: 64, borderRadius: '50%', margin: '0 auto 24px', background: 'rgba(13,43,26,0.8)', border: '2px solid #4ade80', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 800, fontSize: 20, color: '#4ade80', boxShadow: '0 0 24px rgba(74,222,128,0.3)' }}>{s.num}</div>
                  <h3 style={{ fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 20, color: '#e8f5e2', margin: '0 0 12px' }}>{s.title}</h3>
                  <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 14, lineHeight: 1.7, color: 'rgba(232,245,226,0.55)', margin: 0 }}>{s.desc}</p>
                </div>
              </FadeUp>
            ))}
          </div>
        </div>
      </section>

      {/* ── TESTIMONIALS ── */}
      <section id="testimonials" style={{ padding: '120px 40px' }}>
        <div style={{ maxWidth: 1200, margin: '0 auto' }}>
          <FadeUp>
            <div style={{ textAlign: 'center', marginBottom: 72 }}>
              <div style={{ fontFamily: 'Inter', fontSize: 12, letterSpacing: '3px', textTransform: 'uppercase', color: '#4ade80', marginBottom: 16 }}>Farmer stories</div>
              <h2 style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(32px,5vw,56px)', fontWeight: 800, color: '#e8f5e2', letterSpacing: '-2px', margin: 0 }}>Trusted across Sri Lanka</h2>
            </div>
          </FadeUp>
          <div className="lp-testimonials-grid">
            {TESTIMONIALS.map((t, i) => (
              <FadeUp key={i} delay={i * 100}>
                <div style={{ background: 'rgba(13,43,26,0.4)', border: '1px solid rgba(74,222,128,0.12)', borderRadius: 16, padding: 32, backdropFilter: 'blur(12px)' }}>
                  <div style={{ fontSize: 32, color: '#4ade80', fontFamily: 'Georgia, serif', marginBottom: 16, opacity: 0.6 }}>"</div>
                  <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 15, lineHeight: 1.8, color: 'rgba(232,245,226,0.75)', margin: '0 0 24px', fontStyle: 'italic' }}>{t.quote}</p>
                  <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                    <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 700, color: '#0a1a0f', fontFamily: 'Space Grotesk', flexShrink: 0 }}>{t.name[0]}</div>
                    <div>
                      <div style={{ fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 14, color: '#e8f5e2' }}>{t.name}</div>
                      <div style={{ fontFamily: 'Inter, sans-serif', fontSize: 12, color: 'rgba(232,245,226,0.4)' }}>{t.location} · {t.crop}</div>
                    </div>
                  </div>
                </div>
              </FadeUp>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA BANNER ── */}
      <section style={{ padding: '80px 40px', textAlign: 'center', background: 'linear-gradient(135deg, rgba(74,222,128,0.08), rgba(22,163,74,0.05))', borderTop: '1px solid rgba(74,222,128,0.1)', borderBottom: '1px solid rgba(74,222,128,0.1)' }}>
        <FadeUp>
          <h2 style={{ fontFamily: 'Space Grotesk, sans-serif', fontSize: 'clamp(28px,4vw,48px)', fontWeight: 800, color: '#e8f5e2', letterSpacing: '-1.5px', margin: '0 0 16px' }}>Ready to transform your farm?</h2>
          <p style={{ fontFamily: 'Inter, sans-serif', fontSize: 16, color: 'rgba(232,245,226,0.55)', margin: '0 0 40px' }}>Join 500+ Sri Lankan farmers already growing smarter.</p>
          <button onClick={() => navigate('/register')} style={{ background: '#4ade80', color: '#0a1a0f', border: 'none', borderRadius: 10, padding: '18px 48px', fontFamily: 'Space Grotesk, sans-serif', fontWeight: 700, fontSize: 18, cursor: 'pointer', boxShadow: '0 0 50px rgba(74,222,128,0.5)', transition: 'all 0.2s' }}
            onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = '0 0 70px rgba(74,222,128,0.7)' }}
            onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 0 50px rgba(74,222,128,0.5)' }}
          >Start Growing Free</button>
        </FadeUp>
      </section>

      {/* ── FOOTER ── */}
      <footer style={{ padding: '48px 40px', background: 'rgba(10,16,12,0.9)', borderTop: '1px solid rgba(74,222,128,0.06)' }}>
        <div style={{ maxWidth: 1200, margin: '0 auto' }} className="lp-footer-inner">
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 28, height: 28, borderRadius: 7, background: 'linear-gradient(135deg, #4ade80, #16a34a)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14 }}>🌿</div>
            <span style={{ fontFamily: 'Space Grotesk', fontWeight: 700, fontSize: 16, color: '#e8f5e2' }}>AgroMaster</span>
          </div>
          <div style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(232,245,226,0.3)' }}>© 2026 AgroMaster · Built for Sri Lankan Farmers</div>
          <div style={{ display: 'flex', gap: 24 }}>
            {['Privacy', 'Terms', 'Contact'].map(l => (
              <a key={l} href="#" style={{ fontFamily: 'Inter', fontSize: 13, color: 'rgba(232,245,226,0.4)', textDecoration: 'none' }}>{l}</a>
            ))}
          </div>
        </div>
      </footer>
    </div>
  )
}
