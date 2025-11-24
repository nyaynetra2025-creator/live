-- Setup pg_cron to automatically run the news fetching function
-- This will trigger the Edge Function every hour

-- Enable pg_cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant permission to use pg_cron
GRANT USAGE ON SCHEMA cron TO postgres;

-- Schedule the Edge Function to run every hour
-- Replace 'YOUR_FUNCTION_URL' with your actual Edge Function URL
-- You'll get this URL after deploying the Edge Function

-- Example cron job that calls the Edge Function every hour
SELECT cron.schedule(
  'fetch-legal-news-hourly',  -- Job name
  '0 * * * *',                 -- Cron expression (every hour at minute 0)
  $$
  SELECT
    net.http_post(
      url := 'YOUR_FUNCTION_URL_HERE/fetch-legal-news',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
    ) AS request_id;
  $$
);

-- Alternative: Run every 2 hours
-- SELECT cron.schedule(
--   'fetch-legal-news-2-hourly',
--   '0 */2 * * *',
--   $$
--   SELECT
--     net.http_post(
--       url := 'YOUR_FUNCTION_URL_HERE/fetch-legal-news',
--       headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
--     ) AS request_id;
--   $$
-- );

-- Alternative: Run every 6 hours
-- SELECT cron.schedule(
--   'fetch-legal-news-6-hourly',
--   '0 */6 * * *',
--   $$
--   SELECT
--     net.http_post(
--       url := 'YOUR_FUNCTION_URL_HERE/fetch-legal-news',
--       headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
--     ) AS request_id;
--   $$
-- );

-- View all scheduled jobs
SELECT * FROM cron.job;

-- Unschedule a job (if needed)
-- SELECT cron.unschedule('fetch-legal-news-hourly');
