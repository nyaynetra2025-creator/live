# Nyaynetra Supabase Setup Guide

Follow these steps to set up your Supabase backend for the Nyaynetra application:

## 1. Database Setup

1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and run the contents of `supabase_setup.sql`

This will create all necessary tables and set up Row Level Security policies.

## 2. Authentication Setup

### Email Authentication
Email signup and signin are enabled by default. No additional setup required.

### Email OTP (6-digit verification)
1. Go to Authentication > Settings
2. Ensure "Enable Email Signup" is checked
3. Ensure "Enable Email OTP" is checked
4. Set OTP length to 6 digits (this is the default)

### OAuth Providers
1. Go to Authentication > Providers
2. Enable Google provider:
   - Get Client ID and Secret from Google Cloud Console
   - Set redirect URL to: https://chvsvuuedztaarpbwmak.supabase.co/auth/v1/callback
3. Enable GitHub provider:
   - Get Client ID and Secret from GitHub Developer Settings
   - Set redirect URL to: https://chvsvuuedztaarpbwmak.supabase.co/auth/v1/callback

### Email Templates
1. Go to Authentication > Email Templates
2. Customize the "OTP" template with:
   ```
   Subject: Your Nyaynetra Verification Code
   
   Hello,
   
   Your 6-digit verification code for Nyaynetra is: {{ .Token }}
   
   This code will expire in 5 minutes.
   
   If you didn't request this code, you can safely ignore this email.
   
   Best regards,
   The Nyaynetra Team
   ```

## 3. Real-time Setup

Real-time functionality is already enabled for the required tables in the database setup script.
The following tables have real-time enabled:
- gov_updates (for trending topics)
- lawyers (for lawyer directory)
- messages (for chat functionality)

## 4. Edge Functions (Optional)

To set up the government data fetching function:

1. Install Supabase CLI if you haven't already:
   ```
   npm install -g supabase
   ```

2. Link your project:
   ```
   supabase link --project-ref chvsvuuedztaarpbwmak
   ```

3. Deploy the function:
   ```
   supabase functions deploy fetch-gov-data
   ```

4. Set up a cron job to run the function periodically:
   ```
   supabase functions schedule fetch-gov-data "*/30 * * * *"
   ```

## 5. Environment Variables

Make sure your Flutter app has the correct environment variables:
- SUPABASE_URL: https://chvsvuuedztaarpbwmak.supabase.co
- SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNodnN2dXVlZHp0YWFycGJ3bWFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM2MDg5OTIsImV4cCI6MjA3OTE4NDk5Mn0.r_rlDMNN7KP0mjcMfoo1w4K769fiNgaZbUWAhMSxtB0

## Testing

After setup, you can test the application by:
1. Running the Flutter app
2. Creating a new account (signup with email/password)
3. Verifying with the 6-digit OTP sent to your email
4. Browsing the lawyer directory
5. Using the chatbot functionality
6. Checking the trending topics section