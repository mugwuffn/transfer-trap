# Transfer Trap shared leaderboards

## Planned user experience
- Global: daily, weekly and all-time leaderboards.
- Mini leagues: create a private league, share invite code/link, join a league, and view daily/weekly/all-time rankings within it.
- Default game filters remain independent: worldwide scope, hard difficulty, all player eras.

## Why this is not active on GitHub Pages yet
The current game is static and saves scores only in each browser. Shared rankings need a backend. This folder provides a starting Supabase database schema, not a deployed or security-audited backend.

## Setup outline
1. Create a Supabase project.
2. Review and apply `schema.sql` in the SQL Editor. Do not apply blindly to a project containing other data.
3. Configure authentication (email magic link is a simple starting point) and choose whether display names are public.
4. Add the Supabase JS client and project URL + publishable/anon key to the site. Never put a service-role key in browser code.
5. Implement sign-in, profile creation, result submission, league creation/joining, and leaderboard queries.
6. Harden row-level security before public launch. In particular, validate scores server-side or via a trusted function; otherwise clients can submit fake high scores. Add rate limiting and anti-cheat rules.
7. Test two different accounts and devices before announcing shared leaderboards.

## Recommended ranking rules
- Daily: best valid score for a player on that challenge date and exact filter configuration; tie-break by fewer questions/guesses, then faster completion only if timing is reliably measured.
- Weekly: sum each player's best daily score for each distinct daily challenge in the week.
- All-time: cumulative best daily scores across completed challenge dates, with a clearly displayed season reset policy if seasons are introduced.
- Mini leagues: use the same scoring rules as global boards, but only include league members. Store an immutable challenge/configuration identifier with each result so unlike modes are never compared unfairly.

## Privacy and moderation
Use display names rather than exposing email addresses. Provide report/block and leave/delete league flows before a broad launch. Explain what scores are public, allow account deletion, and publish a privacy notice.
