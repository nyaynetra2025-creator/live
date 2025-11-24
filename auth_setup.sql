-- Enable email signup/signin
-- This is enabled by default in Supabase

-- Configure email templates for OTP
-- You can customize these in the Supabase Dashboard under Authentication > Email Templates

-- Sample Email OTP template (to be used in Supabase Dashboard):
/*
Subject: Your Nyaynetra Verification Code
Body:
Hello,

Your 6-digit verification code for Nyaynetra is: {{ .Token }}

This code will expire in 5 minutes.

If you didn't request this code, you can safely ignore this email.

Best regards,
The Nyaynetra Team
*/

-- Enable OAuth providers
-- You'll need to configure these in the Supabase Dashboard:
-- 1. Go to Authentication > Providers
-- 2. Enable Google and GitHub providers
-- 3. Add your OAuth credentials for each provider

-- For Google OAuth, you'll need:
-- - Client ID
-- - Client Secret
-- - Redirect URLs: https://chvsvuuedztaarpbwmak.supabase.co/auth/v1/callback

-- For GitHub OAuth, you'll need:
-- - Client ID
-- - Client Secret
-- - Redirect URLs: https://chvsvuuedztaarpbwmak.supabase.co/auth/v1/callback

-- Enable Email OTP (passwordless sign-in)
-- This is configured in Authentication > Settings
-- Make sure "Enable Email Signup" and "Enable Email OTP" are both checked