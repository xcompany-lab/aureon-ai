import { useAuthStore } from '../store/authStore'
import { useNavigate } from 'react-router-dom'
import { useSystemStatus } from '../hooks/useSystemStatus'
import { ActivityFeed } from '../components/ActivityFeed'
import { AureonVisualizer } from '../components/AureonVisualizer'
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
    <div className="min-h-screen bg-[#010810] text-[#00FFFF] font-['Share_Tech_Mono'] select-none flex flex-col items-stretch hud-scanline">
      {/* Background Visualizer - Fixed/Absolute background */}
      <AureonVisualizer isListening={false} isProcessing={metricsLoading} audioLevel={0} />

      <div className="hud-container">
        {/* TOP BAR */}
        <header className="topbar">
          <div className="logo px-5 flex flex-col justify-center">
            <span className="text-lg font-black tracking-[0.3em] glitch">AUREON</span>
            <span className="text-[10px] opacity-70 tracking-[0.2em] font-light">OPERATING SYSTEM V1.0</span>
          </div>
          <div className="hud-section border-r border-line2 flex items-center gap-2" data-label="Status">
            <span className="text-[11px] text-glow uppercase">Neural Link: Active</span>
          </div>
          <div className="hud-section border-r border-line2 flex items-center gap-2" data-label="Operator">
            <span className="text-[11px]">{profile?.name || profile?.email || 'UNAUTHORIZED'}</span>
          </div>
          <div className="ml-auto px-6 h-full flex items-center border-l border-line2">
            <button
              onClick={handleSignOut}
              className="px-4 py-1 border border-red/30 hover:bg-red/20 text-red/60 text-[9px] font-black uppercase tracking-[0.2em] transition-all"
            >
              Terminate Session
            </button>
          </div>
        </header>

        {/* LEFT PANEL: DIAGNOSTICS */}
        <aside className="panel-side panel-left">
          <div className="hud-section" data-label="DIAGNÓSTICO">
            <div className="space-y-4 mt-2">
              {/* CPU */}
              <div>
                <div className="flex justify-between text-[10px] uppercase opacity-60 mb-1">
                  <span>Processor Load</span>
                  <span className="text-primary">{metricsLoading ? '--' : metrics.cpu}%</span>
                </div>
                <div className="h-1 bg-line2 relative overflow-hidden">
                  <div
                    className="absolute inset-y-0 left-0 bg-primary shadow-glow transition-all duration-1000"
                    style={{ width: `${metrics.cpu}%` }}
                  />
                </div>
              </div>

              {/* RAM */}
              <div>
                <div className="flex justify-between text-[10px] uppercase opacity-60 mb-1">
                  <span>Neural Memory</span>
                  <span className="text-secondary">{metricsLoading ? '--' : metrics.ram}%</span>
                </div>
                <div className="h-1 bg-line2 relative overflow-hidden">
                  <div
                    className="absolute inset-y-0 left-0 bg-secondary shadow-[0_0_10px_rgba(112,0,255,0.8)] transition-all duration-1000"
                    style={{ width: `${metrics.ram}%` }}
                  />
                </div>
              </div>

              {/* DISK */}
              <div>
                <div className="flex justify-between text-[10px] uppercase opacity-60 mb-1">
                  <span>Data Repository</span>
                  <span className="text-accent">{metricsLoading ? '--' : metrics.disk}%</span>
                </div>
                <div className="h-1 bg-line2 relative overflow-hidden">
                  <div
                    className="absolute inset-y-0 left-0 bg-accent shadow-[0_0_10px_rgba(0,255,150,0.8)] transition-all duration-1000"
                    style={{ width: `${metrics.disk}%` }}
                  />
                </div>
              </div>
            </div>
            <p className="text-[8px] mt-4 text-primary/40 font-mono tracking-tighter">
              STORAGE_LINK: SECURE | ENCRYPTION: AES-256
            </p>
          </div>

          <div className="flex-1 flex flex-col min-h-0">
            <div className="hud-section" data-label="SYSTEM_LOG">
              <div className="text-[9px] opacity-40 space-y-1 mt-2">
                <p>[OK] BOOT_SEQUENCE_COMPLETE</p>
                <p>[OK] NEURAL_SYNC_ESTABLISHED</p>
                <p>[OK] SQUAD_HEARTBEAT_ACTIVE</p>
              </div>
            </div>
          </div>

          <div className="p-4 mt-auto">
            <div className="ang-all border border-line bg-white/5 p-4 text-center">
              <span className="text-[10px] tracking-widest uppercase opacity-60">System Core</span>
              <div className="mt-2 text-primary font-bold">STABLE</div>
            </div>
          </div>
        </aside>

        {/* CENTER PANEL: CORE */}
        <main className="flex flex-col flex-1 overflow-hidden relative">
          <div className="flex-1 flex flex-col items-center justify-center relative">
            <div className="absolute inset-0 pointer-events-none opacity-20 flex items-center justify-center">
              <div className="w-[500px] h-[500px] rounded-full border border-primary/20 animate-spin-slow" />
              <div className="absolute w-[400px] h-[400px] rounded-full border border-dashed border-secondary/10 animate-reverse-spin-slow" />
            </div>

            <div className="z-10 text-center">
              <div className="mb-8">
                <h2 className="text-primary text-xs uppercase tracking-[0.5em] font-light mb-2">Neural Interface</h2>
                <div className="h-px w-32 mx-auto bg-gradient-to-r from-transparent via-primary/50 to-transparent" />
              </div>

              {/* This area is visually handled by AureonVisualizer's radar in background */}

              <div className="mt-24 space-y-6">
                <p className="text-glow text-primary text-[10px] uppercase tracking-[0.4em] font-light animate-pulse">
                  System Standby // Ready for Command
                </p>

                {/* Overlay Activation Button is typically floating, but let's put it here as a primary action if we want */}
                <div className="flex gap-4 justify-center">
                  <div className="text-[8px] opacity-30 mt-8 max-w-[200px] mx-auto leading-relaxed">
                    NAVIGATE TO COMMAND CENTER TO START NEURAL INTERACTION OR EXECUTE DIRECT PIPELINES.
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="px-4 py-2 border-t border-line2 flex justify-between items-center bg-black/20">
            <span className="text-[9px] tracking-widest uppercase opacity-50">Active Pipelines</span>
            <span className="text-[8px] opacity-30">SC-01 // READY</span>
          </div>
        </main>

        {/* RIGHT PANEL: ACTIVITY FEED */}
        <aside className="panel-side panel-right">
          <div className="px-4 py-3 border-b border-line2 flex justify-between items-center">
            <span className="text-[9px] tracking-widest uppercase opacity-50">Neural Log</span>
            <div className="h-1.5 w-1.5 rounded-full bg-primary animate-pulse shadow-glow" />
          </div>
          <div className="flex-1 overflow-hidden flex flex-col">
            <ActivityFeed />
          </div>

          <div className="hud-section mt-auto" data-label="KNOWLEDGE DNA">
            <div className="space-y-4 mt-4">
              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[8px] uppercase tracking-widest opacity-60">
                  <span>Filosofias</span><span>70%</span>
                </div>
                <div className="h-0.5 bg-line2 w-full"><div className="h-full bg-c" style={{ width: '70%' }} /></div>
              </div>
              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[8px] uppercase tracking-widest opacity-60">
                  <span>Mental Models</span><span>85%</span>
                </div>
                <div className="h-0.5 bg-line2 w-full"><div className="h-full bg-c2" style={{ width: '85%' }} /></div>
              </div>
            </div>
          </div>
        </aside>

        {/* BOTTOM BAR */}
        <footer className="bottombar h-9">
          <div className="px-4 border-r border-line2 flex items-center gap-2 h-full text-[9px] tracking-widest opacity-60">
            <div className="w-1.5 h-1.5 rounded-full bg-[#00FF88] shadow-[0_0_4px_#00FF88]" />
            CORE STABLE
          </div>
          <div className="px-4 border-r border-line2 flex items-center gap-2 h-full text-[9px] tracking-widest opacity-60">
            SECURE LINK V3.1
          </div>
          <div className="flex-1 flex items-center px-4 gap-4 h-full text-[8px] text-primary/40 uppercase font-mono">
            Aureon Core Engine Interface :: Terminal_ID: MB-03-26 :: Sector: 7G
          </div>
          <div className="px-4 border-l border-line2 flex items-center h-full text-[8px] font-mono text-primary/40">
            LATENCY: 14.82ms :: SESSION_STABLE
          </div>
        </footer>
      </div>

      {/* Voice Command Component - Handles its own isActive state and button */}
      <VoiceCommandOverlay />
    </div>
  )
}
