-- Enable real-time functionality for the required tables
-- This ensures that the Flutter app can listen for changes in real-time

-- Add tables to the supabase_realtime publication
-- This is already included in the main setup script, but here for reference

-- Enable real-time for gov_updates (for trending topics)
alter publication supabase_realtime add table gov_updates;

-- Enable real-time for lawyers (for lawyer directory)
alter publication supabase_realtime add table lawyers;

-- Enable real-time for messages (for chat functionality)
alter publication supabase_realtime add table messages;

-- If you need to remove a table from real-time publication, use:
-- alter publication supabase_realtime drop table table_name;

-- To check which tables are currently in the publication:
-- select tablename from pg_publication_tables where pubname = 'supabase_realtime';

-- Note: Real-time functionality requires the tables to have a primary key
-- All our tables have primary keys, so they're ready for real-time