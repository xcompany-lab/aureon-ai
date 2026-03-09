import { useAuthStore } from '../store/authStore'
import { useNavigate } from 'react-router-dom'
import { useSystemStatus } from '../hooks/useSystemStatus'
import { ActivityFeed } from '../components/ActivityFeed'
import { AureonCore } from '../components/AureonCore'
import { VoiceCommandOverlay } from '../components/VoiceCommandOverlay'

export default function Dashboard() {
  const { profile, signOut } = useAuthStore()
  const { metrics, loading: metricsLoading } = useSystemStatus()
  const navigate = useNavigate()

  const handleSignOut = async () => {
    await signOut()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-background p-4 md:p-8 hud-scanline">
      <div className="max-w-7xl mx-auto space-y-8">
        {/* Top Navigation / HUD Bar */}
        <div className="flex items-center justify-between glass p-4 rounded-lg border-b border-primary/30">
          <div className="flex items-center gap-4">
            <div className="h-10 w-10 rounded-full border border-primary/50 flex items-center justify-center bg-primary/10">
              <span className="text-primary font-bold text-xl leading-none">A</span>
            </div>
            <div>
              <h1 className="text-2xl font-bold text-glow tracking-widest text-primary uppercase">
                Aureon <span className="text-foreground/50 font-light">OS v1.0</span>
              </h1>
              <div className="flex items-center gap-2 text-[10px] uppercase tracking-tighter text-muted-foreground">
                <span className="inline-block w-1.5 h-1.5 rounded-full bg-accent animate-pulse" />
                Neural Connection: ACTIVE
              </div>
            </div>
          </div>

          <div className="flex items-center gap-6">
            <div className="hidden md:block text-right">
              <p className="text-xs text-muted-foreground uppercase">System Operator</p>
              <p className="text-sm font-semibold text-primary">{profile?.name || profile?.email}</p>
            </div>
            <button
              onClick={handleSignOut}
              className="px-4 py-2 border border-destructive/50 hover:bg-destructive/10 text-destructive text-xs uppercase tracking-widest rounded transition-all"
            >
              Terminate Session
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Left: System Metrics HUD */}
          <div className="lg:col-span-1 space-y-6">
            <h2 className="text-xs font-bold text-primary/70 uppercase tracking-[0.2em] mb-4">Diagnostics</h2>

            {/* Metric Card 1: CPU */}
            <div className="glass p-5 rounded-lg border-l-2 border-primary">
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] uppercase text-muted-foreground">Processor Load</span>
                <span className="text-xs font-mono text-primary">{metricsLoading ? '--' : metrics.cpu}%</span>
              </div>
              <div className="h-1 w-full bg-primary/10 rounded-full overflow-hidden">
                <div
                  className="h-full bg-primary shadow-[0_0_10px_rgba(0,242,255,0.8)] transition-all duration-1000"
                  style={{ width: `${metrics.cpu}%` }}
                />
              </div>
              <p className="text-[8px] mt-2 text-muted-foreground font-mono">CORE_TEMP: OPTIMAL | CYCLES: SYNC</p>
            </div>

            {/* Metric Card 2: RAM */}
            <div className="glass p-5 rounded-lg border-l-2 border-secondary">
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] uppercase text-muted-foreground">Neural Memory</span>
                <span className="text-xs font-mono text-secondary">{metricsLoading ? '--' : metrics.ram}%</span>
              </div>
              <div className="h-1 w-full bg-secondary/10 rounded-full overflow-hidden">
                <div
                  className="h-full bg-secondary shadow-[0_0_10px_rgba(112,0,255,0.8)] transition-all duration-1000"
                  style={{ width: `${metrics.ram}%` }}
                />
              </div>
              <p className="text-[8px] mt-2 text-muted-foreground font-mono">BUFFER: ACTIVE | SWAP: STANDBY</p>
            </div>

            {/* Metric Card 3: Storage */}
            <div className="glass p-5 rounded-lg border-l-2 border-accent">
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] uppercase text-muted-foreground">Data Repository</span>
                <span className="text-xs font-mono text-accent">{metricsLoading ? '--' : metrics.disk}%</span>
              </div>
              <div className="h-1 w-full bg-accent/10 rounded-full overflow-hidden">
                <div
                  className="h-full bg-accent shadow-[0_0_10px_rgba(0,255,150,0.8)] transition-all duration-1000"
                  style={{ width: `${metrics.disk}%` }}
                />
              </div>
              <p className="text-[8px] mt-2 text-muted-foreground font-mono">STORAGE_LINK: SECURE | ENCRYPTION: AES-256</p>
            </div>
          </div>

          {/* Center: The Core Interaction Area */}
          <div className="lg:col-span-2 flex flex-col items-center justify-center min-h-[400px] relative">
            <div className="absolute inset-0 pointer-events-none opacity-20 flex items-center justify-center overflow-hidden">
              <div className="w-[500px] h-[500px] rounded-full border border-primary/20 animate-spin-slow" />
              <div className="absolute w-[300px] h-[300px] rounded-full border border-dashed border-secondary/20 animate-reverse-spin-slow" />
            </div>

            <AureonCore size="lg" />

            <div className="mt-12 text-center space-y-4">
              <p className="text-glow text-primary text-sm uppercase tracking-[0.3em] font-light">
                Listening for Command
              </p>
              <div className="flex gap-4 justify-center">
                <button className="px-6 py-2 glass hover:bg-primary/20 text-primary text-xs uppercase tracking-widest rounded border border-primary/50 transition-all">
                  Text Input
                </button>
                <button className="px-6 py-2 bg-primary/20 hover:bg-primary/40 text-primary text-xs uppercase tracking-widest rounded border border-primary shadow-[0_0_15px_rgba(0,242,255,0.3)] transition-all">
                  Voice Mode
                </button>
              </div>
            </div>
          </div>

          {/* Right: Activity / Log HUD */}
          <div className="lg:col-span-1 space-y-4 h-full">
            <div className="glass rounded-lg p-5 flex flex-col h-[500px] border-r-2 border-primary/50">
              <div className="flex items-center justify-between mb-4 pb-2 border-b border-primary/20">
                <h2 className="text-xs font-bold text-primary uppercase tracking-[0.2em]">Live Stream</h2>
                <div className="h-1.5 w-1.5 rounded-full bg-primary animate-pulse shadow-[0_0_8px_rgba(0,242,255,1)]" />
              </div>
              <ActivityFeed />
            </div>
          </div>
        </div>
      </div>

      {/* Voice Command Component */}
      <VoiceCommandOverlay />

      {/* Decorative HUD Elements */}
      <div className="fixed bottom-4 left-4 text-[8px] font-mono text-primary/40 uppercase pointer-events-none">
        Aureon Core Engine Interface :: Terminal_ID: MB-03-26 :: Sector: 7G
      </div>
      <div className="fixed bottom-4 right-4 text-[8px] font-mono text-primary/40 uppercase pointer-events-none">
        LATENCY: {(Math.random() * 20 + 10).toFixed(2)}ms :: ENCRYPTION: ACTIVE :: SESSION_STABLE
      </div>
    </div>
  )
}
