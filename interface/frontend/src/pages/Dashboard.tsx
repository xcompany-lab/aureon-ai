import { useAuthStore } from '../store/authStore'
import { useNavigate } from 'react-router-dom'

export default function Dashboard() {
  const { profile, signOut } = useAuthStore()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-background p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gradient">Dashboard</h1>
            <p className="text-muted-foreground mt-1">
              Welcome back, {profile?.name || profile?.email}!
            </p>
          </div>
          <button
            onClick={handleSignOut}
            className="px-4 py-2 bg-destructive hover:bg-destructive/90 text-destructive-foreground rounded-md transition-colors"
          >
            Sign Out
          </button>
        </div>

        {/* User Info Card */}
        <div className="glass rounded-lg p-6 mb-6">
          <h2 className="text-xl font-semibold mb-4">User Information</h2>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Email:</span>
              <span>{profile?.email}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Name:</span>
              <span>{profile?.name || 'Not set'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Role:</span>
              <span className="capitalize">{profile?.role}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Timezone:</span>
              <span>{profile?.timezone}</span>
            </div>
          </div>
        </div>

        {/* Placeholder Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* CPU Card */}
          <div className="glass rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-2">CPU Status</h3>
            <p className="text-3xl font-bold text-primary">--</p>
            <p className="text-sm text-muted-foreground mt-2">Coming soon...</p>
          </div>

          {/* RAM Card */}
          <div className="glass rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-2">RAM Status</h3>
            <p className="text-3xl font-bold text-secondary">--</p>
            <p className="text-sm text-muted-foreground mt-2">Coming soon...</p>
          </div>

          {/* Disk Card */}
          <div className="glass rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-2">Disk Status</h3>
            <p className="text-3xl font-bold text-accent">--</p>
            <p className="text-sm text-muted-foreground mt-2">Coming soon...</p>
          </div>
        </div>

        {/* Info Banner */}
        <div className="mt-8 glass rounded-lg p-6">
          <h3 className="text-lg font-semibold mb-2">🚀 Phase 1: Foundation Complete!</h3>
          <p className="text-muted-foreground">
            Authentication is working! Next steps:
          </p>
          <ul className="list-disc list-inside text-sm text-muted-foreground mt-2 space-y-1">
            <li>Real-time system metrics integration</li>
            <li>SQUAD status cards</li>
            <li>Activity feed with live events</li>
            <li>Charts with historical data</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
