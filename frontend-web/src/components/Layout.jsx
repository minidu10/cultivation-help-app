import { useState } from 'react'
import Sidebar from './Sidebar'

export default function Layout({ children }) {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false)

  return (
    <div className="flex">
      <Sidebar isOpen={isSidebarOpen} setIsOpen={setIsSidebarOpen} />
      
      <main className="flex-1 min-h-screen bg-gray-50 flex flex-col w-full">
        {/* Top Header with Hamburger */}
        <header className="bg-white shadow-sm px-4 py-3 flex items-center shrink-0">
          <button 
            onClick={() => setIsSidebarOpen(true)}
            className="p-2 mr-3 text-gray-600 rounded-md hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
            aria-label="Open sidebar"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h1 className="text-xl font-semibold text-gray-800">Cultivation App</h1>
        </header>

        {/* Page Content */}
        <div className="flex-1 p-4 md:p-8 overflow-auto">
          {children}
        </div>
      </main>

      {/* Overlay when sidebar is open */}
      {isSidebarOpen && (
        <div 
          className="fixed inset-0 bg-transparent z-40"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}
    </div>
  )
}