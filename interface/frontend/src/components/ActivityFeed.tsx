import { useActivityFeed } from '../hooks/useActivityFeed'

export function ActivityFeed() {
    const { activities, loading } = useActivityFeed()

    if (loading && activities.length === 0) {
        return (
            <div className="flex items-center justify-center p-8 text-muted-foreground">
                Loading activities...
            </div>
        )
    }

    return (
        <div className="flex-1 overflow-y-auto space-y-1 p-2 custom-scrollbar">
            {activities.length === 0 ? (
                <div className="text-center p-8 text-primary/20 text-[10px] uppercase tracking-widest">
                    No activity recorded yet.
                </div>
            ) : (
                activities.map((activity) => (
                    <div
                        key={activity.id}
                        className="border-l border-transparent hover:border-primary/50 hover:bg-white/5 transition-all p-2 group cursor-default"
                    >
                        <div className="flex items-center justify-between gap-2 mb-0.5">
                            <div className="flex items-center gap-2">
                                <div className={`h-1 w-1 rounded-full ${getStatusColor(activity.event_type)} shadow-sm`} />
                                <span className="text-[9px] font-bold uppercase tracking-wider text-primary/80">
                                    {activity.title}
                                </span>
                            </div>
                            <span className="text-[8px] text-primary/30 font-mono">
                                {new Date(activity.created_at).toLocaleTimeString()}
                            </span>
                        </div>
                        {activity.description && (
                            <p className="text-[9px] text-primary/50 leading-relaxed font-mono pl-3">
                                {activity.description}
                            </p>
                        )}
                    </div>
                ))
            )}
        </div>
    )
}

function getStatusColor(type: string) {
    switch (type) {
        case 'execution': return 'bg-blue-500'
        case 'whatsapp': return 'bg-green-500'
        case 'squad_activation': return 'bg-purple-500'
        case 'error': return 'bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.5)]'
        case 'deployment': return 'bg-orange-500'
        case 'system': return 'bg-cyan-500'
        default: return 'bg-muted-foreground'
    }
}
