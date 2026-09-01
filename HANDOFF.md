# ContactCaptain — HANDOFF

Zero-context resumption document. If you have no memory of this project, read only this file
and you should be able to make the next change correctly **without asking anyone and without
undoing something that was chosen on purpose.**

**Naming.** The product is **ContactCaptain** (confirmed 2026-08-29). "Orbit" / "Inner Orbit"
is the OLD name, retired from the product, the repo, the local folder and the appId. It survives
in exactly three places, each for a reason:

| Where | Why it stays |
|---|---|
| `getinnerorbit.io` | A domain that really was ours. Now 404s; kept in CORS and in the history below so nobody re-adds it as a fallback. |
| The legacy `orbit_*` localStorage keys | Read-only fallback so existing installs are not signed out. Deleting them logs people out for no benefit. |
| The Railway service label `inner-orbit` | Internal only and invisible to every client. Renaming the service swaps its URL out from under the deployed frontend; the custom domain made it moot. |

Anything else calling this "Orbit" is stale and should be corrected.

`HANDOFF.md` is authoritative. `BRIEFING.md` derives from it. `CLAUDE.md` holds the in-repo
architecture detail; `ROADMAP.md` lists built features and what is next; `CONTRIBUTING.md` is
the process for a second developer.

---

## What this is

A personal CRM — a relationship manager for staying in touch with people who matter, with an
optional lightweight deals layer for the business side. You add people, log the times you talk
to them, set how often you want to stay in touch, and the Home screen tells you who you owe a
reach-out to. Built for Chris personally first; a Forever Apps portfolio product second.

Single-file React-via-CDN PWA (no build step in dev) + FastAPI/Supabase backend, on the same
stack as the rest of the portfolio.

---

## Current state — 2026-08-31

- **Live and in daily-usable shape.** Frontend on GitHub Pages at **contactcaptain.com**
  (HTTPS enforced). Backend on Railway, healthy, AI configured. Supabase Postgres + Auth.
- **Versions:** read them, do not trust a number written in prose. `APP_VERSION` + `BUILD` in
  `index.html`, `VERSION` in `sw.js` (all three move together), and the backend `/api/health`.
  Do not copy a number out of this bullet into anything.
- **The database is essentially empty.** One account (Chris). Contacts, interactions, tasks and
  deals are all empty; one digital card exists. **The contact import has not been run** — this
  is the single biggest gap between "built" and "useful", and it is what most of the recent
  work has been aimed at surviving.
- Second developer **Mark (`mhutdallas`)** has accepted a write invite.

---

## The map

| Path | Owns |
|---|---|
| `index.html` | The entire frontend — one file. Auth, sync, every screen, the card, the importer. |
| `sw.js` | Service worker: offline shell + data reads, cache versioning. |
| `backend/main.py` | The whole API: auth, collections, AI relay, digital card, push seam. |
| `backend/schema.sql` | Supabase schema. Idempotent, safe to re-run. |
| `backend/.env` | Local secrets. **Gitignored, never committed.** |
| `build.js` | Native build: precompiles the JSX to `www/` for Capacitor. Not yet used in anger. |
| `CLAUDE.md` | Architecture, endpoints, env vars, conventions. Auto-read by Claude Code. |
| `dev_server.py` | Local static server with permissive CORS. Dev only. |

- **Repo:** `github.com/cgramlich/contactcaptain` (public). Local clone:
  `C:\Users\cjgra\contactcaptain` (renamed from `orbit-crm` on 2026-08-29; nothing
  depended on the old folder name - the pre-push hook uses absolute paths elsewhere).
- **Docs (Dropbox):** `CG Apps\Personal CRM\` — `Personal CRM Log\` holds dated session entries,
  `Personal CRM Architecture & Design\` holds the original scope doc.

---

## How to run, build and deploy

Frontend, locally. The app is one file; there is no build step and no npm install:

```bash
python dev_server.py
```

Then open `http://localhost:8300`. It talks to the **live** backend, so you are working against
real data. Be careful with anything destructive.

Backend, locally (needs `backend/.env` populated):

```bash
./.venv/Scripts/python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000
```

Deploy — there is no deploy command. **Pushing to `main` deploys both halves:**

```bash
git push origin main
```

Railway rebuilds the backend from `backend/`; GitHub Pages rebuilds the frontend from the repo
root. Both take roughly one to three minutes. **Bump `APP_VERSION` + `BUILD` + `sw.js` VERSION
together on any user-facing change**, or the in-app update banner never fires.

Schema changes are pasted into the Supabase SQL editor by hand. There is no migration runner;
`schema.sql` is the record of what should exist.

---

## Decisions, dated, with the road not taken

### Naming and identity
- **2026-06-23 → 2026-08-19: appId `com.orbitcrm.app` became `com.contactcaptain.app`.** Changed
  while still unpublished, because an appId is permanent from the first store submission.
  *Rejected:* keeping the old id "because it is invisible" — true today, immovable once shipped.
- **2026-08-19: renamed Inner Orbit → ContactCaptain**, adopting the portfolio Captain family.
  The GitHub repo, appId and domain followed. **2026-08-29:** the local folder followed too
  (`orbit-crm` → `contactcaptain`), once it was confirmed nothing referenced it.
  **2026-08-30:** the API moved to **`api.contactcaptain.com`** (the portfolio pattern, as with
  api.linkscaptain.com). *Rejected:* renaming the Railway service, which swaps its URL out from
  under the already-deployed frontend. A custom domain leaves BOTH hostnames answering, so the
  cutover had no outage window. The Railway service is still internally labelled `inner-orbit`;
  that label is invisible to everything and is not worth touching.

### Domain
- **2026-08-19: getinnerorbit.io is dead, not a fallback.** GitHub Pages serves exactly **one**
  custom domain per repo, so the moment `CNAME` flipped, the old domain began returning 404. A
  commit message at the time claimed it would keep working; that was wrong and is corrected.
  *Open option:* URL-forward it at Porkbun to rescue card links shared before the move.
- `cardUrl()` therefore builds from the **live origin**, never a constant, so a future domain
  change cannot strand shared links again.

### Data model
- **2026-08-20: contact methods are EITHER a plain string OR `{v,t}`** (value plus a type label
  like `mobile`). Read only through `cmValue`/`cmType`; write through `cmMake`. *Rejected:* a
  one-off migration of every existing record — the compatibility helpers are three lines and
  cannot half-fail on someone's cached data.
- **2026-08-20: phones normalize to E.164** on import and on manual entry. That is what makes
  `(555) 111-2222` and `555.111.2222` the same person instead of two contacts. `DEFAULT_DIAL_CC`
  assumes US/Canada for bare 10-digit numbers, which is what the source exports contain.
- **2026-08-20: vCard `TYPE` labels are preserved.** This is the answer to "which number is
  actually his mobile" — the export already knows. **A US mobile cannot be identified from the
  digits after the fact**: there is no prefix rule and portability erased what pattern existed.
  Dropping the label is unrecoverable without a paid carrier lookup. Do not simplify it away.
- **2026-08-20: import writes immediately; review happens afterwards, in a queue.** *Rejected:*
  gating the import behind a full review screen — unusable for thousands of contacts, and all
  progress is lost when the tab closes. Queue state lives on the contact record in the cloud
  (`needs_review`), which is exactly what makes it resumable across days and devices.
- **Archive is not delete.** Archived contacts leave the views but keep their history, because
  the usual reason a record looks like junk is a bad import rather than a bad contact.
- **2026-08-31: that promise is now actually implemented.** It had been written down and
  believed for eleven days while nothing in the app ever read an archived contact back —
  `archived` was set in one place and filtered out in three, so archiving was a slower delete
  and the code comment claiming archived records were searchable was false. There are now two
  ways back (an Archived view, and search, which sweeps the archive and labels those rows) plus
  Restore on the contact detail. *Rejected:* leaving it until after the import "since nothing is
  archived yet" — the queue's one destructive button was about to be pressed thousands of times.
- **2026-08-31: the review queue gained a bulk list mode** beside the one-at-a-time card: filter
  by flag, select, Keep or Archive in one action. *Rejected:* auto-confirming the clean-looking
  contacts on import, which shrinks the backlog faster but clears records you never lay eyes on.
  The judgement stays with the human; only the clicking is batched. Bulk actions write the whole
  contacts array once per action, not once per contact — see CLAUDE.md.

### Auth, email, security
- **RLS enabled with NO policies on every table.** The backend secret key bypasses RLS, so the
  browser publishable key can touch nothing directly. Portfolio-wide rule. Adding a policy to
  "make the client work" would be a critical exposure, not a fix.
- **2026-08-19: auth email goes through Resend SMTP**, not Supabase's built-in sender. See traps.
- **Resend is registered on the ROOT domain.** *Rejected after actually trying it:* a
  `send.contactcaptain.com` subdomain, added out of a misplaced fear that Resend would put an MX
  on the root and collide with Porkbun email forwarding. It does not — Resend isolates its bounce
  MX on `send.<domain>` by design. The subdomain produced `send.send…` and an uglier sender.
- **2026-08-19: storage keys renamed `orbit_*` → `cc_*` WITH a legacy read-fallback**, so
  existing installs were not silently signed out. `signOutHard` must clear the legacy keys too;
  without that, the fallback resurrects the session that was just signed out.
- **Email confirmation is currently OFF** in Supabase, turned off to unblock testing. Decide
  whether to re-enable before real users. The app handles either.

### Collaboration
- **2026-08-19: `main` protected** — PR + 1 approval, no deletions, no force-push, with a
  `RepositoryRole` bypass. *Rejected:* no bypass. GitHub does not allow approving your own PR, so
  a strict rule locks the sole owner out of his own repository.
- **The repo is public.** That is what makes GitHub Pages free. History has been scanned: no
  secret has ever been committed and `.env` has never been tracked. The Supabase publishable key
  in `index.html` is public by design.

### AI
- **Sonnet is the floor.** All three tasks route to Sonnet; none routes to Haiku. This
  contradicts a plausible local argument ("these are short text tasks, Haiku is plenty"), which
  is precisely why it is written down. Enforced by the pre-push gate, check B6.

### Product positioning
- **Cloud and AI, deliberately not privacy/local-first.** The nearest competitor (Toldari) is
  local-first and sells on privacy. Competing on that ground would forfeit AI, cross-device sync,
  the shareable card and contacts sync — the actual advantages here. Do not drift.

---

## Traps — each cost real time

- **A "Database error" while auth and AI work fine means the wrong Supabase key.** Railway held
  the *legacy* `eyJ…` service_role key after legacy keys were disabled on the project. Auth
  (JWKS) and the AI relay were unaffected, so only DB routes 500'd — a very misleading
  signature. It must be the `sb_secret_…` key.
- **"Account created but no email" can mean no account was created.** Supabase's built-in email
  sender is testing-only with a low hourly cap; when exceeded, Supabase **rejects the signup
  outright**. Check the user list before debugging email. Fixed by moving to Resend SMTP.
- **Supabase ships with Site URL = `http://localhost:3000`.** Every confirmation and reset link
  went to a dead address until it was set to the real site. Looks like broken auth code. It isn't.
- **Route order in `backend/main.py`: `/api/card/leads` must be declared before
  `/api/card/{slug}`**, or "leads" is captured as a slug.
- **New Supabase tables 404 with `PGRST205` until they exist.** Endpoints ship before tables do;
  run the SQL.
- **Assuming `emails`/`phones` are strings renders `[object Object]`.** Always `cmValue`.
- **The pre-push audit gate had never actually audited this repo.** It looked for `main.py` at a
  repo root; this one lives at `backend/main.py`, so the backend checks silently skipped and it
  reported clean. Fixed 2026-08-24 by another session. If the gate says clean, confirm it really
  ran the backend checks.
- **`--no-verify` is never the answer.** If the gate is wrong, fix the checker.

---

## What is open

### Blocked on Chris
- **Run the contact import.** Exports from Gmail (CJG Personal and STB) and iCloud. Nothing is
  imported yet; the app is empty.
- **Work contacts: scope undecided.** He asked about importing RTR/RCLP (employer Exchange).
  Flagged against his own standing rule — no real borrower or employee data in personal tools —
  and the question of who owns contacts in an employer mailbox. Recommendation on the table:
  import only relationships he would keep if he left (vendors, counterparties, peers).
  **He has not decided. Do not import work accounts until he does.**
- Re-enable email confirmation; optional getinnerorbit.io URL-forward.
- Optionally retire the old `inner-orbit-production.up.railway.app` domain in Railway once
  nothing references it. It costs nothing to leave, and leaving it means any old client that
  still points there keeps working.
- Whether Mark works from `mhutdallas` or a second GitHub account he mentioned.

### Known gaps
- **No manual merge tool.** Dedupe matches on email or phone only, so two records for one person
  sharing neither will both survive with no way to merge them by hand. Deliberately deferred
  until after the import, so it can be aimed at the duplicates that actually occur.
- **The card QR comes from a public image service.** Fine on the web; vendor or inline a
  generator before the native build, which must not load off-CDN.
- `backend/.env` currently has an empty `SUPABASE_SERVICE_ROLE_KEY` locally. Production on
  Railway is unaffected, but the local backend will not start until it is refilled.
- No live preview in the card editor; you must open the link to see the card.
- **No automated tests of any kind.** The 2026-08-31 review-queue and archive work was verified
  by driving a browser against an offline-mode copy of the app; that harness lives in a session
  scratchpad, not in the repo. Anyone touching those paths is re-verifying by hand.

### Parked (understood, not started)
Google Contacts sync; Gmail → auto-timeline (needs Google's restricted-scope review); enrichment
as confirm-first suggestions; native Capacitor build and store listings; push (needs Firebase);
Pro tier.

### Not possible — stop looking
Auto-importing texts or iMessage: Apple exposes no API, and Play restricts SMS access to default
SMS apps. Apple Contacts sync is on-device only, so it waits for the native build.

---

## Where authority lives

| Question | Truth |
|---|---|
| What version is deployed | `APP_VERSION`/`BUILD` in `index.html`; backend `/api/health` |
| Architecture, endpoints, env vars | `CLAUDE.md` |
| Why something is the way it is | this file |
| What exists and what is next | `ROADMAP.md` |
| Auth settings, Site URL, rate limits | the Supabase dashboard, not any file here |
| Production env vars | Railway. `backend/.env` is local only and may differ |
| Email delivery status | the Resend dashboard, Emails tab |
