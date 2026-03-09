import { useEffect, useState } from 'react'
import { supabase, type ActivityFeed } from '../services/supabase'

export function useActivityFeed(limit = 20) {
    const [activities, setActivities] = useState<ActivityFeed[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        // 1. Fetch initial activities
        const fetchInitial = async () => {
            try {
                const { data, error } = await supabase
                    .from('activity_feed')
                    .select('*')
                    .order('created_at', { ascending: false })
                    .limit(limit)

                if (error) throw error
                setActivities(data || [])
            } catch (err) {
                console.error('Error fetching activities:', err)
            } finally {
                setLoading(false)
            }
        }

        fetchInitial()

        // 2. Subscribe to real-time events
        const channel = supabase
            .channel('activity_feed_changes')
            .on(
                'postgres_changes',
                {
                    event: 'INSERT',
                    schema: 'public',
                    table: 'activity_feed'
                },
                (payload) => {
                    const newActivity = payload.new as ActivityFeed
                    setActivities((prev) => [newActivity, ...prev].slice(0, limit))
                }
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [limit])

    return { activities, loading }
}
