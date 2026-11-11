// How amounts, dates and API codes read on screen, shared by every page so a
// date or a unit looks the same everywhere instead of as the raw API value.

export const rupees = (value) => `Rs. ${Number(value ?? 0).toLocaleString()}`

const UNIT_LABELS = { KG: 'kg', TONNE: 'tonnes', BUSHEL: 'bushels', POUND: 'lb', LITER: 'litres' }

export const unitLabel = (unit) => UNIT_LABELS[unit] || (unit ? unit.toLowerCase() : '')

/** FERTILIZER becomes "Fertilizer", READY_TO_HARVEST becomes "Ready to harvest". */
export function humanize(code) {
  if (!code) return ''
  const words = code.replaceAll('_', ' ').toLowerCase()
  return words.charAt(0).toUpperCase() + words.slice(1)
}

/** "2026-02-10" becomes "10 Feb 2026". Read as a local date, so it never shifts a day. */
export function formatDate(iso) {
  if (!iso) return ''
  const date = new Date(`${iso.slice(0, 10)}T00:00:00`)
  if (Number.isNaN(date.getTime())) return iso
  return date.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}

/** "2026-02-25T06:30:00" becomes "Wed 25 Feb, 6:30 am". */
export function formatDateTime(iso) {
  if (!iso) return ''
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return iso
  const day = date.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short' })
  const time = date.toLocaleTimeString('en-GB', { hour: 'numeric', minute: '2-digit', hour12: true })
  return `${day}, ${time}`
}
