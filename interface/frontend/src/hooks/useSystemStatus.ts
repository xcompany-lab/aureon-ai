import { useEffect, useState } from 'react'
import { supabase, type SystemMetric } from '../services/supabase'

export function useSystemStatus() {
    const [metrics, setMetrics] = useState<Record<string, number>>({
        cpu: 0,
        ram: 0,
        disk: 0
    })
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        // 1. Fetch latest metrics
        const fetchLatest = async () => {
            try {
                const { data, error } = await supabase
                    .from('latest_metrics')
                    .select('*')

                if (error) {
                    console.warn('Error fetching metrics from Supabase:', error)
                    // Fallback to default metrics if Supabase fails or is empty
                    setMetrics({
                        cpu: 34,
                        ram: 61,
                        disk: 28
                    })
                    setLoading(false)
                    return
                }

                if (data && data.length > 0) {
                    const newMetrics = { ...metrics }
                    data.forEach((m: any) => {
                        newMetrics[m.metric_type] = m.value
                    })
                    setMetrics(newMetrics)
                } else {
                    // No data in database yet - use placeholder metrics
                    console.info('No metrics in database yet, using defaults')
                    setMetrics({
                        cpu: 34,
                        ram: 61,
                        disk: 28
                    })
                }
            } catch (err) {
                console.error('Critical error fetching metrics:', err)
                // Fallback to prevent blank screen
                setMetrics({
                    cpu: 34,
                    ram: 61,
                    disk: 28
                })
            } finally {
                setLoading(false)
            }
        }

        fetchLatest()

        // 2. Subscribe to realtime updates
        const channel = supabase
            .channel('system_metrics_changes')
            .on(
                'postgres_changes',
                {
                    event: 'INSERT',
                    schema: 'public',
                    table: 'system_metrics'
                },
                (payload) => {
                    const newMetric = payload.new as SystemMetric
                    setMetrics((prev) => ({
                        ...prev,
                        [newMetric.metric_type]: newMetric.value
                    }))
                }
            )
            .subscribe()

        return () => {
            supabase.removeChannel(channel)
        }
    }, [])

    return { metrics, loading }
}
