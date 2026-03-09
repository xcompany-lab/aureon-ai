import React from 'react'

interface AureonCoreProps {
    isListening?: boolean
    isProcessing?: boolean
    size?: 'sm' | 'md' | 'lg'
}

export const AureonCore: React.FC<AureonCoreProps> = ({
    isListening = false,
    isProcessing = false,
    size = 'md'
}) => {
    const sizeClasses = {
        sm: 'w-24 h-24',
        md: 'w-48 h-48',
        lg: 'w-64 h-64'
    }

    return (
        <div className={`relative flex items-center justify-center ${sizeClasses[size]}`}>
            {/* Outer Glow Ring */}
            <div className={`absolute inset-0 rounded-full border-2 border-primary/20 animate-hud-pulse`} />

            {/* Rotating Orbitals */}
            <div className="absolute inset-2 rounded-full border border-dashed border-primary/30 animate-[spin_10s_linear_infinite]" />
            <div className="absolute inset-6 rounded-full border border-secondary/20 animate-[spin_15s_linear_infinite_reverse]" />

            {/* The Central Core */}
            <div className={`relative z-10 rounded-full flex items-center justify-center transition-all duration-500 bg-background border-2 border-primary/60 shadow-[0_0_30px_rgba(0,242,255,0.4)] ${isListening ? 'scale-110 border-accent shadow-[0_0_50px_rgba(0,255,150,0.6)]' : ''}`}>
                <div className={`rounded-full bg-gradient-to-tr from-primary/20 via-primary/40 to-secondary/20 flex items-center justify-center p-4 ${isProcessing ? 'animate-pulse' : ''}`}>
                    <div className={`rounded-full h-8 w-8 bg-primary shadow-[0_0_20px_rgba(0,242,255,0.8)] ${isProcessing ? 'scale-125' : ''}`} />
                </div>

                {/* Dynamic Voice Waves (only if listening) */}
                {isListening && (
                    <div className="absolute -inset-4 flex items-center justify-center gap-1">
                        {[1, 2, 3, 4, 5].map((i) => (
                            <div
                                key={i}
                                className="w-1 bg-accent rounded-full animate-bounce"
                                style={{ height: `${20 + Math.random() * 40}px`, animationDelay: `${i * 0.1}s` }}
                            />
                        ))}
                    </div>
                )}
            </div>

            {/* Hexagon Grid Background Overlay */}
            <div className="absolute inset-0 opacity-10 pointer-events-none">
                <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <pattern id="hexagons" width="28" height="49" patternUnits="userSpaceOnUse" patternTransform="scale(1) rotate(0)">
                            <path d="M28 9.98L14 2L0 9.98V25.96L14 33.94L28 25.96V9.98Z" stroke="currentColor" fill="none" />
                        </pattern>
                    </defs>
                    <rect width="100%" height="100%" fill="url(#hexagons)" className="text-primary" />
                </svg>
            </div>
        </div>
    )
}
