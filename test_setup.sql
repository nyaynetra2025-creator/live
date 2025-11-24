-- Test script to verify Supabase setup
-- Run this script to check if all tables and policies are correctly set up

-- Check if all tables exist
\dt

-- Check if RLS is enabled on all tables
select tablename, relrowsecurity from pg_class c join pg_namespace n on c.relnamespace = n.oid where n.nspname = 'public' and relrowsecurity = true;

-- Check if real-time is enabled for the required tables
select tablename from pg_publication_tables where pubname = 'supabase_realtime';

-- Check if sample data was inserted
select count(*) from gov_updates;

-- Test inserting a sample lawyer (this should work if you're logged in as a user)
-- insert into lawyers (user_id, specialization, experience_years, rating, is_verified, avatar_url) 
-- values (auth.uid(), 'Test Specialization', 5, 4.5, true, 'https://example.com/avatar.jpg');

-- Test inserting a sample message (this should work if you're logged in as a user)
-- insert into messages (user_id, sender, content) 
-- values (auth.uid(), 'user', 'Test message');

-- Test inserting a sample case (this should work if you're logged in as a user)
-- insert into cases (client_id, lawyer_id, status, summary) 
-- values (auth.uid(), '00000000-0000-0000-0000-000000000000', 'open', 'Test case');

-- Check if authentication providers are enabled
-- This can only be checked in the Supabase Dashboard under Authentication > Providers

-- Check if email templates are set up
-- This can only be checked in the Supabase Dashboard under Authentication > Email Templates