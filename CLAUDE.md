# ContactCaptain — CLAUDE.md

Personal CRM in the **Forever Apps** portfolio (publisher: MilSpo Life LLC). Built on the
MenuCaptain stack. This file is auto-read at session start — keep it TRUE. If you change an
endpoint, env var, data model, or convention, update this file in the same session.

**Doc currency (Forever Apps starter spec section 5):** update docs in the SAME session as
the code change. This CLAUDE.md stays true to the code; the README/architecture body updates
when the architecture changes. Write a DATED entry in
`C:\Users\cjgra\Dropbox\My AI\CG Apps\Personal CRM\Personal CRM Log\` for EVERY work session.
No hardcoded versions in docs (point at `APP_VERSION`/`BUILD` + the live `/api/health`).
Rule: `CG Apps\Forever Apps\forever-apps-starter-spec.md` section 5.

## Code readability (Chris's directive 2026-08-10) - part of "done"
This code has to be readable by three people who were not in the room when it was written:
a human AUDITOR reconstructing what the system does, a REGULATOR asking "show me where that
rule is implemented", and a DEVELOPER JOINING COLD. If any of them has to ask "why is this
here?", the code has failed - whether or not it works. Treat this as part of the definition
of done, alongside "it compiles" and "it is deployed". Not polish to add later.

- **Comment the WHY and the RULE, never the WHAT.** The test: a good comment is still true
  after someone rewrites the implementation. If it only narrates the current lines, delete it.
- **Every business rule is stated in plain English beside the code enforcing it**, so a
  reviewer reads the rule and sees the code without inferring it from the logic. Say where the
  rule came from (statute, contract, policy, a decision Chris made) and date it. The invariants
  already written down here - "a failed push must never read as synced", reminder rows dismiss
  rather than delete - are the shape to copy in the code itself.
- **Non-obvious decisions record the road not taken** - what was rejected and why - so a later
  session doesn't "fix" a deliberate choice (e.g. supabase-js is deliberately NOT loaded).
- **Anything surprising gets a WARNING comment** where someone would trip over it: load-bearing
  quirks, footguns, things that fail silently. Route ordering on `/api/card/leads` vs
  `/api/card/{slug}` is that kind of trap.
- **Files open with an orientation block** (what this file is, what it owns, what it
  deliberately does not do), and long files are split into labelled banner sections (`AUTH`,
  `SYNC`, `CARD`, `AI RELAY`). Matters most in `index.html` and `backend/main.py`.
- **Names are the documentation**; explicit over clever, always. Don't golf.
- **Dead code is deleted, not commented out.** Git remembers.

Guard the opposite failure just as hard: NOT a comment per line, NOT the code restated in
English, NOT ceremonial docblocks, NOT commit-message content in comments (who changed what and
when is git's job). Noise buries signal and teaches the reader to skip comments, including the
one that mattered. Restructure unclear code rather than apologizing for it in a comment.

Full standard (the authority, read it):
`C:\Users\cjgra\Dropbox\My AI\CG Apps\Forever Apps\CODE-READABILITY-STANDARD.md`

## Pre-push audit gate (never bypass)
`git push` runs the shared checker `C:\Users\cjgra\portfolio-audit\portfolio_audit.py` through
`.git\hooks\pre-push`. Backend checks BLOCK the push; frontend checks are advisory (print-only)
for now. Run it ad hoc any time with `--all`.

It exists because these specific failures actually happened:
- a model that was routed but had no price entry took PriorityCaptain's AI relay fully offline;
- a duplicate dict key made FitnessCaptain meter Sonnet 5 at Haiku's rate, so the budget breaker
  sailed past roughly 3x the real spend;
- a typo in a Railway numeric variable crash-loops a backend at import.

`--no-verify` is NOT an acceptable workaround - it is already against Chris's standing rule. If
the gate is wrong, fix the checker; don't push around it.

## What it is
A personal relationship manager (stay close to the people in your orbit) with an optional,
toggleable **deals** layer. Single-file React-via-CDN + Babel PWA, FastAPI + Supabase
backend, deployed to the web; Capacitor native build is future.

## Live URLs
- **App (frontend):** https://contactcaptain.com — GitHub Pages from `cgramlich/contactcaptain`,
  repo **root**, custom domain via `CNAME` file. Porkbun DNS: 4 A records → GitHub Pages
  (185.199.108–111.153) + `www` CNAME → `cgramlich.github.io`.
- **API (backend):** https://inner-orbit-production.up.railway.app — Railway, **root dir =
  `backend/`**, auto-deploys on push to `main`. Health: `GET /api/health`.
- **Supabase project:** `efzuuqhraaxwsrkqfavn` (org Team CG, Pro). Asymmetric **ES256** JWT
  signing keys (backend verifies via JWKS — no JWT secret needed).
- **appId (native, not yet published):** `com.contactcaptain.app`.

## Versioning (do NOT hardcode a version in docs)
- Source of truth = `APP_VERSION` + `BUILD` in `index.html` and `VERSION` in `sw.js`
  (keep all three in **lockstep**), plus the deployed `/api/health` `version` field.
- **Bump `APP_VERSION` + `BUILD` (+ `sw.js`) on every user-facing change.** `BUILD` is the
  monotonic "YYYY-MM-DD.N" stamp the in-app updater actually compares (portfolio-standard
  updater, ref impl `tracker-app`); `APP_VERSION` is the friendly label shown in the banner,
  Settings, and footers. When citing "what's deployed," read the constants / hit `/health`;
  never write a number into prose.

## Backend (`backend/main.py`)
- Auth: `verify_jwt` picks alg from the token header — asymmetric (ES256/RS256) via JWKS, or
  legacy HS256 via `SUPABASE_JWT_SECRET`. A verified Bearer token is required on every call.
- Data: **generic whole-collection API** — `GET/PUT /api/collection/{name}` where name ∈
  `contacts, organizations, interactions, tasks, deals` (arrays) and `meta` (object). One row
  per user per collection (`user_id` PK, `data` jsonb). Client owns ordering.
- AI: `POST /api/ai/relay` (task→model routing, metering, monthly cost breaker). **Sonnet is
  the portfolio floor — no task routes to Haiku** (enforced by the pre-push gate). Free +
  capped. NO domain text injected server-side.
- Digital card: authed `PUT/GET /api/card` (owner's card, one per user → `cards` table:
  `user_id` PK, unguessable `slug`, `data` jsonb, `published`), `GET /api/card/leads` +
  `DELETE /api/card/leads/{id}` (review inbox → `card_leads` table). **PUBLIC (no auth):**
  `GET /api/card/{slug}` (published card only) and `POST /api/card/{slug}/connect`
  (rate-limited; a visitor's info → the owner's lead inbox). Routes ordered so
  `/api/card/leads` matches before `/api/card/{slug}`.
- Push: `/api/push/register|unregister` — **gated OFF** (frontend `PUSH_ENABLED=false`) until Firebase.
- `POST /api/account/delete` wipes all of a user's rows.
- Config is blank-safe: numeric/CORS env vars fall back via `or default` so empty Railway vars
  don't crash startup.

## Env vars (Railway = production; `backend/.env` = local, gitignored)
- `SUPABASE_URL` — the project URL.
- `SUPABASE_SERVICE_ROLE_KEY` — the **`sb_secret_…`** key (NOT the legacy `eyJ…` service_role;
  legacy keys are disabled on this project). Full DB access, bypasses RLS. SECRET.
- `ANTHROPIC_API_KEY` — enables `/api/ai/relay`; blank = AI disabled.
- `SUPABASE_JWT_SECRET` — leave blank (ES256/JWKS).
- Optional: `ALLOWED_ORIGINS` (defaults already include contactcaptain.com + the Pages URL —
  prefer leaving unset), `AI_MONTHLY_BUDGET_USD`, `AI_MAX_TOKENS_CEILING`.

## Frontend (`index.html`)
- `API_BASE_DEFAULT` → the Railway URL (overridable per-user in Settings).
- `SUPABASE_URL` + `SUPABASE_PUBLISHABLE_KEY` (the public `sb_publishable_…` key) for auth.
- Branding routed through `BRAND` + the CSS `:root` palette (drop-in swap principle).
- Offline mode: an "Explore offline (no account)" path appears only when `SUPABASE_URL` is unset.
- **Public card route:** a `?card=<slug>` URL renders `<PublicCard>` (login-free) instead of
  `<App>` — the branch is at the `ReactDOM.render` call. Owner editor is `<CardEditor>` (Settings
  → "My digital card"): edit/publish, Share tab (link + QR + Web Share), Connections inbox
  (accept → contact tagged "Met via card", or dismiss). QR uses a public image service in V1
  (card URL is public by design) — vendor/inline before the native build.
- **Supabase auth is called as raw REST** (`supabasePassword` → `/auth/v1/token`). The
  `supabase-js` CDN library is deliberately NOT loaded — nothing to pin or upgrade here.
- **Saves are optimistic with retry.** `saveCollection` writes local state + localStorage,
  then parks the collection's payload in `unsentRef` until its `PUT` is confirmed.
  `flushUnsent` retries on the next save, on `online`, and on visibilitychange-visible.
  Anything still unsent raises the amber top banner + the Settings "Cloud sync" row.
  Invariant: **a failed push must never read as "synced."**
- **Home reminder rows dismiss, they don't delete.** "Time to reach out" and "Upcoming
  birthdays" are VIEWS of a contact, so their swipe reveals a neutral **Dismiss**
  (`SwipeRow kind="dismiss"`). Carried on the contact record: `reachout_snooze_until`
  (ISO date; `contactDueInfo` takes the later of it and the cadence due date) and
  `birthday_ack` (the ISO date of the acknowledged occurrence, so the row returns next
  year). Deleting a contact lives on the contact detail screen only. Follow-up and
  interaction rows keep a real destructive Delete.

## Security / RLS
- Tables have **RLS on, no policies** → clients (publishable key) can't touch them directly.
  Only the backend (secret key) reads/writes. All access flows through the API.
- `backend/.env` is gitignored — never commit secrets. Publishable/anon key in `index.html` is
  public by design.

## Deploy
- Push to `main` → Railway redeploys the backend AND GitHub Pages redeploys the frontend.
- DB schema lives in `backend/schema.sql` (run in the Supabase SQL editor; idempotent).

## Local dev
- Backend: `cd backend && .venv/Scripts/python -m uvicorn main:app --port 8000` (needs `.env`).
- Frontend: `python dev_server.py` (CORS static server) → http://localhost:8300, or any static host.
- The JSX is runtime-Babel in dev; `build.js` precompiles to `www/` for the native build.

## Docs to keep current (Forever Apps §5 doc-currency)
- This `CLAUDE.md`, `README.md` (as-built body), and a dated entry in
  `Dropbox\My AI\CG Apps\Personal CRM\Personal CRM Log\` for every work session.
