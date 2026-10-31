import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import DashboardPage from './DashboardPage'
import { http, HttpResponse, server } from '../test/server'
import { renderWithApp, signIn } from '../test/render'

const SUMMARY = {
  totals: { totalRevenue: 2000, totalExpenses: 1800.5, netProfit: 199.5, activeCrops: 1, totalCrops: 2 },
  crops: [
    {
      cropId: 1, cropName: 'Paddy', status: 'GROWING', fieldLocation: '', aiInsightsEnabled: false,
      totalExpenses: 1500.5, totalRevenue: 2000, netProfit: 499.5, result: 'PROFIT',
    },
    {
      cropId: 2, cropName: 'Big Onion', status: 'FAILED', fieldLocation: '', aiInsightsEnabled: false,
      totalExpenses: 300, totalRevenue: 0, netProfit: -300, result: 'LOSS',
    },
  ],
  dueReminders: [
    { id: 9, cropId: 1, title: 'Apply urea', type: 'FERTILIZER', reminderAt: '2026-05-10T07:00:00', enabled: true, completed: false },
  ],
  upcomingReminders: [],
}

/** The value shown on a stat card. Totals also appear in charts and tables, so match by card. */
async function statValue(title) {
  const [label] = await screen.findAllByText(title)
  return label.parentElement.nextElementSibling.textContent
}

describe('DashboardPage', () => {
  it('builds every figure from the single summary request', async () => {
    signIn()
    const profitLossCalls = []
    server.use(
      http.get('/api/dashboard/summary', () => HttpResponse.json(SUMMARY)),
      // The old dashboard asked once per crop; it must not any more.
      http.get('/api/crops/:id/expenses/profit-loss', ({ params }) => {
        profitLossCalls.push(params.id)
        return HttpResponse.json({})
      }),
    )

    renderWithApp(<DashboardPage />)

    expect(await statValue('Harvest Revenue')).toBe('Rs. 2,000')
    expect(await statValue('Total Expenses')).toBe('Rs. 1,800.5')
    expect(await statValue('Net Profit')).toBe('Rs. 199.5')
    expect(await statValue('Active Crops')).toBe('1')
    expect(screen.getByText('2 total')).toBeInTheDocument()
    expect(screen.getByText('Apply urea')).toBeInTheDocument()
    expect(profitLossCalls).toEqual([])
  })

  it('does not ask for AI insights on crops that have them switched off', async () => {
    signIn()
    const insightCalls = []
    server.use(
      http.get('/api/dashboard/summary', () => HttpResponse.json(SUMMARY)),
      http.get('/api/crops/:id/insights', ({ params }) => {
        insightCalls.push(params.id)
        return HttpResponse.json({ insights: 'x' })
      }),
    )

    renderWithApp(<DashboardPage />)
    expect(await statValue('Total Expenses')).toBe('Rs. 1,800.5')

    expect(insightCalls).toEqual([])
  })

  // Regression: with no saved city and no geolocation, the fallback lookup
  // used to reject unhandled and leave the weather card blank.
  it('says so when weather cannot be loaded', async () => {
    signIn()
    server.use(http.get('/api/dashboard/summary', () => HttpResponse.json(SUMMARY)))

    renderWithApp(<DashboardPage />)

    expect(await screen.findByText('Unable to load weather now.')).toBeInTheDocument()
  })

  it('falls back from an unknown saved city to coordinates', async () => {
    signIn({ user: { fullName: 'Test Farmer', email: 'farmer@example.com', city: 'Nowhereville' } })
    server.use(
      http.get('/api/dashboard/summary', () => HttpResponse.json(SUMMARY)),
      http.get('/api/weather/current/by-location', () => HttpResponse.json({ message: 'Location not found' }, { status: 404 })),
      http.get('/api/weather/daily/by-location', () => HttpResponse.json({ message: 'Location not found' }, { status: 404 })),
      http.get('/api/weather/current', () => HttpResponse.json({ location: 'Colombo, LK', temperatureC: 31, description: 'scattered clouds' })),
      http.get('/api/weather/daily', () => HttpResponse.json({ location: 'Colombo, LK', days: [] })),
    )

    renderWithApp(<DashboardPage />)

    expect(await screen.findByText('scattered clouds')).toBeInTheDocument()
  })
})
