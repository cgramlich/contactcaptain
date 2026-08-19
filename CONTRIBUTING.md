# Contributing to ContactCaptain

Welcome! This guide gets a second developer productive without touching production
secrets or the live site. It assumes you're new to GitHub — no command line required.

## The one thing to know first

**`main` is the live site.** Anything merged into `main` deploys automatically:

- the app → https://contactcaptain.com (GitHub Pages)
- the API → Railway (`backend/`)

So we never commit straight to `main`. **Work on a branch, open a Pull Request (PR),
get it reviewed, then merge.** That way nothing reaches real users until it's approved.

## Never commit secrets

- `backend/.env` holds live keys (Supabase secret, Anthropic). It is gitignored — keep it
  that way, and never paste its contents into a file, a PR, or a chat.
- You do **not** need any secrets to work on the frontend (see below).
- The Supabase *publishable* key in `index.html` is public by design — that one is fine.

## What you need

- A GitHub account (you have one) — ask Chris for a collaborator invite.
- A browser. That's genuinely enough for most changes.
- Optional: your own Claude Code subscription if you want AI help while coding.

## Easiest path: edit in the browser (no installs)

1. Go to https://github.com/cgramlich/contactcaptain
2. Press the **`.`** key (or change the URL from `github.com` to `github.dev`).
   A full VS Code editor opens in your browser.
3. **Make a branch first**: click the branch name (bottom-left in github.dev, or the
   branch dropdown on the repo page) → type a new name like `mark/card-preview` → create it.
4. Edit files, then commit from the Source Control panel (left sidebar, the branch icon).
5. Back on github.com you'll see a **"Compare & pull request"** button → click it, describe
   what you changed, and open the PR.

## Running it locally (optional)

The app is a single HTML file — no build step, no npm install.

```bash
git clone https://github.com/cgramlich/contactcaptain.git
cd contactcaptain
python dev_server.py        # serves on http://localhost:8300
```

That local frontend talks to the **live** Railway backend, so sign-in and data work with no
secrets on your machine. Note this means you are working against **real data** — be careful
with anything destructive.

Want a fully isolated stack (your own database, no risk to real data)? Create your own free
Supabase project, run `backend/schema.sql` in its SQL editor, put your own keys in
`backend/.env` (copy `.env.example`), and run the backend per `backend/README.md`.

## Project layout

```
index.html      the entire app (single-file React-via-CDN PWA)
sw.js           service worker / offline + cache versioning
backend/        FastAPI + Supabase API (main.py, schema.sql)
CLAUDE.md       architecture, endpoints, env vars, conventions — READ THIS FIRST
```

## House rules

- **Read `CLAUDE.md`** before changing architecture — it's the source of truth.
- **Bump the version on any user-facing change**: `APP_VERSION` + `BUILD` in `index.html`
  and `VERSION` in `sw.js`, all in lockstep. This drives the in-app update prompt.
- **Never hardcode a version number in docs** — point at `APP_VERSION` / `/api/health`.
- **Comment the *why*, not the *what*.** Business rules get a plain-English note beside the
  code enforcing them. This code should be readable by someone joining cold.
- **AI model floor: Sonnet.** No task routes to Haiku.
- Keep secrets out of the repo; keep `RLS on, no policies` (backend-only DB access).

## PR checklist

- [ ] Branch off `main`, descriptive branch name
- [ ] App still loads with no console errors
- [ ] Version bumped if the change is user-facing
- [ ] Docs updated in the same PR if behavior/architecture changed
- [ ] No secrets, no `.env`, no real personal data in the diff
