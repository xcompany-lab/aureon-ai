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
        <div className="space-y-4 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
            {activities.length === 0 ? (
                <div className="text-center p-8 text-muted-foreground">
                    No activity recorded yet.
                </div>
            ) : (
                activities.map((activity) => (
                    <div
                        key={activity.id}
                        className="flex items-start gap-4 p-3 rounded-md bg-background/50 border border-border/50 hover:border-primary/30 transition-colors"
                    >
                        <div className={`mt-1 h-2 w-2 rounded-full shrink-0 ${getStatusColor(activity.event_type)}`} />
                        <div className="flex-1 min-w-0">
                            <div className="flex items-center justify-between gap-2">
                                <h4 className="text-sm font-medium truncate">{activity.title}</h4>
                                <span className="text-[10px] text-muted-foreground whitespace-nowrap">
                                    {new Date(activity.created_at).toLocaleTimeString()}
                                </span>
                            </div>
                            {activity.description && (
                                <p className="text-xs text-muted-foreground mt-1 line-clamp-2">
                                    {activity.description}
                                </p>
                            )}
                        </div>
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
