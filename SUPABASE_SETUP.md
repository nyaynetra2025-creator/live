# Nyaynetra - Legal Assistant App

This is a Flutter application for legal assistance with Supabase backend integration.

## Supabase Setup Instructions

### 1. Database Schema

The application uses the following tables:

1. **profiles** - User profiles with roles (client/advocate)
2. **lawyers** - Lawyer information and credentials
3. **cases** - Legal cases between clients and lawyers
4. **messages** - Chat messages between users and the AI assistant
5. **gov_updates** - Government legal updates

### 2. Authentication

The app supports:
- Email/password authentication
- Email OTP verification (6-digit codes)
- OAuth providers (Google, GitHub)

### 3. Real-time Features

- Real-time chat messages
- Live government updates
- Instant lawyer directory updates

### 4. Row Level Security (RLS) Policies

- Users can only view/edit their own profiles
- Lawyers are publicly viewable
- Cases are only visible to the client and assigned lawyer
- Messages are private to each user
- Government updates are publicly readable

### 5. Edge Functions

- `fetch-gov-data` - Function to periodically fetch and update government legal information

## Setup Steps

1. Run the SQL migration in `supabase/migrations/001_initial_schema.sql`
2. Deploy the Edge Function in `supabase/functions/fetch-gov-data/`
3. Configure OAuth providers in the Supabase Dashboard
4. Set up email templates for OTP verification
5. Schedule the Edge Function to run periodically for government updates

## Environment Variables

- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key
- `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key (for Edge Functions)