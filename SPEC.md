# Transfer Trap — Product Specification (v0.2)

## 1. Selected default configuration

The setup screen should open with these independent filters selected:

- **Geographical scope:** All leagues worldwide
- **Difficulty:** Hard
- **Player era:** All eras

These are three separate filters. Changing one must not silently change either of the others. The user can change each filter independently before starting a game.

> **Current prototype limitation:** the existing question bank contains only 17 questions, is weighted towards well-known players with European-club careers, and has not been fully tagged or editorially verified for worldwide/all-era coverage. The defaults above describe the intended configuration; they must not be presented as proof that the current content already offers comprehensive worldwide coverage. Until the data bank is expanded and tagged, the UI should label coverage as a limited beta and avoid silently substituting a different filter.

## 2. Player eligibility rules

Eligibility is determined by a player's documented club-league playing history, not their nationality, birthplace, or the country of their national team.

### Geographical scope

1. **Single league** — eligible if the player made at least one verified senior competitive appearance in the selected league. A transfer, registration, youth appearance, or bench appearance alone is not enough unless the game explicitly introduces a separate rule for it.
2. **All leagues in one country** — eligible if the player made at least one verified senior competitive league appearance in any included domestic league in that country. The supported divisions must be explicitly listed in the data catalogue; do not imply every amateur or semi-professional competition is covered unless it is.
3. **All leagues in one continent** — eligible if the player made at least one verified senior competitive league appearance in a country assigned to the selected continent in the game's maintained geography table. Continental boundaries and transcontinental countries must follow a documented, consistent mapping.
4. **All leagues worldwide** — eligible if the player made at least one verified senior competitive league appearance in any country represented in the catalogue. This means worldwide scope over the catalogue, not a claim that every league in the world is already covered.

A player may qualify for several leagues, countries, and continents over their career. Their nationality is metadata for clues, not the basis of scope eligibility. Cup-only appearances do not by themselves qualify a player for a league-based scope, though cup or international achievements can be used as clues for an otherwise eligible player.

### Difficulty

Difficulty measures how demanding the clue path is, not the player's fame or the amount of data available.

- **Easy:** highly recognisable player or connection; clues are direct and widely known.
- **Medium:** at least one less obvious career connection; some football knowledge required.
- **Hard:** clues require combining less obvious career facts, lower-profile clubs/competitions, historical context, or multi-step connections. Each clue must still be verifiable and the final answer must be unambiguous.

Each question has one editorially assigned difficulty value (`easy`, `medium`, or `hard`). Difficulty does not change the eligible player pool's geography or era. A hard worldwide/all-era game is the intersection of all three selected filters.

### Player era

- **Current players:** players active as professional players in a season defined by the game's current-season metadata.
- **Modern era:** players with a verified senior competitive appearance from 2000 onward. (Use the appearance date, not birth date.)
- **All eras:** no start-date restriction; include any era represented by verified source data.

Era is independent of geographical scope and difficulty. Retired players remain eligible for `all eras` and `modern era` if their career meets the relevant date rule.

## 3. Game setup and filter behaviour

The setup UI should have three independent controls:

- `scopeType`: `league | country | continent | world`
- `scopeId`: selected league, country, or continent identifier; ignored when `scopeType = world`
- `difficulty`: `easy | medium | hard`
- `era`: `current | modern | all`

The currently requested defaults are `scopeType = world`, `difficulty = hard`, and `era = all`.

The filter pipeline must apply all three constraints to the question bank:

1. Start with questions whose answer/player has sufficient verified league-history metadata for the selected geographical scope.
2. Keep only questions whose assigned difficulty equals the selected difficulty. If product testing later calls for a mixed difficulty mode, add it as a separate explicit option rather than weakening the meaning of `hard`.
3. Keep only questions whose player history intersects the selected era rule.
4. Validate that the filtered pool contains enough distinct, publishable questions for the selected mode.
5. If it does not, show a clear message such as “Not enough verified questions for this combination yet.” Offer the player an explicit option to broaden a filter. Never silently broaden scope, era, or difficulty.

For a five-question daily challenge, the eligible bank must contain at least five questions. For training mode, show all eligible questions in a shuffled order. Daily question selection must be deterministic for the same date and exact filter combination so users comparing a challenge receive the same set.

## 4. Scoring rules

Use the existing clue-based scoring model for the first implementation:

- Correct after clue 1: 100 points
- Correct after clue 2: 75 points
- Correct after clue 3: 50 points
- Correct after clue 4: 25 points
- Incorrect guess: −10 points, with round score floored at zero
- One Trap Card per game removes one incorrect option

Keep scoring identical across difficulty levels for the first beta to make it easier to understand and compare. Difficulty affects the question/clue selection, not the point values. Do not add a hidden multiplier. If later tests show hard rounds are too punishing or easy rounds are under-rewarded, test a clearly displayed multiplier as a separate versioned rules change.

Record each result with the selected filter configuration, question ID, answer, clue count, wrong-guess count, and earned points. Share text should include scope, difficulty, era, date/mode, score, and a link that reconstructs the same challenge configuration.

## 5. Question-bank data requirements

Each question should be structured data, not hard-coded only into rendering logic. Minimum proposed schema:

```json
{
  "id": "unique-stable-id",
  "answerPlayerId": "player-id",
  "answerDisplayName": "Player Name",
  "difficulty": "hard",
  "clues": [
    { "text": "Clue text", "sourceUrl": "https://...", "sourceNote": "What this source verifies" },
    { "text": "Clue text", "sourceUrl": "https://...", "sourceNote": "What this source verifies" },
    { "text": "Clue text", "sourceUrl": "https://...", "sourceNote": "What this source verifies" },
    { "text": "Clue text", "sourceUrl": "https://...", "sourceNote": "What this source verifies" }
  ],
  "explanation": "Short answer explanation with sources",
  "player": {
    "careerStartYear": 1998,
    "careerEndYear": 2018,
    "activeSeasons": ["1998-99", "1999-00"],
    "leagueAppearances": [
      { "leagueId": "eng-premier-league", "countryId": "england", "continentId": "europe", "firstSeason": "2003-04", "lastSeason": "2006-07", "sourceUrl": "https://..." }
    ]
  },
  "answerOptions": ["Player Name", "Distractor A", "Distractor B", "Distractor C"],
  "status": "draft | verified | published",
  "editorialReviewedAt": null
}
```

Data rules:

- Use stable IDs for players, leagues, countries, continents, seasons, and questions. Avoid matching only on display names.
- Keep a source URL and source note for every factual clue and every league eligibility claim. Prefer authoritative league/club records or reputable statistical sources.
- Do not publish a question until all clues, dates, spellings, competition names, and distractors have been checked by an editor.
- Store country-to-continent mapping in one maintained reference table; do not infer geography from player nationality.
- Track coverage explicitly by league, country, continent, era and difficulty. Label missing or partial coverage honestly.
- Review licensing, terms, and database rights for any third-party dataset. Public visibility does not automatically mean unrestricted reuse.
- Keep player photographs, club crests and third-party branding out of the MVP unless appropriately licensed.

## 6. Implementation plan for the existing static browser game

The current `index.html` app uses static HTML/CSS/JavaScript and a small in-file `QUESTIONS` array. It has no backend, user accounts, or shared server-side leaderboard. Implement the filters incrementally:

### Phase A — make questions filterable

1. Convert `QUESTIONS` to the schema above (or move it into `questions.json`).
2. Add the league/country/continent metadata required for eligibility and the `status` field.
3. Add the setup controls for geographical scope, difficulty, and era. Preselect world / hard / all.
4. Implement pure functions such as `isEligibleByScope(question, settings)`, `isEligibleByDifficulty(question, settings)`, and `isEligibleByEra(question, settings)`; combine them in `getEligibleQuestions(settings)`.
5. Only include `status: "published"` questions in public play. Draft/unverified questions may be used locally during development but not in release builds.
6. If there are fewer than five eligible questions for Daily Trap, disable that start action and explain the shortage. Do not fall back silently.

### Phase B — make challenges reproducible

1. Generate a canonical settings key from scope type, scope ID, difficulty, era, mode and UTC date (for daily mode).
2. Seed the daily shuffle from that key so the same configuration yields the same daily questions for all users.
3. Add a URL query parameter or compact, versioned challenge payload for the settings. Validate values on load; never execute arbitrary payload text.
4. Include the settings in result summaries and share messages.
5. Preserve the current local-only score storage, namespaced by settings key so records from different configurations are not mixed.

### Phase C — validation and release

1. Unit-test scope and era boundary cases, including a player with multiple league careers and transcontinental mapping.
2. Test the exact default combination: world + hard + all eras. Ensure the UI clearly says when the verified bank is too small.
3. Test deterministic daily sets across browsers for the same UTC date and configuration.
4. Test no-results/insufficient-bank states, mobile controls, keyboard access and share URLs.
5. Keep a question-source ledger and a release checklist. Add a backend only if live shared leagues or server-side leaderboards become essential.

## 7. Acceptance criteria

- The three settings are independent and visible before starting a game.
- The initial selected values are world / hard / all eras.
- Eligibility uses verified league appearance metadata, not nationality.
- The filter result is the strict intersection of scope, difficulty, and era.
- No insufficient-data condition silently changes the user's settings.
- Daily challenges are reproducible for a given UTC date and settings combination.
- Every published clue and eligibility fact has a recorded source and editorial status.
- Share text/link communicates the settings needed to reproduce the challenge.
- The interface clearly distinguishes intended global coverage from the leagues and eras currently present in the verified question bank.

## 8. Release note

The existing MVP's 17-question bank is not yet sufficient evidence of comprehensive worldwide, hard-difficulty, all-era coverage. The next development milestone is to add metadata and source-review each question, then expand the verified bank until the selected default can reliably support a five-question daily game without fallback behaviour.

## Shared leaderboards and mini leagues (new requirement)

### Leaderboards
- Global leaderboard views: daily, weekly, and all-time.
- Mini leagues: a player can create a league, invite others by code/link, join/leave a league, and view daily/weekly/all-time league rankings.
- Keep geography, difficulty and player era as independent filters. Only compare scores from the same challenge date and configuration.
- Display name only; never expose account email.
- Suggested tie-break: score, then fewer questions/guesses, then completion time if measured consistently.

### Architecture and integrity
- Static GitHub Pages cannot synchronise scores across users. A backend such as Supabase is required for authentication, profiles, results, leagues and memberships.
- A starting Postgres schema and setup notes live in `leaderboards/`.
- The schema is a starting point only, not a deployed backend or a complete security audit. Public launch requires server-side score validation / anti-cheat, rate limiting, hardened row-level security, privacy and account-deletion flows.
- The current localStorage scores must not be presented as global or shared rankings.

## 9. Progression MVP update (v0.3)

Implemented in the static browser prototype:
- Local profile statistics: best daily score, current daily streak, games completed and unique players discovered.
- Football Passport: adds correctly identified players to a local collection.
- Nine achievements: first player, 5/15 unique players, first-clue solve, daily completion, 3-day streak, 400+ score, five training games and ten first-clue solves.
- Unlock notifications and shareable score summary.

The local profile is a retention prototype, not a user account. It is tied to one browser/device, can be edited by the user through browser storage, and must not be used for public rankings.

### Next implementation gates
1. Expand and fact-check the question bank; add stable player IDs, source URLs, competition/league history, career dates, continent/country mappings, and editorial status.
2. Implement independent geography, difficulty and era filters only after the metadata exists; never imply that current questions provide full worldwide coverage.
3. Deploy Supabase authentication and backend with reviewed RLS, server-validated results, rate limits and anti-cheat before displaying global/mini-league rankings.
4. Implement asynchronous head-to-head by storing a shared challenge ID, settings key, question-set version, participant results and deterministic tie-break rules.
5. Add analytics only with a clear privacy notice and appropriate consent/legal review.
