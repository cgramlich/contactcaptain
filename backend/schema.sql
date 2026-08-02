-- ===========================================================================
-- Orbit (Personal CRM) — Supabase schema
-- ===========================================================================
-- Whole-collection JSONB model: one row per user per collection. The client
-- reads/writes each collection as a whole (it owns ordering). The backend uses
-- the service_role key and is the ONLY thing that touches these tables —
-- clients always go through the API, never the DB directly.
--
-- Run this in the Supabase SQL editor for the Orbit project.
-- (Lesson from MenuCaptain: new tables return 500 / 42501 until the
--  service_role grants below are applied; the ALTER DEFAULT PRIVILEGES lines
--  auto-grant any future tables too.)
-- ===========================================================================

-- ---- collections (arrays) -------------------------------------------------
create table if not exists public.contacts (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.organizations (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.interactions (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.tasks (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.deals (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- ---- meta (singleton object: preferences, default cadence, etc.) ----------
create table if not exists public.meta (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- ---- push device tokens (dormant until Firebase is wired) -----------------
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);
create index if not exists device_tokens_user_idx on public.device_tokens(user_id);

-- ---- AI usage metering ----------------------------------------------------
create table if not exists public.ai_usage (
  id            bigint generated always as identity primary key,
  user_id       uuid not null,
  model         text,
  input_tokens  integer not null default 0,
  output_tokens integer not null default 0,
  cost_usd      double precision not null default 0,
  created_at    timestamptz not null default now()
);
create index if not exists ai_usage_user_idx    on public.ai_usage(user_id);
create index if not exists ai_usage_created_idx on public.ai_usage(created_at);

-- ---- digital business card (public shareable card + connect leads) --------
-- One card per user, looked up publicly by its unguessable `slug`.
create table if not exists public.cards (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  slug       text unique not null,
  data       jsonb not null default '{}'::jsonb,   -- public shareable fields only
  published  boolean not null default false,
  updated_at timestamptz not null default now()
);
create index if not exists cards_slug_idx on public.cards(slug);

-- Incoming "share your info" submissions from a card's public page (a review inbox).
create table if not exists public.card_leads (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,  -- card owner
  slug       text,
  data       jsonb not null default '{}'::jsonb,   -- {name,email,phone,note}
  created_at timestamptz not null default now()
);
create index if not exists card_leads_user_idx on public.card_leads(user_id);

-- ===========================================================================
-- Row Level Security
-- ===========================================================================
-- The backend uses service_role, which BYPASSES RLS. Enable RLS with NO
-- policies so anon / authenticated clients (which only have the publishable
-- key) cannot read or write these tables directly — only the backend can.
-- ===========================================================================
alter table public.contacts      enable row level security;
alter table public.organizations enable row level security;
alter table public.interactions  enable row level security;
alter table public.tasks         enable row level security;
alter table public.deals         enable row level security;
alter table public.meta          enable row level security;
alter table public.device_tokens enable row level security;
alter table public.ai_usage      enable row level security;
alter table public.cards         enable row level security;
alter table public.card_leads    enable row level security;

-- ===========================================================================
-- service_role grants (fixes 42501 on new tables; auto-grants future tables)
-- ===========================================================================
grant usage on schema public to service_role;
grant all privileges on all tables    in schema public to service_role;
grant all privileges on all sequences in schema public to service_role;
alter default privileges in schema public grant all on tables    to service_role;
alter default privileges in schema public grant all on sequences to service_role;
