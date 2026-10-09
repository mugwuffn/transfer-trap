# Transfer Trap — Browser Game MVP

An original, mobile-friendly footballer deduction game. Static HTML/CSS/JavaScript; no build step, external libraries, analytics, images, or server required.

## Play locally

1. Unzip the project if needed.
2. Open `index.html` in a modern browser.
3. Select **Daily Trap** or **Training Ground**.

For local development, a simple static server also works, e.g. `python -m http.server 8000`, then visit `http://localhost:8000`.

## Game rules

- Correct guess with 1 clue: 100 points.
- Correct guess with 2 clues: 75 points.
- Correct guess with 3 clues: 50 points.
- Correct guess with 4 clues: 25 points.
- Wrong guesses deduct 10 points (score cannot go below zero).
- One Trap Card per game removes one incorrect answer.
- Daily Trap chooses the same five-question set for a given UTC date.
- Training Ground plays the complete question bank in shuffled order.
- Scores and practice count are stored in local browser storage only.

## Current product specification

See [`SPEC.md`](SPEC.md) for the planned independent filters: geographical scope (single league / country / continent / worldwide), difficulty, and player era. The intended defaults are **worldwide + hard + all eras**. The current 17-question prototype does not yet provide comprehensive worldwide/all-era coverage; the spec defines the metadata, strict filtering behaviour, scoring, and implementation phases needed to support it honestly.

## Deploy free with GitHub Pages

1. Create a new GitHub repository (e.g. `transfer-trap`).
2. Upload `index.html` and `README.md` to the repository root.
3. In repository **Settings → Pages**, choose **Deploy from a branch**, select the default branch and `/ (root)`, then save.
4. Wait for the Pages deployment and open the URL shown in Settings → Pages.

Official guide: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site

GitHub Pages sites are public. This MVP has no server-side secrets and does not collect player data centrally. It does store local high scores on each player's own device.

## Before public launch

- Confirm name/domain/trademark availability for “Transfer Trap”. This is a working title, not a clearance result.
- Independently fact-check every question and source its football-history claims. The included bank is a prototype and should receive a full editorial review before wider publication.
- Add a privacy notice if you introduce analytics, accounts, advertising, or third-party services.
- Test on current iOS Safari, Android Chrome, desktop Chrome/Firefox/Safari and with keyboard navigation.
- Consider a persistent backend only if you need cross-device accounts, shared leaderboards or live multiplayer. Do not add this until the core loop has traction.

## Product strategy / next experiments

1. Test whether people finish a five-player Daily Trap and invite another player.
2. Measure repeat play manually with a small beta group (this prototype intentionally has no analytics).
3. Ask 10–20 football fans to try it without explaining the game first; watch where they get stuck.
4. Add more question packs only after the format is fun and reliable.
5. Explore a premium “private league” or themed packs only after there is evidence of repeat use.

## IP / content note

This is an independently styled fan-made trivia prototype. It does not use club badges, official photographs, or Tifo branding/assets. Player names and factual career events are used as quiz answers/clues. That does not guarantee legal clearance: check the product name, review the question text, and verify the rights/terms of any future data source or visual asset before commercial launch.

## Progression features in MVP v0.3

The browser-only build now includes:

- Daily streak tracking (based on completed Daily Trap challenges on consecutive UTC dates).
- A local Football Passport that collects each correctly identified player.
- Nine achievements, including first discovery, first-clue solves, daily participation and training milestones.
- Profile statistics for best daily score, current streak, completed games and unique players discovered.
- Achievement unlock notifications and shareable round results.

These records are stored in the current browser using `localStorage`. They do not sync between devices and can be cleared by the user. The passport currently tracks player names from this prototype question bank; it is not yet a verified global player database.

## Current limitations — do not mistake roadmap for live features

- The prototype has 17 hand-authored questions, not comprehensive worldwide league or all-era coverage.
- Geography and era filters are not yet active because the question bank lacks the verified player/league/season metadata required to filter honestly. The specification defines how to add them without silently changing the selected filters.
- Global leaderboards, accounts, private mini-leagues and live head-to-head matches are not live. They require the Supabase backend described in `leaderboards/README.md`; the schema is only a starting point and requires security review and server-side score validation.
- Sharing sends a score summary; it does not create a synchronised multiplayer match.

## Suggested test pass

1. Finish a Daily Trap and confirm games, unique players, best score, streak and achievements update.
2. Finish a Training Ground game and confirm it increments completed games but does not change the daily streak.
3. Replay the daily challenge on the same UTC date; the streak should not increase twice.
4. Complete a Daily Trap on the next UTC date; the streak should increase by one.
5. Reload the page and confirm local progress persists.
6. Test in a private browser window and confirm it starts with a separate local profile.
