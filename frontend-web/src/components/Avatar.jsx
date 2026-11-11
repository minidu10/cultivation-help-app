import { useEffect, useState } from 'react'
import { getMyPhoto } from '../api/users'

/**
 * The farmer's profile picture, or their initials when there is none.
 * `version` changes whenever the picture does, so a new upload refetches.
 */
export default function Avatar({ name, version, size = 32, className, style }) {
  // Remembers which version the loaded picture belongs to, so a stale one is never shown.
  const [loaded, setLoaded] = useState({ version: null, url: null })

  useEffect(() => {
    if (!version) return undefined
    let cancelled = false
    let objectUrl = null
    getMyPhoto()
      .then((res) => {
        if (cancelled) return
        objectUrl = URL.createObjectURL(res.data)
        setLoaded({ version, url: objectUrl })
      })
      .catch(() => {})
    return () => {
      cancelled = true
      if (objectUrl) URL.revokeObjectURL(objectUrl)
    }
  }, [version])

  const url = version && loaded.version === version ? loaded.url : null
  const initials = (name || 'U').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()

  return (
    <span
      aria-hidden="true"
      className={className}
      style={{
        width: size, height: size, borderRadius: '50%', flexShrink: 0, overflow: 'hidden',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        fontSize: Math.round(size * 0.38), fontWeight: 700, ...style,
      }}
    >
      {url ? <img src={url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : initials}
    </span>
  )
}
