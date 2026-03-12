import React, { useState, useRef, useEffect } from 'react'
import { voiceService } from '../services/voice'
import { AureonVisualizer } from './AureonVisualizer'

interface Message {
    id: string
    type: 'user' | 'aureon'
    text: string
    time: string
    cost?: number
}

export const VoiceCommandOverlay: React.FC = () => {
    const [isActive, setIsActive] = useState(false)
    const [isListening, setIsListening] = useState(false)
    const [isProcessing, setIsProcessing] = useState(false)
    const [audioLevel, setAudioLevel] = useState(0)
    const [status, setStatus] = useState('STANDBY')
    const [messages, setMessages] = useState<Message[]>([
        { id: '1', type: 'aureon', text: 'Sessão SES-0471 iniciada — Sistema Online', time: '14:55:30' },
        { id: '2', type: 'aureon', text: 'Supabase DB CONECTADO — 8 tabelas ativas', time: '14:54:10' }
    ])
    const [sessionCost, setSessionCost] = useState(0.13)
    const [timeStr, setTimeStr] = useState('00:00:00')
    const [dateStr, setDateStr] = useState('')
    const [commandInput, setCommandInput] = useState('')

    const logEndRef = useRef<HTMLDivElement>(null)
    const waveCanvasRef = useRef<HTMLCanvasElement>(null)
    const waveData = useRef(new Array(40).fill(0))

    // ── CLOCK & DATE ──
    useEffect(() => {
        const tick = () => {
            const now = new Date()
            setTimeStr(now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }))

            const days = ['Domingo', 'Segunda-Feira', 'Terça-Feira', 'Quarta-Feira', 'Quinta-Feira', 'Sexta-Feira', 'Sábado']
            const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']
            setDateStr(`${days[now.getDay()]}, ${now.getDate()} ${months[now.getMonth()]}`)
        }
        tick()
        const timer = setInterval(tick, 1000)
        return () => clearInterval(timer)
    }, [])

    // ── WAVEFORM VIZ ──
    useEffect(() => {
        if (!isActive) return
        const cvs = waveCanvasRef.current
        if (!cvs) return
        const ctx = cvs.getContext('2d')
        if (!ctx) return

        let wT = 0
        const drawWave = () => {
            wT += 0.1
            waveData.current.shift()
            const boost = isListening ? (audioLevel / 2) : 2
            waveData.current.push(Math.sin(wT) * (boost * 3) + Math.sin(wT * 2.3) * (boost * 1.5) + (Math.random() - 0.5) * 2)

            ctx.clearRect(0, 0, cvs.width, cvs.height)
            ctx.beginPath()
            waveData.current.forEach((v, i) => {
                const x = (i / waveData.current.length) * cvs.width
                const y = cvs.height / 2 - v
                i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y)
            })
            ctx.strokeStyle = `rgba(0, 255, 255, ${isListening ? 0.9 : 0.4})`
            ctx.lineWidth = 1.5
            ctx.stroke()
            if (isActive) setTimeout(() => requestAnimationFrame(drawWave), 50)
        }
        drawWave()
    }, [isActive, isListening, audioLevel])

    const addMessage = (type: 'user' | 'aureon', text: string, cost?: number) => {
        const msg: Message = {
            id: String(Date.now()),
            type,
            text,
            time: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
            cost
        }
        setMessages(prev => [msg, ...prev.slice(0, 19)])
        if (cost) setSessionCost(prev => prev + cost)
    }

    const playAudio = (base64: string) => {
        try {
            const audio = new Audio(`data:audio/mp3;base64,${base64}`);
            audio.play().catch(e => console.warn('Autoplay prevented or audio error:', e));
        } catch (e) {
            console.error('Falha ao tocar áudio:', e);
        }
    }

    const handleStartListening = async () => {
        setIsListening(true)
        setStatus('ESCUTANDO COMANDO...')
        await voiceService.startRecording((level) => setAudioLevel(level))
    }

    const handleStopListening = async () => {
        setIsListening(false)
        setAudioLevel(0)
        setStatus('ANALISANDO...')
        const blob = await voiceService.stopRecording()
        if (blob && blob.size > 200) {
            processAudio(blob)
        } else {
            addMessage('aureon', 'Aviso: Áudio não captado. Verifique as permissões de microfone ou fale um pouco mais alto, senhor.')
            setStatus('STANDBY')
        }
    }

    const processAudio = async (blob: Blob) => {
        setIsProcessing(true)
        setStatus('PROCESSANDO...')
        try {
            const formData = new FormData()
            formData.append('audio', blob, 'audio.webm')
            const response = await fetch(`${import.meta.env.VITE_API_URL}/api/voice/process`, { method: 'POST', body: formData })

            if (!response.ok) {
                const errData = await response.json().catch(() => ({ error: `Erro HTTP ${response.status}` }))
                throw new Error(errData.error || 'Erro desconhecido no servidor')
            }

            const data = await response.json()
            if (data.status === 'success') {
                addMessage('user', data.transcription)
                setStatus('SINC_NUCLEUS...')
                setTimeout(() => {
                    addMessage('aureon', data.response, data.cost)
                    if (data.audio_base64) playAudio(data.audio_base64)
                    setStatus('STANDBY')
                    setIsProcessing(false)
                }, 300)
            } else {
                throw new Error(data.error || 'Erro desconhecido no processamento')
            }
        } catch (error: any) {
            let errorMsg = 'Falha na conexão'
            if (error.message) errorMsg = error.message

            // Handle HTTP errors that didn't throw properly
            addMessage('aureon', `Erro Crítico: ${errorMsg}`)
            setStatus('ERRO_STANDBY')
            setIsProcessing(false)
        }
    }

    const handleCommandInput = async (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && commandInput) {
            const userMsg = commandInput
            setCommandInput('')
            addMessage('user', userMsg)
            setIsProcessing(true)
            setStatus('PROCESSANDO TEXTO...')

            try {
                const response = await fetch(`${import.meta.env.VITE_API_URL}/api/chat/process`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ text: userMsg })
                })

                if (!response.ok) {
                    const errData = await response.json().catch(() => ({ error: `Erro HTTP ${response.status}` }))
                    throw new Error(errData.error || 'Erro desconhecido no servidor')
                }

                const data = await response.json()
                if (data.status === 'success') {
                    setStatus('SINC_NUCLEUS...')
                    setTimeout(() => {
                        addMessage('aureon', data.response, data.cost)
                        if (data.audio_base64) playAudio(data.audio_base64)
                        setStatus('STANDBY')
                        setIsProcessing(false)
                    }, 300)
                } else {
                    throw new Error(data.error || 'Erro desconhecido no processamento')
                }
            } catch (error: any) {
                addMessage('aureon', `Erro Crítico: ${error.message || 'Falha na conexão'}`)
                setStatus('ERRO_STANDBY')
                setIsProcessing(false)
            }
        }
    }

    // Background hiding
    useEffect(() => {
        const mainContent = document.querySelector('.hud-container');
        if (isActive) {
            document.body.style.overflow = 'hidden';
            if (mainContent) (mainContent as HTMLElement).style.opacity = '0';
        } else {
            document.body.style.overflow = 'unset';
            if (mainContent) (mainContent as HTMLElement).style.opacity = '1';
        }
    }, [isActive]);

    if (!isActive) {
        return (
            <button
                onClick={() => setIsActive(true)}
                className="fixed bottom-8 right-8 z-50 ang-all border border-line bg-dim p-4 text-primary hover:bg-primary/20 transition-all font-mono text-[9px] tracking-widest"
            >
                AUREON COMMAND CENTER :: ATIVAR
            </button>
        )
    }

    return (
        <div className="fixed inset-0 z-[100] bg-[#010810] text-[#00FFFF] font-['Share_Tech_Mono'] select-none flex flex-col items-stretch hud-scanline">
            <AureonVisualizer isListening={isListening} isProcessing={isProcessing} audioLevel={audioLevel} />

            <div className="hud-container">
                {/* TOP BAR */}
                <header className="topbar">
                    <div className="logo px-5 flex flex-col justify-center">
                        <span className="text-lg font-black tracking-[0.3em] glitch">AUREON</span>
                        <span className="text-[10px] opacity-70 tracking-[0.2em] font-light">OPERATING SYSTEM</span>
                    </div>
                    <div className="hud-section border-r border-line2 flex items-center gap-2" data-label="Sistema">
                        <span className="text-[11px] text-glow">AUREON-CORE-V2.0.0</span>
                    </div>
                    <div className="hud-section border-r border-line2 flex items-center gap-2" data-label="Data">
                        <span className="text-[11px]">{dateStr}</span>
                    </div>
                    <div className="hud-section border-r border-line2 flex items-center gap-2" data-label="Sessão">
                        <span className="text-[11px]">SES-0471</span>
                    </div>
                    <div className="flex items-center gap-4 px-6 border-l border-line2">
                        <div className="flex items-center gap-2">
                            <div className="pulse-active"></div>
                            <span className="text-[9px] tracking-widest uppercase">Neural Link Ativo</span>
                        </div>
                        <div className="flex items-center gap-2 text-[#00FF88]">
                            <div className="pulse-active bg-[#00FF88] shadow-[#00FF88]"></div>
                            <span className="text-[9px] tracking-widest uppercase">OpenClaw Online</span>
                        </div>
                    </div>
                    <div className="ml-auto px-6 h-full flex items-center border-l border-line2 font-orbitron text-lg font-bold glitch">
                        {timeStr}
                    </div>
                </header>

                {/* LEFT PANEL */}
                <aside className="panel-side panel-left">
                    <div className="hud-section" data-label="DIAGNÓSTICO">
                        <div className="flex justify-between py-1 text-[9px] opacity-60 uppercase"><span>Neural Link</span><span className="text-[#00FF88]">Ativo</span></div>
                        <div className="flex justify-between py-1 text-[9px] opacity-60 uppercase"><span>Voice Engine</span><span className="text-[#00FF88]">Online</span></div>
                        <div className="flex justify-between py-1 text-[9px] opacity-60 uppercase"><span>Supabase DB</span><span className="text-[#00FF88]">Conectado</span></div>
                        <div className="flex justify-between py-1 text-[9px] opacity-60 uppercase"><span>WhatsApp</span><span className="text-[#00FF88]">Paired</span></div>
                        <div className="flex justify-between py-1 text-[9px] opacity-60 uppercase"><span>Custo Sessão</span><span className="text-[#FFB300]">${sessionCost.toFixed(4)}</span></div>
                    </div>

                    <div className="hud-section" data-label="SISTEMA">
                        <div className="flex justify-between text-[9px] opacity-60 uppercase mt-2"><span>CPU</span><span>34%</span></div>
                        <div className="h-0.5 bg-line2 mt-1 relative overflow-hidden"><div className="absolute inset-y-0 left-0 bg-gradient-to-r from-c2 to-c w-[34%] shadow-glow" /></div>
                        <div className="flex justify-between text-[9px] opacity-60 uppercase mt-3"><span>RAM</span><span>61%</span></div>
                        <div className="h-0.5 bg-line2 mt-1 relative overflow-hidden"><div className="absolute inset-y-0 left-0 bg-gradient-to-r from-warn to-[#ff8800] w-[61%] shadow-glow" /></div>
                        <div className="flex justify-between text-[9px] opacity-60 uppercase mt-3"><span>Disco</span><span>28%</span></div>
                        <div className="h-0.5 bg-line2 mt-1 relative overflow-hidden"><div className="absolute inset-y-0 left-0 bg-gradient-to-r from-c2 to-c w-[28%] shadow-glow" /></div>
                    </div>

                    <div className="flex-1 flex flex-col min-h-0">
                        <div className="px-4 py-2 border-b border-line2 flex justify-between items-center">
                            <span className="text-[9px] tracking-widest uppercase opacity-50">Squads Online</span>
                            <span className="text-[8px] opacity-30">7 / 7 →</span>
                        </div>
                        <div className="flex-1 overflow-y-auto p-4 space-y-2">
                            {['Sales', 'Executive', 'Operations', 'Marketing', 'Technology'].map((name, i) => (
                                <div key={name} className="flex items-center gap-3 py-1 border-b border-white/5 last:border-0 hover:bg-white/5 transition-colors cursor-pointer group">
                                    <span className="text-[8px] opacity-30">0{i + 1}</span>
                                    <div className="w-1.5 h-1.5 rounded-full bg-[#00FF88] shadow-[0_0_4px_#00FF88]" />
                                    <span className="text-[10px] uppercase tracking-wider flex-1">{name}</span>
                                    <span className="text-[8px] opacity-40">OK</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="hud-section" data-label="NÍVEL DE ÁUDIO">
                        <canvas ref={waveCanvasRef} width="190" height="40" className="w-full mt-2" />
                    </div>

                    <button
                        onClick={() => setIsActive(false)}
                        className="m-4 py-3 ang-all border border-red/30 text-red/60 text-[9px] font-black uppercase tracking-[0.4em] hover:bg-red/20 transition-all"
                    >
                        Terminate Connection
                    </button>
                </aside>

                {/* CENTER PANEL */}
                <main className="flex flex-col flex-1 overflow-hidden relative">
                    <div className="grid grid-cols-4 border-b border-line2">
                        {[
                            { label: 'Squads Ativos', val: '7', sub: '/ 7 Total', color: 'text-[#00FF88]' },
                            { label: 'Knowledge Nodes', val: '142', sub: '+8 Session', color: 'text-primary' },
                            { label: 'Pipelines', val: '3', sub: '1 Processing', color: 'text-warn' },
                            { label: 'Custo Total', val: `$${sessionCost.toFixed(2)}`, sub: 'Current Session', color: 'text-primary' },
                        ].map((m, i) => (
                            <div key={i} className="p-4 border-r border-line2 last:border-0 flex flex-col gap-1">
                                <span className="text-[8px] tracking-widest text-primary/40 uppercase">{m.label}</span>
                                <span className={`font-orbitron text-xl font-bold ${m.color} text-glow`}>{m.val}</span>
                                <span className="text-[8px] opacity-30 uppercase">{m.sub}</span>
                            </div>
                        ))}
                    </div>

                    <div className="flex-1 relative">
                        {/* AureonVisualizer takes the background area already */}
                    </div>

                    <div className="px-4 py-2 border-t border-line2 flex justify-between items-center">
                        <span className="text-[9px] tracking-widest uppercase opacity-50">Pipelines em Execução</span>
                        <span className="text-[8px] opacity-30 hover:text-primary cursor-pointer">+ Novo Pipeline</span>
                    </div>
                    <div className="grid grid-cols-3 border-t border-line2 min-h-[80px]">
                        {[
                            { name: 'Ingest · Sales', status: 'RUNNING', p: 60, col: 'bg-primary' },
                            { name: 'DNA · Exec', status: 'PENDING', p: 10, col: 'bg-warn' },
                            { name: 'Clone · Alex', status: 'DONE', p: 100, col: 'bg-c' },
                        ].map((p, i) => (
                            <div key={i} className="p-4 border-r border-line2 last:border-0 flex flex-col gap-2">
                                <div className="flex justify-between items-center">
                                    <span className="text-[10px] uppercase font-bold">{p.name}</span>
                                    <span className={`text-[8px] ${p.status === 'RUNNING' ? 'text-[#00FF88]' : p.status === 'PENDING' ? 'text-warn' : 'text-primary'}`}>{p.status}</span>
                                </div>
                                <div className="h-0.5 bg-line2 w-full relative">
                                    <div className={`absolute inset-y-0 left-0 ${p.col} shadow-glow`} style={{ width: `${p.p}%` }} />
                                </div>
                                <span className="text-[8px] opacity-30">{p.p}% Completo</span>
                            </div>
                        ))}
                    </div>
                </main>

                {/* RIGHT PANEL */}
                <aside className="panel-side panel-right">
                    <div className="px-4 py-3 border-b border-line2 flex justify-between items-center">
                        <span className="text-[9px] tracking-widest uppercase opacity-50">Neural Log · Conversação</span>
                        <div className="pulse-active bg-[#FF2244] shadow-[#FF2244]"></div>
                    </div>
                    <div className="flex-1 overflow-y-auto p-4 space-y-4 flex flex-col-reverse">
                        {messages.map((msg, i) => (
                            <div key={i} className="border-l-2 border-transparent hover:border-primary/50 hover:bg-white/5 transition-all p-2 group">
                                <div className="flex gap-2 items-center mb-1">
                                    <span className="text-[8px] opacity-30 font-mono">{msg.time}</span>
                                    <span className={`text-[9px] uppercase font-bold ${msg.type === 'aureon' ? 'text-primary' : 'text-white/60'}`}>
                                        {msg.type === 'aureon' ? 'AUREON' : 'USER'}
                                    </span>
                                </div>
                                <p className="text-[10px] text-white/80 leading-relaxed font-mono">{msg.text}</p>
                            </div>
                        ))}
                    </div>

                    <div className="hud-section" data-label="KNOWLEDGE DNA">
                        <div className="space-y-3 mt-4">
                            {[
                                { l: 'L1 · Filosofias', p: 70, c: 'bg-c' },
                                { l: 'L2 · Mental Models', p: 85, c: 'bg-c2' },
                                { l: 'L3 · Heurísticas', p: 75, c: 'bg-[#8855ff]' }
                            ].map((k, i) => (
                                <div key={i} className="flex flex-col gap-1">
                                    <div className="flex justify-between text-[8px] uppercase tracking-widest opacity-60">
                                        <span>{k.l}</span><span>{k.p}%</span>
                                    </div>
                                    <div className="h-0.5 bg-line2 w-full"><div className={`h-full ${k.c}`} style={{ width: `${k.p}%` }} /></div>
                                </div>
                            ))}
                        </div>
                    </div>

                    <div className="p-4 grid grid-cols-2 gap-2 mt-auto">
                        {['/INGEST', '/CONCLAVE', '/PROCESS', '/STATUS'].map(cmd => (
                            <button key={cmd} className="ang-all border border-line bg-white/5 py-2 text-[8px] tracking-[0.2em] hover:bg-primary/20 transition-all">
                                {cmd}
                            </button>
                        ))}
                    </div>
                </aside>

                {/* BOTTOM BAR */}
                <footer className="bottombar h-9">
                    <div className="px-4 border-r border-line2 flex items-center gap-2 h-full text-[9px] tracking-widest opacity-60">
                        <div className="w-1.5 h-1.5 rounded-full bg-[#00FF88] shadow-[0_0_4px_#00FF88]" />
                        SISTEMA OK
                    </div>
                    <div className="px-4 border-r border-line2 flex items-center gap-2 h-full text-[9px] tracking-widest opacity-60">
                        3 PIPELINES ATIVOS
                    </div>
                    <div className="px-4 border-r border-line2 flex items-center h-full text-[9px] font-mono opacity-40">
                        SES-0471 · {timeStr}
                    </div>
                    <div className="flex-1 flex items-center px-4 gap-4 h-full group">
                        <span className="text-primary font-bold text-xs">$</span>
                        <input
                            className="bg-transparent border-none outline-none flex-1 text-[11px] text-primary placeholder:text-primary/20 font-mono"
                            placeholder="DIRETO PARA O NÚCLEO... (ENTER PARA EXECUTAR ou ESPAÇO PARA VOZ)"
                            value={commandInput}
                            onChange={(e) => setCommandInput(e.target.value)}
                            onKeyDown={handleCommandInput}
                        />
                        <div className="flex gap-4">
                            {!isListening && (
                                <button
                                    onClick={handleStartListening}
                                    className="p-1 px-4 border border-primary/20 hover:bg-primary/20 transition-all text-[9px] tracking-widest uppercase rounded-sm bg-primary/5 shadow-glow-sm"
                                >
                                    Voice Input
                                </button>
                            )}
                            {isListening && (
                                <button
                                    onClick={handleStopListening}
                                    className="p-1 px-4 border border-red/40 bg-red/10 text-red hover:bg-red/30 transition-all text-[9px] tracking-widest uppercase rounded-sm animate-pulse"
                                >
                                    Stop Listening
                                </button>
                            )}
                        </div>
                    </div>
                </footer>
            </div>
        </div>
    )
}
