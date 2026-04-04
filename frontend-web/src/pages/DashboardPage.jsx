import { useEffect, useState } from 'react'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend, PieChart, Pie, Cell
} from 'recharts'
import Layout from '../components/Layout'
import StatCard from '../components/StatCard'
import { getCrops, getProfitLoss } from '../api/crops'
import { getCropInsights } from '../api/crops'

const COLORS = ['#16a34a', '#dc2626', '#2563eb', '#d97706', '#7c3aed']

export default function DashboardPage() {
  const [crops, setCrops] = useState([])
  const [profitData, setProfitData] = useState([])
  const [loading, setLoading] = useState(true)
  const [insights, setInsights] = useState({})
  const [loadingInsights, setLoadingInsights] = useState(false)

  useEffect(() => {
    loadDashboard()
  }, [])

  const loadDashboard = async () => {
    try {
      const cropsRes = await getCrops()
      const cropList = cropsRes.data
      setCrops(cropList)

      // Load profit/loss for each crop
      const plData = await Promise.all(
        cropList.map(async (crop) => {
          try {
            const pl = await getProfitLoss(crop.id)
            return {
              name: crop.name,
              expenses: Number(pl.data.totalExpenses),
              revenue: Number(pl.data.totalRevenue),
              profit: Number(pl.data.netProfit),
              result: pl.data.result,
            }
          } catch {
            return {
              name: crop.name,
              expenses: 0,
              revenue: 0,
              profit: 0,
              result: 'N/A',
            }
          }
        })
      )
      setProfitData(plData)
      loadInsights(plData)
    } catch (err) {
      console.error('Dashboard load failed:', err)
    } finally {
      setLoading(false)
    }
  }
  const loadInsights = async (plData) => {
    setLoadingInsights(true)
    const results = {}

    for (const crop of plData) {
      try {
        const res = await getCropInsights({
          crop_name: crop.name,
          total_expenses: crop.expenses,
          total_revenue: crop.revenue,
          net_profit: crop.profit,
          status: crop.result,
        })
        results[crop.name] = res.data.insights
      } catch {
        results[crop.name] = null
      }
    }

    setInsights(results)
    setLoadingInsights(false)
  }

  // Summary totals
  const totalRevenue = profitData.reduce((s, d) => s + d.revenue, 0)
  const totalExpenses = profitData.reduce((s, d) => s + d.expenses, 0)
  const netProfit = totalRevenue - totalExpenses
  const activeCrops = crops.filter(
    (c) => c.status !== 'HARVESTED' && c.status !== 'FAILED'
  ).length

  // Pie chart data — expense vs revenue
  const pieData = [
    { name: 'Total Revenue', value: totalRevenue },
    { name: 'Total Expenses', value: totalExpenses },
  ]

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <p className="text-gray-400 animate-pulse">Loading dashboard...</p>
        </div>
      </Layout>
    )
  }

  return (
    <Layout>
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-500 mt-1">
          Your farm performance at a glance
        </p>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard
          title="Total Revenue"
          value={`Rs. ${totalRevenue.toLocaleString()}`}
          sub="All crops"
          color="green"
        />
        <StatCard
          title="Total Expenses"
          value={`Rs. ${totalExpenses.toLocaleString()}`}
          sub="All crops"
          color="red"
        />
        <StatCard
          title="Net Profit"
          value={`Rs. ${netProfit.toLocaleString()}`}
          sub={netProfit >= 0 ? '✅ Profitable' : '❌ Loss'}
          color={netProfit >= 0 ? 'green' : 'red'}
        />
        <StatCard
          title="Active Crops"
          value={activeCrops}
          sub={`${crops.length} total`}
          color="blue"
        />
      </div>

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">

        {/* Bar chart — revenue vs expenses per crop */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Revenue vs Expenses by Crop
          </h2>
          {profitData.length === 0 ? (
            <p className="text-gray-400 text-sm text-center py-10">
              No crop data yet — add crops and expenses to see charts
            </p>
          ) : (
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={profitData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip
                  formatter={(value) => `Rs. ${value.toLocaleString()}`}
                />
                <Legend />
                <Bar dataKey="revenue" name="Revenue"
                     fill="#16a34a" radius={[4, 4, 0, 0]} />
                <Bar dataKey="expenses" name="Expenses"
                     fill="#dc2626" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Pie chart — revenue vs expenses overall */}
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h2 className="text-base font-semibold text-gray-700 mb-4">
            Revenue vs Expenses Overview
          </h2>
          {totalRevenue === 0 && totalExpenses === 0 ? (
            <p className="text-gray-400 text-sm text-center py-10">
              No financial data yet
            </p>
          ) : (
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={pieData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={4}
                  dataKey="value"
                  label={({ name, percent }) =>
                    `${name} ${(percent * 100).toFixed(0)}%`
                  }
                >
                  {pieData.map((_, index) => (
                    <Cell key={index} fill={COLORS[index]} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value) => `Rs. ${value.toLocaleString()}`}
                />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* Crop profit/loss table */}
      <div className="bg-white rounded-xl border border-gray-200 p-5">
        <h2 className="text-base font-semibold text-gray-700 mb-4">
          Crop Performance
        </h2>
        {profitData.length === 0 ? (
          <p className="text-gray-400 text-sm text-center py-6">
            No crops added yet
          </p>
        ) : (
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-gray-500 border-b border-gray-100">
                <th className="pb-2 font-medium">Crop</th>
                <th className="pb-2 font-medium">Revenue</th>
                <th className="pb-2 font-medium">Expenses</th>
                <th className="pb-2 font-medium">Net Profit</th>
                <th className="pb-2 font-medium">Result</th>
              </tr>
            </thead>
            <tbody>
              {profitData.map((row, i) => (
                <tr key={i}
                    className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="py-3 font-medium text-gray-800">
                    {row.name}
                  </td>
                  <td className="py-3 text-green-600">
                    Rs. {row.revenue.toLocaleString()}
                  </td>
                  <td className="py-3 text-red-500">
                    Rs. {row.expenses.toLocaleString()}
                  </td>
                  <td className="py-3 font-semibold">
                    Rs. {row.profit.toLocaleString()}
                  </td>
                  <td className="py-3">
                    <span className={`px-2 py-1 rounded-full text-xs
                      font-medium ${
                        row.result === 'PROFIT'
                          ? 'bg-green-100 text-green-700'
                          : row.result === 'LOSS'
                          ? 'bg-red-100 text-red-700'
                          : 'bg-gray-100 text-gray-500'
                      }`}>
                      {row.result}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
      {/* AI Insights */}
     {profitData.length > 0 && (
        <div className="mt-6">
          <div className="flex items-center gap-2 mb-4">
            <h2 className="text-base font-semibold text-gray-700">
              🤖 AI Insights
            </h2>
            <span className="text-xs bg-green-100 text-green-700
                            px-2 py-1 rounded-full font-medium">
              Powered by Groq
            </span>
          </div>

          {loadingInsights ? (
            <div className="bg-white rounded-xl border border-gray-200
                            p-8 text-center">
              <p className="text-gray-400 animate-pulse text-sm">
                🤖 AI is analysing your crops...
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {profitData.map((crop, i) => (
                <div key={i}
                    className="bg-white rounded-xl border border-gray-200 p-5">
                  <div className="flex items-center gap-2 mb-3">
                    <span className="text-lg">🌾</span>
                    <h3 className="font-semibold text-gray-800">
                      {crop.name}
                    </h3>
                    <span className={`ml-auto text-xs px-2 py-1
                                    rounded-full font-medium ${
                      crop.result === 'PROFIT'
                        ? 'bg-green-100 text-green-700'
                        : 'bg-red-100 text-red-700'
                    }`}>
                      {crop.result}
                    </span>
                  </div>

                  {insights[crop.name] ? (
                    <div className="text-sm text-gray-600 leading-relaxed
                                    space-y-1">
                      {insights[crop.name]
                        .split('\n')
                        .filter((line) => line.trim())
                        .map((line, j) => (
                          <p key={j}>{line}</p>
                        ))}
                    </div>
                  ) : (
                    <p className="text-sm text-gray-400">
                      No insights available
                    </p>
                  )}

                  <div className="mt-4 pt-3 border-t border-gray-100
                                  grid grid-cols-3 gap-2 text-center">
                    <div>
                      <p className="text-xs text-gray-400">Revenue</p>
                      <p className="text-sm font-semibold text-green-600">
                        Rs. {crop.revenue.toLocaleString()}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400">Expenses</p>
                      <p className="text-sm font-semibold text-red-500">
                        Rs. {crop.expenses.toLocaleString()}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400">Profit</p>
                      <p className={`text-sm font-semibold ${
                        crop.profit >= 0
                          ? 'text-green-700' : 'text-red-600'
                      }`}>
                        Rs. {crop.profit.toLocaleString()}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </Layout>
  )
}