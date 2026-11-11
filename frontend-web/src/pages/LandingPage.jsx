import { useState, useEffect, useRef } from 'react'
import { Link } from 'react-router-dom'
import logo from '../assets/logo.png'
import farmerPhoto from '../assets/photos/farmer-ambanpola.jpg'
import fieldsPhoto from '../assets/photos/fields-matara-aerial.jpg'
import rainPhoto from '../assets/photos/paddy-rain-clouds.jpg'

// ── Palette and type ───────────────────────────────────────────
// The landing page keeps one light look whatever theme the app is set to.
const C = {
  paper: '#f7f3ea',
  card: '#fffdf8',
  ink: '#22261f',
  muted: '#5c6157',
  line: '#e2dccb',
  green: '#3f6b3a',
  greenDark: '#2f5530',
  greenSoft: '#e3ecdf',
  rust: '#a84b25',
  amberSoft: '#f4e6c3',
  amberInk: '#6f5210',
  roseSoft: '#f6dcd5',
  roseInk: '#8a3324',
}
const SERIF = "'Fraunces', Georgia, 'Times New Roman', serif"
const SANS = "'Work Sans', 'Segoe UI', Roboto, Arial, sans-serif"

const GITHUB_URL = 'https://github.com/minidu10/cultivation-help-app'
const APK_URL = `${GITHUB_URL}/releases`

// ── Scroll reveal ──────────────────────────────────────────────
function useInView(threshold = 0.15) {
  const ref = useRef(null)
  // Without IntersectionObserver there is nothing to wait for: show it.
  const [inView, setInView] = useState(() => typeof IntersectionObserver === 'undefined')
  useEffect(() => {
    if (inView || !ref.current) return undefined
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setInView(true) }, { threshold })
    obs.observe(ref.current)
    return () => obs.disconnect()
  }, [inView, threshold])
  return [ref, inView]
}

function FadeUp({ children, delay = 0, style, className }) {
  const [ref, inView] = useInView()
  return (
    <div ref={ref} className={className} style={{
      opacity: inView ? 1 : 0,
      transform: inView ? 'translateY(0)' : 'translateY(24px)',
      transition: `opacity 0.6s ease ${delay}ms, transform 0.6s ease ${delay}ms`,
      ...style,
    }}>
      {children}
    </div>
  )
}

// ── Content ────────────────────────────────────────────────────
const FACTS = [
  { value: '5-day', label: 'forecast for every field' },
  { value: '5', label: 'weather checks on planned jobs' },
  { value: '10', label: 'photo checks a day for each farmer' },
  { value: '1', label: 'account on the web and on Android' },
]

const FEATURES = [
  { title: 'Profit for every crop', desc: 'Each expense and each sale is recorded against a crop, so at harvest you can see which one paid and which one lost money.' },
  { title: 'Weather checks on your plans', desc: 'Planned a fertilizer round or a spray? It is checked against the 5-day forecast for that field, with a one-tap move to a safer day.' },
  { title: 'A crop doctor in your pocket', desc: 'Photograph a sick leaf to get the likely disease or pest, treatments with and without chemicals, and when to see the Agrarian Service Centre.' },
  { title: 'An advisor that knows your farm', desc: 'Ask in plain words. The AI advisor already has your crop list, so the answer starts from your fields and your figures.' },
  { title: 'Reminders that arrive on time', desc: 'One email at 7 in the morning with what is due, and a notification on your phone for each reminder.' },
  { title: 'Records without signal', desc: 'In the Android app, expenses and harvests you save offline are sent when you are back in coverage, and only once.' },
]

const WEATHER_RULES = [
  'Rain within a day of fertilizer or a spray',
  'Wind strong enough to make a spray drift',
  'Irrigation booked just before heavy rain',
  'Rain on the day you planned to harvest',
  'Heat over 35 °C on your fields',
]

const STEPS = [
  { title: 'Register your farm', desc: 'Create a free account and add your crops, fields and sizes. It takes a few minutes.' },
  { title: 'Log your activity', desc: 'Record expenses, harvests and reminders as they happen, on the web or on your phone.' },
  { title: 'Grow with AI insights', desc: 'AgroMaster works out the profit for each crop, checks your plans against the weather and suggests what to do next.' },
]

const FAQ = [
  { q: 'Is AgroMaster free?', a: 'Yes. Create an account and use everything, on the web and in the Android app.' },
  { q: 'What happens out in the field with no signal?', a: 'The Android app shows what it last loaded and keeps new expenses and harvests on the phone. They are sent when the phone reconnects, without making duplicates.' },
  { q: 'Where does the weather come from?', a: 'From the OpenWeather forecast for each field’s location. It looks five days ahead and refreshes every 30 minutes.' },
  { q: 'How far can I trust the crop doctor?', a: 'It gives the most likely cause and how confident it is. When it is unsure, or the problem looks serious, it tells you to show the plant to an officer at your Agrarian Service Centre.' },
  { q: 'Can I use it in Sinhala or Tamil?', a: 'Not yet. AgroMaster is in English for now.' },
]

// ── Record cards floating over the hero photo ──────────────────
// Top left, middle right and bottom left, with a clear gap between each, so
// no card covers another or the farmer's face.
const RECORDS = [
  { meta: 'Tue · 7:10 AM · North field', text: 'Sold 4,800 kg of BG 300 paddy to the rice mill', tag: 'Harvest · Rs 566,400', tagBg: C.greenSoft, tagInk: C.greenDark, tilt: -2 },
  { meta: 'Thu · 6:30 AM · East plot', text: 'Compost and NPK mix for the green chilli', tag: 'Expense · Rs 19,800', tagBg: C.amberSoft, tagInk: C.amberInk, tilt: 1.5 },
  { meta: 'Thu 13 Nov · Dambulla', text: '18 mm of rain expected. Move the fungicide spray to Friday?', tag: 'Weather warning', tagBg: C.roseSoft, tagInk: C.roseInk, tilt: -1.5 },
]

function RecordCard({ record, index }) {
  return (
    <div className={`lp-record lp-record-${index}`} style={{ transform: `rotate(${record.tilt}deg)` }}>
      <div className="lp-float" style={{
        animationDelay: `${index * 0.8}s`,
        background: C.card, border: `1px solid ${C.line}`, borderRadius: 14,
        padding: '14px 16px', boxShadow: '0 10px 28px rgba(40, 32, 18, 0.14)',
        display: 'flex', flexDirection: 'column', gap: 6,
      }}>
        <span style={{ fontSize: 13, color: C.muted }}>{record.meta}</span>
        <span style={{ fontSize: 15, fontWeight: 600, color: C.ink, lineHeight: 1.35 }}>{record.text}</span>
        <span style={{ alignSelf: 'flex-start', background: record.tagBg, color: record.tagInk, borderRadius: 999, padding: '3px 10px', fontSize: 13, fontWeight: 600 }}>{record.tag}</span>
      </div>
    </div>
  )
}

// ── Paddy along the bottom of the hero ─────────────────────────
// Fixed geometry, built once at module load so a re-render never reshuffles it.
const STALKS = Array.from({ length: 64 }, (_, i) => {
  const x = (i / 63) * 1440
  return {
    x,
    h: 34 + Math.abs(Math.sin(i * 1.7)) * 30,
    lean: Math.sin(i * 0.9) * 5,
    delay: `${(i % 9) * 0.21}s`,
    duration: `${2.4 + Math.abs(Math.cos(i)) * 1.2}s`,
    back: i % 2 === 0,
  }
})

function PaddyStrip() {
  return (
    <svg aria-hidden="true" viewBox="0 0 1440 90" preserveAspectRatio="xMidYMax slice" style={{ display: 'block', width: '100%', height: 90 }}>
      {STALKS.map((s, i) => (
        <g key={i} className="lp-sway" style={{ transformOrigin: `${s.x}px 90px`, animationDelay: s.delay, animationDuration: s.duration }}>
          <path d={`M${s.x} 90 Q ${s.x + s.lean / 2} ${90 - s.h / 2} ${s.x + s.lean} ${90 - s.h}`} stroke={s.back ? '#9db58f' : C.green} strokeWidth={s.back ? 1.6 : 2.2} fill="none" strokeLinecap="round" />
          <ellipse cx={s.x + s.lean} cy={90 - s.h} rx="3.2" ry="8" fill={s.back ? '#c9b26b' : '#b59a4a'} opacity="0.85" />
        </g>
      ))}
    </svg>
  )
}

// ── How it works: the line between the steps draws itself ─────
function StepsLine() {
  const [ref, inView] = useInView(0.4)
  return (
    <div ref={ref} aria-hidden="true" className="lp-steps-line" style={{ position: 'absolute', top: 27, left: '16.6%', right: '16.6%', height: 2, background: C.line }}>
      <div style={{ height: '100%', background: C.green, width: inView ? '100%' : '0%', transition: 'width 1.2s ease 0.2s' }} />
    </div>
  )
}

function PlusIcon() {
  return (
    <svg className="lp-plus" aria-hidden="true" width="18" height="18" viewBox="0 0 18 18" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round">
      <path d="M9 3v12M3 9h12" />
    </svg>
  )
}

function CheckIcon() {
  return (
    <svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C.green} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, marginTop: 4 }}>
      <path d="M5 12.5l4.5 4.5L19 7.5" />
    </svg>
  )
}

const pillPrimary = {
  background: C.green, color: '#ffffff', borderRadius: 999, padding: '14px 26px',
  fontWeight: 600, fontSize: 16, textDecoration: 'none', display: 'inline-block',
}

const sectionTitle = { fontFamily: SERIF, fontWeight: 600, fontSize: 'clamp(32px, 4vw, 46px)', lineHeight: 1.1, margin: 0, textWrap: 'balance' }

// ── Page ───────────────────────────────────────────────────────
export default function LandingPage() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8)
    window.addEventListener('scroll', onScroll)
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <div style={{ background: C.paper, color: C.ink, fontFamily: SANS, fontSize: 17, lineHeight: 1.6, minHeight: '100vh', overflowX: 'hidden' }}>
      <style>{`
        @keyframes lp-float { 0%, 100% { transform: translateY(0) } 50% { transform: translateY(-6px) } }
        @keyframes lp-sway { 0%, 100% { transform: rotate(-3deg) } 50% { transform: rotate(3deg) } }
        .lp-float { animation: lp-float 6s ease-in-out infinite; }
        .lp-sway { animation-name: lp-sway; animation-timing-function: ease-in-out; animation-iteration-count: infinite; }
        .lp-hero { display: grid; grid-template-columns: minmax(0, 1fr) 530px; gap: 72px; align-items: center; }
        .lp-hero-photo { position: relative; margin: 0 40px 0 56px; }
        .lp-record { position: absolute; width: 250px; z-index: 1; }
        .lp-record-0 { top: 3%; left: -56px; }
        .lp-record-1 { top: calc(50% - 62px); right: -44px; }
        .lp-record-2 { bottom: 3%; left: -32px; }
        .lp-facts { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 24px; }
        .lp-features { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 18px; }
        .lp-split { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 64px; align-items: center; }
        .lp-steps { position: relative; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 40px; text-align: center; }
        .lp-nav-links { display: flex; align-items: center; gap: 28px; }
        .lp-nav-links a { white-space: nowrap; }
        .lp-link { color: ${C.ink}; text-decoration: none; font-weight: 500; }
        .lp-link:hover { color: ${C.green}; }
        .lp-cta:hover { background: ${C.greenDark} !important; }
        .lp-faq summary { list-style: none; cursor: pointer; display: flex; justify-content: space-between; align-items: center; gap: 16px; padding: 20px 0; font-weight: 600; }
        .lp-faq summary::-webkit-details-marker { display: none; }
        .lp-faq .lp-plus { flex-shrink: 0; color: ${C.green}; transition: transform 0.2s ease; }
        .lp-faq details[open] .lp-plus { transform: rotate(45deg); }
        @media (max-width: 1040px) {
          .lp-hero { grid-template-columns: minmax(0, 1fr); gap: 48px; }
          .lp-hero-photo { margin: 0 auto; max-width: 460px; }
        }
        @media (max-width: 960px) {
          .lp-split { grid-template-columns: minmax(0, 1fr); gap: 40px; }
          .lp-facts { grid-template-columns: repeat(2, minmax(0, 1fr)); }
          .lp-features { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 640px) {
          .lp-hero-photo { max-width: none; }
          .lp-record { position: static; width: auto; margin-top: 20px; }
          .lp-features, .lp-steps { grid-template-columns: minmax(0, 1fr); }
          .lp-steps-line { display: none; }
          .lp-nav-links { gap: 10px; }
          .lp-nav-links .lp-hide-sm { display: none; }
          .lp-bar { padding: 12px 16px !important; gap: 10px !important; }
          .lp-bar .lp-logo { width: 30px; height: 30px; }
          .lp-bar .lp-wordmark { font-size: 18px !important; }
          .lp-nav-links .lp-cta { padding: 8px 12px !important; font-size: 14px !important; }
        }
      `}</style>

      {/* ── Nav ── */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 20, background: C.paper,
        borderBottom: `1px solid ${scrolled ? C.line : 'transparent'}`, transition: 'border-color 0.2s',
      }}>
        <div className="lp-bar" style={{ maxWidth: 1180, margin: '0 auto', padding: '14px 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16 }}>
          <Link to="/" style={{ display: 'flex', alignItems: 'center', gap: 8, textDecoration: 'none', flexShrink: 0 }}>
            <img src={logo} alt="" width="38" height="38" className="lp-logo" style={{ display: 'block' }} />
            <span className="lp-wordmark" style={{ fontFamily: SERIF, fontWeight: 700, fontSize: 24, color: C.ink }}>
              Agro<span style={{ color: C.green }}>Master</span>
            </span>
          </Link>
          <nav aria-label="Main" className="lp-nav-links">
            <a href="#features" className="lp-link lp-hide-sm">Features</a>
            <a href="#how-it-works" className="lp-link lp-hide-sm">How it works</a>
            <a href="#questions" className="lp-link lp-hide-sm">Questions</a>
            <Link to="/login" className="lp-link">Sign in</Link>
            <Link to="/register" className="lp-cta" style={{ ...pillPrimary, padding: '10px 20px', fontSize: 15 }}>Try AgroMaster</Link>
          </nav>
        </div>
      </header>

      {/* ── Hero ── */}
      <section>
        <div className="lp-hero" style={{ maxWidth: 1180, margin: '0 auto', padding: '48px 24px 40px' }}>
          <FadeUp style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
            <span style={{ fontSize: 13, fontWeight: 600, letterSpacing: '0.08em', textTransform: 'uppercase', color: C.rust }}>AI-powered farm records for Sri Lanka</span>
            <h1 style={{ fontFamily: SERIF, fontWeight: 600, fontSize: 'clamp(42px, 5.6vw, 70px)', lineHeight: 1.04, letterSpacing: '-0.01em', margin: 0, textWrap: 'balance' }}>
              Write it down in the field. <em style={{ color: C.green, fontStyle: 'italic' }}>Know what it earned</em> at harvest.
            </h1>
            <p style={{ margin: 0, fontSize: 19, color: C.muted, maxWidth: 560 }}>
              AgroMaster keeps the expenses, harvests and reminders for each of your crops, on your phone and on the web. It warns you when rain or wind will spoil a job you planned, checks photos of sick leaves, and shows the profit or loss for every crop.
            </p>
            <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '14px 24px' }}>
              <Link to="/register" className="lp-cta" style={pillPrimary}>Create a free account</Link>
              <Link to="/login" style={{ color: C.ink, fontWeight: 500 }}>I already have an account</Link>
            </div>
            <span style={{ fontSize: 14, color: C.muted }}>On the web and on Android, with the same account.</span>
          </FadeUp>

          <FadeUp delay={150}>
            <div className="lp-hero-photo">
              <img
                src={farmerPhoto}
                alt="A paddy farmer near Ambanpola standing in his rice field"
                fetchPriority="high"
                style={{ display: 'block', width: '100%', aspectRatio: '4 / 5', objectFit: 'cover', objectPosition: '52% 40%', borderRadius: 22 }}
              />
              {RECORDS.map((record, i) => <RecordCard key={record.text} record={record} index={i} />)}
            </div>
          </FadeUp>
        </div>
        <PaddyStrip />
      </section>

      {/* ── Facts ── */}
      <section aria-label="AgroMaster in numbers" style={{ borderTop: `1px solid ${C.line}`, borderBottom: `1px solid ${C.line}`, background: C.card }}>
        <div className="lp-facts" style={{ maxWidth: 1180, margin: '0 auto', padding: '40px 24px' }}>
          {FACTS.map((f, i) => (
            <FadeUp key={f.label} delay={i * 90} style={{ textAlign: 'center' }}>
              <div style={{ fontFamily: SERIF, fontWeight: 600, fontSize: 'clamp(34px, 4vw, 46px)', color: C.green, lineHeight: 1.1 }}>{f.value}</div>
              <div style={{ fontSize: 15, color: C.muted, marginTop: 6 }}>{f.label}</div>
            </FadeUp>
          ))}
        </div>
      </section>

      {/* ── Features ── */}
      <section id="features">
        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '96px 24px', display: 'flex', flexDirection: 'column', gap: 44 }}>
          <FadeUp style={{ display: 'flex', flexDirection: 'column', gap: 14, maxWidth: 700, margin: '0 auto', textAlign: 'center' }}>
            <h2 style={sectionTitle}>Your exercise book has the numbers. AgroMaster does the sums.</h2>
            <p style={{ margin: 0, color: C.muted, fontSize: 18 }}>Keep writing things down the way you already do, just on your phone. This is what you get back.</p>
          </FadeUp>
          <div className="lp-features">
            {FEATURES.map((f, i) => (
              <FadeUp key={f.title} delay={(i % 3) * 90} style={{ height: '100%' }}>
                <div style={{ background: C.card, border: `1px solid ${C.line}`, borderRadius: 14, padding: '26px 24px', height: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
                  <span style={{ fontFamily: SERIF, fontSize: 15, fontWeight: 600, color: C.rust }}>{String(i + 1).padStart(2, '0')}</span>
                  <h3 style={{ fontFamily: SERIF, fontWeight: 600, fontSize: 22, lineHeight: 1.2, margin: 0 }}>{f.title}</h3>
                  <p style={{ margin: 0, color: C.muted, fontSize: 16 }}>{f.desc}</p>
                </div>
              </FadeUp>
            ))}
          </div>
        </div>
      </section>

      {/* ── Weather spotlight ── */}
      <section style={{ maxWidth: 1180, margin: '0 auto', padding: '0 24px 96px' }}>
        <div className="lp-split">
          <FadeUp>
            <div style={{ position: 'relative' }}>
              <img src={rainPhoto} alt="Young rice in a flooded field under heavy rain clouds" loading="lazy" style={{ display: 'block', width: '100%', aspectRatio: '4 / 3', objectFit: 'cover', borderRadius: 20 }} />
              <div style={{ position: 'absolute', left: 20, right: 20, bottom: 20, background: C.card, borderRadius: 14, padding: '14px 16px', boxShadow: '0 12px 30px rgba(40, 32, 18, 0.18)', display: 'flex', flexDirection: 'column', gap: 4 }}>
                <span style={{ fontSize: 14, fontWeight: 700, color: C.roseInk }}>Rain may wash it off</span>
                <span style={{ fontSize: 15, color: C.ink }}>18 mm expected on Thursday. The fungicide spray on the big onion can move to Friday, which looks dry.</span>
              </div>
            </div>
          </FadeUp>
          <FadeUp delay={120} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
            <h2 style={sectionTitle}>Rain on the way? <em style={{ color: C.green }}>You’ll know before you spray.</em></h2>
            <p style={{ margin: 0, color: C.muted, fontSize: 18 }}>Every reminder you set for the next five days is checked against the forecast for that field. When the weather puts a job at risk, AgroMaster says why and offers a safer day, which you can accept in one tap.</p>
            <ul style={{ listStyle: 'none', margin: 0, padding: 0, display: 'flex', flexDirection: 'column', gap: 10 }}>
              {WEATHER_RULES.map((rule) => (
                <li key={rule} style={{ display: 'flex', gap: 10, fontSize: 16 }}><CheckIcon />{rule}</li>
              ))}
            </ul>
          </FadeUp>
        </div>
      </section>

      {/* ── How it works ── */}
      <section id="how-it-works" style={{ background: C.card, borderTop: `1px solid ${C.line}`, borderBottom: `1px solid ${C.line}` }}>
        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '96px 24px', display: 'flex', flexDirection: 'column', gap: 52 }}>
          <FadeUp style={{ textAlign: 'center', maxWidth: 640, margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 12 }}>
            <h2 style={sectionTitle}>How AgroMaster works</h2>
            <p style={{ margin: 0, color: C.muted, fontSize: 18 }}>Three steps from an empty account to knowing what each crop earned.</p>
          </FadeUp>
          <div className="lp-steps">
            <StepsLine />
            {STEPS.map((s, i) => (
              <FadeUp key={s.title} delay={i * 150} style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
                <span style={{ width: 56, height: 56, borderRadius: '50%', background: C.card, border: `2px solid ${C.green}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: SERIF, fontWeight: 600, fontSize: 22, color: C.green }}>{i + 1}</span>
                <h3 style={{ fontFamily: SERIF, fontWeight: 600, fontSize: 22, margin: 0 }}>{s.title}</h3>
                <p style={{ margin: 0, color: C.muted, fontSize: 16, maxWidth: 320 }}>{s.desc}</p>
              </FadeUp>
            ))}
          </div>
          <FadeUp>
            <img src={fieldsPhoto} alt="Rice fields and village houses near Matara, seen from above" loading="lazy" style={{ display: 'block', width: '100%', height: 'clamp(220px, 32vw, 380px)', objectFit: 'cover', borderRadius: 20 }} />
          </FadeUp>
        </div>
      </section>

      {/* ── A real season ── */}
      <section style={{ maxWidth: 1180, margin: '0 auto', padding: '96px 24px 0' }}>
        <FadeUp>
          <figure style={{ margin: 0, background: C.green, color: '#ffffff', borderRadius: 18, padding: 'clamp(28px, 5vw, 56px)', display: 'flex', flexDirection: 'column', gap: 18 }}>
            <blockquote style={{ margin: 0, fontFamily: SERIF, fontWeight: 500, fontSize: 'clamp(24px, 3vw, 34px)', lineHeight: 1.3, textWrap: 'balance' }}>
              Paddy made Rs 402,650 this Maha season. The big onion lost Rs 298,200 to downy mildew. The farm still finished Rs 64,850 ahead.
            </blockquote>
            <figcaption style={{ fontSize: 15, color: '#dfe9da' }}>The demo farm in AgroMaster: four crops in Polonnaruwa and Dambulla, 35 expenses and 5 harvests.</figcaption>
          </figure>
        </FadeUp>
      </section>

      {/* ── Questions ── */}
      <section id="questions" style={{ maxWidth: 1180, margin: '0 auto', padding: '96px 24px 0' }}>
        <FadeUp style={{ display: 'flex', flexDirection: 'column', gap: 22, maxWidth: 760, margin: '0 auto' }}>
          <h2 style={{ ...sectionTitle, textAlign: 'center' }}>Questions farmers ask first</h2>
          <div className="lp-faq" style={{ borderTop: `1px solid ${C.line}` }}>
            {FAQ.map((item) => (
              <details key={item.q} style={{ borderBottom: `1px solid ${C.line}` }}>
                <summary>{item.q}<PlusIcon /></summary>
                <p style={{ margin: 0, padding: '0 0 20px', color: C.muted }}>{item.a}</p>
              </details>
            ))}
          </div>
        </FadeUp>
      </section>

      {/* ── Closing call ── */}
      <section style={{ maxWidth: 1180, margin: '0 auto', padding: '112px 24px 96px', textAlign: 'center' }}>
        <FadeUp style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20 }}>
          <h2 style={{ ...sectionTitle, fontSize: 'clamp(34px, 5vw, 56px)', maxWidth: 760 }}>Start this season’s records today.</h2>
          <p style={{ margin: 0, color: C.muted, maxWidth: 520 }}>Add your crops in a few minutes, then log costs and sales as they happen. At harvest, the profit for each crop is already worked out.</p>
          <Link to="/register" className="lp-cta" style={pillPrimary}>Create a free account</Link>
          <a href={APK_URL} style={{ color: C.ink, fontSize: 15 }}>Or download the Android app</a>
        </FadeUp>
      </section>

      {/* ── Footer ── */}
      <footer style={{ borderTop: `1px solid ${C.line}` }}>
        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '28px 24px', display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'center', gap: 16, fontSize: 14, color: C.muted }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <img src={logo} alt="" width="28" height="28" style={{ display: 'block' }} />
            <span>© 2026 AgroMaster</span>
          </div>
          <nav aria-label="Footer" style={{ display: 'flex', flexWrap: 'wrap', gap: 20 }}>
            <a href={APK_URL} style={{ color: C.muted }}>Android app</a>
            <a href={GITHUB_URL} style={{ color: C.muted }}>Source on GitHub</a>
            <Link to="/login" style={{ color: C.muted }}>Sign in</Link>
          </nav>
        </div>
      </footer>
    </div>
  )
}
