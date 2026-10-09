-- Transfer Trap leaderboard schema for Supabase (Postgres)
-- Apply only after creating a Supabase project and reviewing RLS policies.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 24),
  created_at timestamptz not null default now()
);

create table if not exists public.game_results (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.profiles(id) on delete cascade,
  game_mode text not null check (game_mode in ('daily','practice')),
  challenge_date date,
  scope text not null default 'worldwide',
  difficulty text not null default 'hard',
  player_era text not null default 'all',
  score integer not null check (score >= 0),
  max_score integer not null check (max_score > 0 and score <= max_score),
  questions_answered integer not null default 0 check (questions_answered >= 0),
  duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
  created_at timestamptz not null default now(),
  constraint daily_date_required check (game_mode <> 'daily' or challenge_date is not null)
);

create index if not exists game_results_daily_rank_idx on public.game_results (challenge_date, score desc) where game_mode = 'daily';
create index if not exists game_results_player_idx on public.game_results (player_id, created_at desc);

create table if not exists public.mini_leagues (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 3 and 40),
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 8)),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.mini_league_members (
  league_id uuid not null references public.mini_leagues(id) on delete cascade,
  player_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (league_id, player_id)
);

create table if not exists public.mini_league_results (
  league_id uuid not null references public.mini_leagues(id) on delete cascade,
  result_id uuid not null references public.game_results(id) on delete cascade,
  player_id uuid not null references public.profiles(id) on delete cascade,
  primary key (league_id, result_id),
  foreign key (league_id, player_id) references public.mini_league_members(league_id, player_id) on delete cascade
);

alter table public.profiles enable row level security;
alter table public.game_results enable row level security;
alter table public.mini_leagues enable row level security;
alter table public.mini_league_members enable row level security;
alter table public.mini_league_results enable row level security;

-- Public profile names and leaderboard results are readable by signed-in users.
create policy "profiles readable to authenticated" on public.profiles for select to authenticated using (true);
create policy "players create own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "players update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "leaderboard results readable to authenticated" on public.game_results for select to authenticated using (true);
create policy "players insert own results" on public.game_results for insert to authenticated with check (auth.uid() = player_id);
create policy "mini leagues readable to authenticated" on public.mini_leagues for select to authenticated using (true);
create policy "members create leagues as owner" on public.mini_leagues for insert to authenticated with check (auth.uid() = owner_id);
create policy "memberships readable to authenticated" on public.mini_league_members for select to authenticated using (true);
create policy "players join as themselves" on public.mini_league_members for insert to authenticated with check (auth.uid() = player_id);
create policy "league results readable to authenticated" on public.mini_league_results for select to authenticated using (true);
create policy "members add own league results" on public.mini_league_results for insert to authenticated with check (auth.uid() = player_id and exists (select 1 from public.mini_league_members m where m.league_id = league_id and m.player_id = auth.uid()));
