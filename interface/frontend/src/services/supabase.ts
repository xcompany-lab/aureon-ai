import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please check your .env file.\n' +
    'Required: VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY'
  )
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})

// Types for database tables
export type User = {
  id: string
  email: string
  name: string | null
  avatar_url: string | null
  role: 'admin' | 'operator' | 'viewer'
  timezone: string
  preferences: Record<string, any>
  created_at: string
  updated_at: string
}

export type ChatSession = {
  id: string
  user_id: string
  title: string | null
  context: Record<string, any>
  created_at: string
  updated_at: string
}

export type ChatMessage = {
  id: string
  session_id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  metadata: Record<string, any>
  created_at: string
}

export type SkillExecution = {
  id: string
  user_id: string | null
  skill_name: string
  input_params: Record<string, any>
  output: Record<string, any>
  status: 'pending' | 'running' | 'success' | 'error'
  duration_ms: number | null
  error: string | null
  created_at: string
  completed_at: string | null
}

export type WhatsAppMessage = {
  id: string
  direction: 'incoming' | 'outgoing'
  contact_name: string | null
  contact_number: string
  message: string
  status: 'sent' | 'delivered' | 'read' | 'failed' | null
  squad_activated: string | null
  metadata: Record<string, any>
  created_at: string
}

export type SystemMetric = {
  id: string
  metric_type: 'cpu' | 'ram' | 'disk' | 'network'
  value: number
  metadata: Record<string, any>
  recorded_at: string
}

export type ActivityFeed = {
  id: string
  event_type: 'execution' | 'whatsapp' | 'squad_activation' | 'error' | 'deployment' | 'system'
  title: string
  description: string | null
  metadata: Record<string, any>
  created_at: string
}

export type Squad = {
  id: string
  name: string
  description: string | null
  specialists: string[]
  triggers: string[]
  status: 'active' | 'inactive'
  metadata: Record<string, any>
  created_at: string
  updated_at: string
}

// Database schema type
export type Database = {
  public: {
    Tables: {
      users: {
        Row: User
        Insert: Omit<User, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<User, 'id' | 'created_at' | 'updated_at'>>
      }
      chat_sessions: {
        Row: ChatSession
        Insert: Omit<ChatSession, 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Omit<ChatSession, 'id' | 'created_at' | 'updated_at'>>
      }
      chat_messages: {
        Row: ChatMessage
        Insert: Omit<ChatMessage, 'id' | 'created_at'>
        Update: Partial<Omit<ChatMessage, 'id' | 'created_at'>>
      }
      skill_executions: {
        Row: SkillExecution
        Insert: Omit<SkillExecution, 'id' | 'created_at'>
        Update: Partial<Omit<SkillExecution, 'id' | 'created_at'>>
      }
      whatsapp_messages: {
        Row: WhatsAppMessage
        Insert: Omit<WhatsAppMessage, 'id' | 'created_at'>
        Update: Partial<Omit<WhatsAppMessage, 'id' | 'created_at'>>
      }
      system_metrics: {
        Row: SystemMetric
        Insert: Omit<SystemMetric, 'id' | 'recorded_at'>
        Update: Partial<Omit<SystemMetric, 'id' | 'recorded_at'>>
      }
      activity_feed: {
        Row: ActivityFeed
        Insert: Omit<ActivityFeed, 'id' | 'created_at'>
        Update: Partial<Omit<ActivityFeed, 'id' | 'created_at'>>
      }
      squads: {
        Row: Squad
        Insert: Omit<Squad, 'created_at' | 'updated_at'>
        Update: Partial<Omit<Squad, 'created_at' | 'updated_at'>>
      }
    }
  }
}
