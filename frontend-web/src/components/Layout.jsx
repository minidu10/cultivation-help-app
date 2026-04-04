import Sidebar from './Sidebar'

export default function Layout({ children }) {
  return (
    <div className="flex">
      <Sidebar />
      <main className="ml-64 flex-1 min-h-screen bg-gray-50 p-8">
        {children}
      </main>
    </div>
  )
}