import React, { useState, useRef } from 'react'
import { voiceService } from '../services/voice'

interface Message {
    id: number
    type: 'user' | 'aureon'
    text: string
    time: string
}

export const VoiceCommandOverlay: React.FC = () => {
    const [isActive, setIsActive] = useState(false)
    const [isListening, setIsListening] = useState(false)
    const [isProcessing, setIsProcessing] = useState(false)
    const [audioLevel, setAudioLevel] = useState(0)
    const [status, setStatus] = useState('STANDBY')
    const [messages, setMessages] = useState<Message[]>([
        { id: 0, type: 'aureon', text: 'Sistemas online. Aguardando comando, senhor.', time: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) }
    ])
    const msgEndRef = useRef<HTMLDivElement>(null)
    const msgId = useRef(1)

    const addMessage = (type: 'user' | 'aureon', text: string) => {
        const msg: Message = {
            id: msgId.current++,
            type,
            text,
            time: new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })
        }
        setMessages(prev => [...prev, msg])
        setTimeout(() => msgEndRef.current?.scrollIntoView({ behavior: 'smooth' }), 100)
    }

    const handleStartListening = async () => {
        setIsListening(true)
        setStatus('PROCESSANDO AUDIO...')
        await voiceService.startRecording((level) => setAudioLevel(level))
    }

    const handleStopListening = async () => {
        setIsListening(false)
        setAudioLevel(0)
        setStatus('ANALISANDO...')
        const blob = await voiceService.stopRecording()
        if (blob) processAudio(blob)
    }

    const processAudio = async (blob: Blob) => {
        setIsProcessing(true)
        try {
            const formData = new FormData()
            formData.append('audio', blob, 'audio.webm')
            const response = await fetch('http://localhost:5000/api/voice/process', { method: 'POST', body: formData })
            const data = await response.json()
            if (data.status === 'success') {
                addMessage('user', data.transcription)
                setStatus('RESPONDENDO...')
                setTimeout(() => {
                    addMessage('aureon', data.response)
                    setStatus('STANDBY')
                    setIsProcessing(false)
                }, 300)
            } else {
                throw new Error(data.error)
            }
        } catch (error) {
            addMessage('aureon', `Erro de sistema: ${error instanceof Error ? error.message : 'Falha na conexão'}`)
            setStatus('ERRO — AGUARDANDO RETRY')
            setIsProcessing(false)
        }
    }

    const now = new Date()
    const timeStr = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
    const dateStr = now.toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: 'long' })

    if (!isActive) {
        return (
            <button
                onClick={() => setIsActive(true)}
                className="fixed bottom-8 right-8 group"
                title="Abrir Aureon Command Center"
            >
                <div className="relative flex items-center justify-center w-16 h-16">
                    <div className="absolute inset-0 rounded-full border-2 border-primary/40 animate-ping opacity-30" />
                    <div className="absolute inset-0 rounded-full border border-primary/30 animate-[spin_6s_linear_infinite]" />
                    <div className="relative w-14 h-14 rounded-full bg-background border border-primary/60 flex items-center justify-center shadow-[0_0_20px_rgba(0,242,255,0.5)] group-hover:shadow-[0_0_35px_rgba(0,242,255,0.8)] transition-all">
                        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
                            <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" />
                            <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
                            <line x1="12" x2="12" y1="19" y2="22" />
                        </svg>
                    </div>
                </div>
                <span className="absolute -top-7 left-1/2 -translate-x-1/2 text-[9px] font-mono text-primary/60 uppercase tracking-widest whitespace-nowrap">
                    Command Center
                </span>
            </button>
        )
    }

    return (
        <div className="fixed inset-0 z-50 bg-[#020810] text-primary font-mono overflow-hidden">
            {/* Scan Line Effect */}
            <div className="pointer-events-none absolute inset-0 z-10 bg-[repeating-linear-gradient(0deg,transparent,transparent_2px,rgba(0,242,255,0.015)_2px,rgba(0,242,255,0.015)_4px)]" />

            {/* Corner Decorations */}
            {[['top-0 left-0 border-t border-l', 'rounded-br-none'], ['top-0 right-0 border-t border-r', 'rounded-bl-none'], ['bottom-0 left-0 border-b border-l', 'rounded-tr-none'], ['bottom-0 right-0 border-b border-r', 'rounded-tl-none']].map(([pos], i) => (
                <div key={i} className={`absolute ${pos} w-16 h-16 border-primary/40`} />
            ))}

            {/* Grid Lines */}
            <div className="absolute inset-0 pointer-events-none opacity-[0.04]"
                style={{ backgroundImage: 'linear-gradient(rgba(0,242,255,1) 1px, transparent 1px), linear-gradient(90deg, rgba(0,242,255,1) 1px, transparent 1px)', backgroundSize: '60px 60px' }} />

            {/* MAIN LAYOUT: 3 columns */}
            <div className="relative z-20 h-full flex flex-col">

                {/* TOP BAR */}
                <div className="flex items-center justify-between px-8 py-3 border-b border-primary/20">
                    <div className="flex items-center gap-8">
                        <div>
                            <p className="text-[9px] text-primary/40 uppercase tracking-[0.3em]">Sistema</p>
                            <p className="text-lg font-bold tracking-[0.2em] text-primary" style={{ textShadow: '0 0 20px rgba(0,242,255,0.8)' }}>AUREON <span className="text-primary/40 font-light">OS</span></p>
                        </div>
                        <div className="h-8 w-px bg-primary/20" />
                        <div>
                            <p className="text-[9px] text-primary/40 uppercase">Data</p>
                            <p className="text-xs text-primary/70 capitalize">{dateStr}</p>
                        </div>
                    </div>
                    <div className="text-center">
                        <p className="text-[9px] text-primary/40 uppercase tracking-[0.3em]">Status Neural</p>
                        <div className="flex items-center gap-2">
                            <div className={`w-2 h-2 rounded-full ${isListening ? 'bg-green-400 animate-pulse' : isProcessing ? 'bg-yellow-400 animate-ping' : 'bg-primary'}`} />
                            <p className="text-xs tracking-widest text-primary">{status}</p>
                        </div>
                    </div>
                    <div className="text-right">
                        <p className="text-[9px] text-primary/40 uppercase">Hora Local</p>
                        <p className="text-xl font-bold tracking-widest text-primary" style={{ textShadow: '0 0 15px rgba(0,242,255,0.7)', fontVariantNumeric: 'tabular-nums' }}>{timeStr}</p>
                    </div>
                </div>

                <div className="flex-1 flex overflow-hidden">
                    {/* LEFT PANEL — System Info */}
                    <div className="w-64 border-r border-primary/15 flex flex-col p-6 gap-6">
                        <p className="text-[9px] text-primary/40 uppercase tracking-[0.3em] border-b border-primary/10 pb-2">Diagnóstico</p>
                        {[
                            { label: 'Neural Link', value: 'ATIVO', color: 'text-green-400' },
                            { label: 'Voice Engine', value: 'ONLINE', color: 'text-primary' },
                            { label: 'OpenAI Whisper', value: 'SYNC', color: 'text-primary' },
                            { label: 'Supabase DB', value: 'CONECTADO', color: 'text-green-400' },
                        ].map(({ label, value, color }) => (
                            <div key={label} className="flex justify-between items-center border-b border-primary/10 pb-3">
                                <span className="text-[10px] text-primary/50 uppercase tracking-wider">{label}</span>
                                <span className={`text-[10px] font-bold ${color}`}>{value}</span>
                            </div>
                        ))}

                        {/* Audio Level Visualizer */}
                        <div>
                            <p className="text-[9px] text-primary/40 uppercase tracking-[0.3em] mb-3">Nível de Áudio</p>
                            <div className="flex items-end gap-1 h-12">
                                {[...Array(18)].map((_, i) => (
                                    <div key={i} className="flex-1 bg-primary/10 rounded-sm overflow-hidden flex flex-col justify-end">
                                        <div
                                            className="bg-primary transition-all duration-75"
                                            style={{
                                                height: isListening ? `${Math.max(10, (audioLevel + Math.random() * 30))}%` : '5%',
                                                boxShadow: isListening ? '0 0 8px rgba(0,242,255,0.8)' : 'none'
                                            }}
                                        />
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Close button */}
                        <div className="mt-auto">
                            <button
                                onClick={() => setIsActive(false)}
                                className="w-full py-2 border border-destructive/40 text-destructive/70 text-[10px] uppercase tracking-widest hover:bg-destructive/10 transition-all rounded"
                            >
                                ⬡ Encerrar Sessão
                            </button>
                        </div>
                    </div>

                    {/* CENTER — Core + Controls */}
                    <div className="flex-1 flex flex-col items-center justify-center gap-8 relative">
                        {/* Central HUD Ring */}
                        <div className="relative flex items-center justify-center">
                            {/* Outer rings */}
                            <div className="absolute w-72 h-72 rounded-full border border-primary/10 animate-[spin_30s_linear_infinite]">
                                {[0, 60, 120, 180, 240, 300].map(deg => (
                                    <div key={deg} className="absolute w-2 h-2 -translate-x-1 -translate-y-1 rounded-sm bg-primary/30"
                                        style={{ left: `${50 + 48 * Math.cos(deg * Math.PI / 180)}%`, top: `${50 + 48 * Math.sin(deg * Math.PI / 180)}%` }} />
                                ))}
                            </div>
                            <div className="absolute w-60 h-60 rounded-full border border-dashed border-primary/20 animate-[spin_20s_linear_infinite_reverse]" />
                            <div className="absolute w-48 h-48 rounded-full border border-primary/30 animate-[spin_15s_linear_infinite]" />

                            {/* Inner Glow */}
                            <div className={`relative w-36 h-36 rounded-full flex items-center justify-center
                border-2 transition-all duration-700
                ${isListening ? 'border-green-400 shadow-[0_0_60px_rgba(0,255,150,0.6),inset_0_0_40px_rgba(0,255,150,0.15)]' :
                                    isProcessing ? 'border-yellow-400 shadow-[0_0_60px_rgba(255,200,0,0.5),inset_0_0_40px_rgba(255,200,0,0.1)] animate-pulse' :
                                        'border-primary/60 shadow-[0_0_40px_rgba(0,242,255,0.4),inset_0_0_30px_rgba(0,242,255,0.08)]'}`}>

                                <div className={`w-20 h-20 rounded-full flex items-center justify-center
                  ${isListening ? 'bg-green-400/10' : 'bg-primary/5'}`}>
                                    <div className={`w-10 h-10 rounded-full 
                    ${isListening ? 'bg-green-400 shadow-[0_0_30px_rgba(0,255,150,1)]' :
                                            isProcessing ? 'bg-yellow-400 shadow-[0_0_30px_rgba(255,200,0,1)] animate-spin' :
                                                'bg-primary shadow-[0_0_20px_rgba(0,242,255,0.8)]'}`} />
                                </div>

                                {/* Tick marks on inner ring */}
                                <svg className="absolute inset-0 w-full h-full" viewBox="0 0 144 144">
                                    {[...Array(24)].map((_, i) => {
                                        const angle = (i / 24) * 2 * Math.PI - Math.PI / 2
                                        const r1 = 68, r2 = i % 6 === 0 ? 60 : 63
                                        return <line key={i} x1={72 + r1 * Math.cos(angle)} y1={72 + r1 * Math.sin(angle)} x2={72 + r2 * Math.cos(angle)} y2={72 + r2 * Math.sin(angle)} stroke="rgba(0,242,255,0.4)" strokeWidth="1" />
                                    })}
                                </svg>
                            </div>
                        </div>

                        {/* Voice Controls */}
                        <div className="flex gap-4">
                            {!isListening && !isProcessing && (
                                <button onClick={handleStartListening}
                                    className="px-10 py-3 border border-primary/60 text-primary text-[11px] uppercase tracking-[0.2em] hover:bg-primary/10 hover:shadow-[0_0_20px_rgba(0,242,255,0.3)] transition-all rounded">
                                    ◉ Ativar Comando de Voz
                                </button>
                            )}
                            {isListening && (
                                <button onClick={handleStopListening}
                                    className="px-10 py-3 border border-red-400/60 text-red-400 text-[11px] uppercase tracking-[0.2em] hover:bg-red-400/10 transition-all rounded animate-pulse">
                                    ◼ Encerrar Captura
                                </button>
                            )}
                            {isProcessing && (
                                <div className="px-10 py-3 border border-yellow-400/40 text-yellow-400 text-[11px] uppercase tracking-[0.2em]">
                                    ◈ Processando...
                                </div>
                            )}
                        </div>
                    </div>

                    {/* RIGHT PANEL — Chat Log (PERSISTENT) */}
                    <div className="w-96 border-l border-primary/15 flex flex-col">
                        <div className="flex items-center justify-between px-5 py-3 border-b border-primary/10">
                            <p className="text-[9px] text-primary/40 uppercase tracking-[0.3em]">Neural Log — Conversação</p>
                            <div className="flex items-center gap-2">
                                <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                                <span className="text-[9px] text-primary/40">LIVE</span>
                            </div>
                        </div>

                        <div className="flex-1 overflow-y-auto p-4 space-y-4 scrollbar-thin scrollbar-thumb-primary/20">
                            {messages.map((msg) => (
                                <div key={msg.id} className={`flex flex-col gap-1 ${msg.type === 'user' ? 'items-end' : 'items-start'}`}>
                                    <div className="flex items-center gap-2">
                                        <span className="text-[8px] text-primary/30 uppercase">{msg.type === 'aureon' ? '◈ AUREON' : '◉ OPERADOR'}</span>
                                        <span className="text-[8px] text-primary/20">{msg.time}</span>
                                    </div>
                                    <div className={`max-w-[90%] px-4 py-3 rounded text-xs leading-relaxed
                    ${msg.type === 'aureon'
                                            ? 'bg-primary/5 border border-primary/20 text-primary/90 text-left'
                                            : 'bg-secondary/5 border border-secondary/20 text-secondary/80 text-right'
                                        }`}
                                        style={{ textShadow: msg.type === 'aureon' ? '0 0 10px rgba(0,242,255,0.2)' : 'none' }}>
                                        {msg.text}
                                    </div>
                                </div>
                            ))}
                            <div ref={msgEndRef} />
                        </div>

                        {/* Clear log */}
                        <div className="p-3 border-t border-primary/10">
                            <button onClick={() => setMessages([])} className="w-full text-[9px] uppercase tracking-widest text-primary/30 hover:text-primary/60 transition-colors py-1">
                                ✕ Limpar Log
                            </button>
                        </div>
                    </div>
                </div>

                {/* BOTTOM BAR */}
                <div className="flex items-center justify-between px-8 py-2 border-t border-primary/20">
                    <p className="text-[8px] text-primary/25 font-mono">AUREON CORE ENGINE :: Terminal_ID: MB-03-26 :: Build 2026.03.08</p>
                    <p className="text-[8px] text-primary/25 font-mono">ENCRYPTION: AES-256 :: SESSION: SECURE :: NEURAL_LINK: ACTIVE</p>
                </div>
            </div>
        </div>
    )
}
