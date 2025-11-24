-- Create profiles table
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  email text unique,
  role text check (role in ('client', 'advocate')),
  created_at timestamp with time zone default now()
);

-- Create lawyers table
create table lawyers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  specialization text,
  experience_years integer,
  rating numeric,
  is_verified boolean default false,
  avatar_url text,
  created_at timestamp with time zone default now()
);

-- Create cases table
create table cases (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references profiles(id) on delete cascade,
  lawyer_id uuid references lawyers(id) on delete cascade,
  status text,
  summary text,
  updated_at timestamp with time zone default now()
);

-- Create messages table
create table messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  sender text check (sender in ('user', 'bot')),
  content text,
  created_at timestamp with time zone default now()
);

-- Create gov_updates table
create table gov_updates (
  id bigserial primary key,
  title text,
  body text,
  source_url text,
  published_at timestamp with time zone,
  updated_at timestamp with time zone default now()
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;
alter table lawyers enable row level security;
alter table cases enable row level security;
alter table messages enable row level security;
alter table gov_updates enable row level security;

-- Profiles policies
create policy "Profiles are viewable by their user" on profiles
  for select using (auth.uid() = id);

create policy "Users can insert their own profile" on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id);

-- Lawyers policies
create policy "Lawyers are viewable by everyone" on lawyers
  for select using (true);

create policy "Lawyers can be inserted by their user" on lawyers
  for insert with check (auth.uid() = user_id);

-- Cases policies
create policy "Cases are viewable by clients or lawyers" on cases
  for select using (auth.uid() = client_id or auth.uid() = lawyer_id);

create policy "Cases can be inserted by clients" on cases
  for insert with check (auth.uid() = client_id);

-- Messages policies
create policy "Messages are viewable by their user" on messages
  for select using (auth.uid() = user_id);

create policy "Messages can be inserted by their user" on messages
  for insert with check (auth.uid() = user_id);

-- Gov updates policies
create policy "Gov updates are viewable by everyone" on gov_updates
  for select using (true);

-- Insert sample data
insert into gov_updates (title, body, source_url, published_at) values
  ('New Data Privacy Laws', 'Understand the latest changes in data protection.', 'https://example.com/privacy-laws', now()),
  ('Tenant Rights Updates', 'Know your rights as a tenant in India.', 'https://example.com/tenant-rights', now()),
  ('Consumer Protection', 'Learn about the rules that protect you.', 'https://example.com/consumer-protection', now());

-- Enable real-time for relevant tables
alter publication supabase_realtime add table gov_updates;
alter publication supabase_realtime add table lawyers;
alter publication supabase_realtime add table messages;