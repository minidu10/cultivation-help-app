/**
 * Shrinks a camera photo before upload: a 12 MP phone picture is 4-6 MB,
 * and on a rural connection that is minutes of waiting for detail the model
 * does not need. Orientation is applied from EXIF, so a portrait photo stays
 * upright once the metadata is gone.
 *
 * Falls back to the original file wherever the browser cannot do this; the
 * server accepts up to 5 MB and shrinks it anyway.
 */
export async function resizePhoto(file, maxSide = 1280, quality = 0.85) {
  try {
    if (typeof createImageBitmap !== 'function') return file
    const bitmap = await createImageBitmap(file, { imageOrientation: 'from-image' })
    const scale = Math.min(1, maxSide / Math.max(bitmap.width, bitmap.height))
    const canvas = document.createElement('canvas')
    canvas.width = Math.round(bitmap.width * scale)
    canvas.height = Math.round(bitmap.height * scale)
    const context = canvas.getContext('2d')
    if (!context) return file
    context.drawImage(bitmap, 0, 0, canvas.width, canvas.height)
    bitmap.close?.()
    const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', quality))
    return blob ? new File([blob], 'photo.jpg', { type: 'image/jpeg' }) : file
  } catch {
    return file
  }
}
