import { create } from 'zustand'
import type { User as SupabaseUser } from '@supabase/supabase-js'
import { supabase, type User } from '../services/supabase'

interface AuthState {
  user: SupabaseUser | null
  profile: User | null
  loading: boolean
  initialized: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, name: string) => Promise<void>
  signOut: () => Promise<void>
  initialize: () => Promise<void>
  fetchProfile: () => Promise<void>
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  profile: null,
  loading: false,
  initialized: false,

  initialize: async () => {
    try {
      // Get current session
      const { data: { session } } = await supabase.auth.getSession()

      if (session?.user) {
        set({ user: session.user })
        await get().fetchProfile()
      }

      // Listen for auth changes
      supabase.auth.onAuthStateChange(async (event, session) => {
        console.log('Auth state changed:', event)

        if (session?.user) {
          set({ user: session.user })
          await get().fetchProfile()
        } else {
          set({ user: null, profile: null })
        }
      })

      set({ initialized: true })
    } catch (error) {
      console.error('Error initializing auth:', error)
      set({ initialized: true })
    }
  },

  fetchProfile: async () => {
    try {
      const { user } = get()
      if (!user) return

      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .single()

      if (error) {
        // If profile doesn't exist, create one
        if (error.code === 'PGRST116') {
          const { data: newProfile, error: insertError } = await supabase
            .from('users')
            .insert({
              id: user.id,
              email: user.email!,
              name: user.user_metadata?.name || null,
              role: 'operator',
              timezone: 'America/Sao_Paulo',
              preferences: {}
            })
            .select()
            .single()

          if (insertError) throw insertError
          set({ profile: newProfile })
        } else {
          throw error
        }
      } else {
        set({ profile: data })
      }
    } catch (error) {
      console.error('Error fetching profile:', error)
    }
  },

  signIn: async (email: string, password: string) => {
    try {
      set({ loading: true })

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      })

      if (error) throw error

      set({ user: data.user })
      await get().fetchProfile()
    } catch (error: any) {
      console.error('Sign in error:', error)
      throw new Error(error.message || 'Failed to sign in')
    } finally {
      set({ loading: false })
    }
  },

  signUp: async (email: string, password: string, name: string) => {
    try {
      set({ loading: true })

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            name
          }
        }
      })

      if (error) throw error

      if (data.user) {
        set({ user: data.user })
        await get().fetchProfile()
      }
    } catch (error: any) {
      console.error('Sign up error:', error)
      throw new Error(error.message || 'Failed to sign up')
    } finally {
      set({ loading: false })
    }
  },

  signOut: async () => {
    try {
      set({ loading: true })

      const { error } = await supabase.auth.signOut()

      if (error) throw error

      set({ user: null, profile: null })
    } catch (error: any) {
      console.error('Sign out error:', error)
      throw new Error(error.message || 'Failed to sign out')
    } finally {
      set({ loading: false })
    }
  }
}))
