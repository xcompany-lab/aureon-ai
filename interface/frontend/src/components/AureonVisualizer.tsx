import React, { useEffect, useRef } from 'react';

interface AureonVisualizerProps {
    isListening: boolean;
    isProcessing: boolean;
    audioLevel: number; // 0 to 100
}

export const AureonVisualizer: React.FC<AureonVisualizerProps> = ({ isListening, isProcessing, audioLevel }) => {
    const bgCanvasRef = useRef<HTMLCanvasElement>(null);
    const radarCanvasRef = useRef<HTMLCanvasElement>(null);
    const bgRequestRef = useRef<number>(0);
    const radarRequestRef = useRef<number>(0);

    const propsRef = useRef({ isListening, isProcessing, audioLevel });
    useEffect(() => {
        propsRef.current = { isListening, isProcessing, audioLevel };
    }, [isListening, isProcessing, audioLevel]);

    const radarStateRef = useRef({
        angle: 0,
        dataPoints: Array.from({ length: 24 }, () => ({
            angle: Math.random() * Math.PI * 2,
            dist: 0.2 + Math.random() * 0.45,
            size: 1.5 + Math.random() * 3,
            alpha: Math.random() * 0.8 + 0.2,
            decay: 0
        }))
    });


    // ── CIRCUIT / PARTICLE BG LOGIC ──
    useEffect(() => {
        const cvs = bgCanvasRef.current;
        if (!cvs) return;
        const ctx = cvs.getContext('2d');
        if (!ctx) return;

        let width = window.innerWidth;
        let height = window.innerHeight;
        cvs.width = width;
        cvs.height = height;

        const particles: any[] = [];
        for (let i = 0; i < 80; i++) {
            particles.push({
                x: Math.random() * width, y: Math.random() * height,
                vx: (Math.random() - 0.5) * 0.3, vy: (Math.random() - 0.5) * 0.3,
                size: Math.random() * 1.5 + 0.3, alpha: Math.random() * 0.5 + 0.1,
                pulse: Math.random() * Math.PI * 2
            });
        }

        const lines: any[] = [];
        for (let i = 0; i < 30; i++) {
            const x1 = Math.random() * width; const y1 = Math.random() * height;
            const dir = Math.random() > 0.5;
            const len = 40 + Math.random() * 120;
            lines.push({ x1, y1, x2: dir ? x1 + len : x1, y2: dir ? y1 : y1 + len, alpha: Math.random() * 0.12, speed: 0.005 + Math.random() * 0.01, t: Math.random() });
        }

        const handleResize = () => {
            width = window.innerWidth;
            height = window.innerHeight;
            cvs.width = width;
            cvs.height = height;
        };
        window.addEventListener('resize', handleResize);

        const drawBG = () => {
            ctx.clearRect(0, 0, width, height);

            lines.forEach(l => {
                l.t += l.speed; if (l.t > 1) l.t = 0;
                ctx.beginPath();
                ctx.moveTo(l.x1, l.y1); ctx.lineTo(l.x2, l.y2);
                ctx.strokeStyle = `rgba(0,180,255,${l.alpha})`;
                ctx.lineWidth = 0.5; ctx.stroke();
                const tx = l.x1 + (l.x2 - l.x1) * l.t;
                const ty = l.y1 + (l.y2 - l.y1) * l.t;
                ctx.beginPath(); ctx.arc(tx, ty, 1.5, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(0,255,255,0.6)`; ctx.fill();
            });

            const now = Date.now() / 1000;
            particles.forEach(p => {
                p.x += p.vx; p.y += p.vy;
                if (p.x < 0) p.x = width; if (p.x > width) p.x = 0;
                if (p.y < 0) p.y = height; if (p.y > height) p.y = 0;
                const a = p.alpha * (0.7 + 0.3 * Math.sin(now * 2 + p.pulse));
                ctx.beginPath(); ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
                ctx.fillStyle = `rgba(0,200,255,${a})`; ctx.fill();
            });

            for (let i = 0; i < particles.length; i++) {
                for (let j = i + 1; j < particles.length; j++) {
                    const dx = particles[i].x - particles[j].x;
                    const dy = particles[i].y - particles[j].y;
                    const dist = Math.sqrt(dx * dx + dy * dy);
                    if (dist < 100) {
                        ctx.beginPath();
                        ctx.moveTo(particles[i].x, particles[i].y);
                        ctx.lineTo(particles[j].x, particles[j].y);
                        ctx.strokeStyle = `rgba(0,200,255,${0.04 * (1 - dist / 100)})`;
                        ctx.lineWidth = 0.5; ctx.stroke();
                    }
                }
            }
            bgRequestRef.current = requestAnimationFrame(drawBG);
        };
        drawBG();

        return () => {
            window.removeEventListener('resize', handleResize);
            cancelAnimationFrame(bgRequestRef.current);
        };
    }, []);

    useEffect(() => {
        const rcvs = radarCanvasRef.current;
        if (!rcvs) return;
        const rctx = rcvs.getContext('2d');
        if (!rctx) return;

        const resizeRadar = () => {
            const rect = rcvs.parentElement?.getBoundingClientRect();
            if (rect) {
                rcvs.width = rect.width;
                rcvs.height = rect.height;
            }
        };
        resizeRadar();
        window.addEventListener('resize', resizeRadar);

        const drawRadar = () => {
            const { isListening: curListening, isProcessing: curProcessing, audioLevel: curLevel } = propsRef.current;
            const w = rcvs.width; const h = rcvs.height;
            const cx = w / 2; const cy = h / 2;
            const maxR = Math.min(w, h) * 0.38;

            rctx.clearRect(0, 0, w, h);

            const bg = rctx.createRadialGradient(cx, cy, 0, cx, cy, maxR * 1.5);
            bg.addColorStop(0, 'rgba(0,30,50,0.3)');
            bg.addColorStop(1, 'rgba(0,0,0,0)');
            rctx.fillStyle = bg; rctx.fillRect(0, 0, w, h);

            [1, 0.75, 0.5, 0.25].forEach(r => {
                rctx.beginPath();
                rctx.arc(cx, cy, maxR * r, 0, Math.PI * 2);
                rctx.strokeStyle = `rgba(0,255,255,${r === 1 ? 0.2 : 0.1})`;
                rctx.lineWidth = r === 1 ? 1 : 0.5; rctx.stroke();
            });

            // Sweepers & Leads
            radarStateRef.current.angle = (radarStateRef.current.angle + 0.008) % (Math.PI * 2);
            const radarAngle = radarStateRef.current.angle;

            for (let i = 0; i < 60; i++) {
                const a = radarAngle - i * 0.04;
                const alpha = (1 - i / 60) * 0.25;
                rctx.beginPath();
                rctx.moveTo(cx, cy);
                rctx.arc(cx, cy, maxR, a, a + 0.04);
                rctx.fillStyle = `rgba(0,255,200,${alpha})`;
                rctx.fill();
            }

            // Lead Edge
            rctx.beginPath();
            rctx.moveTo(cx, cy);
            rctx.lineTo(cx + Math.cos(radarAngle) * maxR, cy + Math.sin(radarAngle) * maxR);
            rctx.strokeStyle = 'rgba(0,255,180,0.7)';
            rctx.lineWidth = 1.5; rctx.stroke();

            // SQUAD NODES
            const squadColors = ['#00FF88', '#00FF88', '#00FF88', '#00FF88', '#00FF88', '#FFB300', '#00FF88'];
            radarStateRef.current.dataPoints.forEach((p, i) => {
                const px = cx + Math.cos(p.angle) * maxR * p.dist;
                const py = cy + Math.sin(p.angle) * maxR * p.dist;

                const diff = ((p.angle - radarAngle) % (Math.PI * 2) + Math.PI * 2) % (Math.PI * 2);
                if (diff < 0.15) { p.decay = 1.0; }
                if (p.decay > 0) { p.decay -= 0.008; }

                const col = i < 7 ? (curProcessing ? '#FFB300' : squadColors[i]) : '#00FFFF';
                if (p.decay > 0) {
                    rctx.beginPath();
                    rctx.arc(px, py, 6 + p.decay * 12, 0, Math.PI * 2);
                    rctx.strokeStyle = `rgba(0,255,136,${p.decay * 0.5})`;
                    rctx.lineWidth = 1; rctx.stroke();
                }

                rctx.beginPath();
                const radius = Math.max(0.1, p.size + (curListening ? Math.sin(Date.now() * 0.01) * 2 : 0));
                rctx.arc(px, py, radius, 0, Math.PI * 2);
                rctx.fillStyle = col;
                rctx.globalAlpha = 0.6 + p.decay * 0.4;
                rctx.fill();
                rctx.globalAlpha = 1;
            });

            // Center Orb
            const coreColor = curProcessing ? 'rgba(255, 179, 0, 0.9)' : (curListening ? 'rgba(0, 255, 136, 0.9)' : 'rgba(0, 255, 255, 0.9)');
            const cg = rctx.createRadialGradient(cx, cy, 0, cx, cy, 16);
            cg.addColorStop(0, coreColor);
            cg.addColorStop(0.4, 'rgba(0,200,255,0.4)');
            cg.addColorStop(1, 'rgba(0,0,0,0)');
            rctx.fillStyle = cg; rctx.beginPath(); rctx.arc(cx, cy, 16 + (curLevel / 5), 0, Math.PI * 2); rctx.fill();

            radarRequestRef.current = requestAnimationFrame(drawRadar);
        };
        drawRadar();

        return () => {
            window.removeEventListener('resize', resizeRadar);
            cancelAnimationFrame(radarRequestRef.current);
        };
    }, []);


    return (
        <>
            <canvas ref={bgCanvasRef} className="fixed inset-0 z-0 pointer-events-none" />
            <div className="hex-overlay" />
            <div className="viz-area absolute inset-0 flex items-center justify-center">
                <canvas ref={radarCanvasRef} id="radarcvs" className="w-full h-full" />
                <div className="corner-deco tl" style={{ top: '8px', left: '8px', opacity: 0.4 }} />
                <div className="corner-deco tr" style={{ top: '8px', right: '8px', opacity: 0.4 }} />
                <div className="corner-deco bl" style={{ bottom: '8px', left: '8px', opacity: 0.4 }} />
                <div className="corner-deco br" style={{ bottom: '8px', right: '8px', opacity: 0.4 }} />
                <div className="absolute bottom-[20px] left-1/2 -translate-x-1/2 text-center pointer-events-none">
                    <div className="font-orbitron text-[9px] tracking-[0.25em] text-primary/40">AUREON · NEURAL CORE</div>
                    <div className="text-[8px] text-primary/25 mt-0.5 uppercase">
                        {isProcessing ? 'ANALISANDO DNA SCHEMA...' : (isListening ? 'ESCUTANDO COMANDO...' : 'SQUADS SINCRONIZADOS')}
                    </div>
                </div>
            </div>
        </>
    );
};
