# ContactCaptain — Built & Roadmap

A personal relationship manager: stay close to the people in your orbit, with an optional
deals layer. Live at **https://contactcaptain.com**.

New here? Read `CONTRIBUTING.md` (how to work on this) and `CLAUDE.md` (architecture,
endpoints, conventions) first. Deployed version comes from `APP_VERSION` in `index.html`
and the live `/api/health` — not written down here, so this file can't go stale on it.

---

## ✅ Built and live

### People
- Contacts: multiple emails + phones, company link, title, location, tags, how-we-met,
  birthday, notes.
- Organizations: created inline when you type a company on a contact, or added directly;
  org detail lists its linked contacts.
- Tags as filterable chips; search across name / company / title / tags / email.
- People vs Companies segmented list.

### The relationship engine (the point of the app)
- **Interactions**: log call / text / email / in-person / note with date + notes; per-contact
  timeline; logging updates "last contacted".
- **Follow-up tasks**: per contact, optional due date, check off when done.
- **Keep-in-touch cadence**: 30 / 60 / 90 / 180 / 365 days per contact.
- **Home screen** = the daily view: who you're overdue to reach out to, open follow-ups, and
  birthdays in the next 30 days. One-tap "Logged"; reminders **dismiss** (snooze) rather than
  delete, because a reminder row is a view of a contact, not a thing to destroy.

### AI (routed to Sonnet)
- ✨ **Summarize** your history with a person, and suggest a next step.
- ✨ **Draft check-in** — a warm reconnect message, ready to copy.
- Metered and capped per user, with a monthly cost breaker on the backend.

### Digital business card
- Card editor (name, title, company, location, bio, chosen emails/phones/links, accent color)
  → **Publish** → shareable **link + QR** + native Share.
- **Public page** at `/?card=<slug>` — no login: tappable contact methods, **Save contact**
  (vCard download), and a "share your info back" form.
- Submissions land in a **Connections inbox** → *Add to contacts* (auto-tagged "Met via card")
  or *Dismiss*, so nothing reaches the real contact list unreviewed.

### Deals (optional layer, toggled in Settings)
- Pipeline grouped by stage (Lead / Contacted / Proposal / Won / Lost), open + won totals,
  deal detail with one-tap stage changes and contact/company linking.

### Import & data hygiene
- **vCard (.vcf)** import, parsed on-device. Preserves the export's **phone/email type labels**
  (so "which one is his mobile" is answered from the source data), normalizes phones to
  **E.164**, and records **source + scope** (personal/work) per contact.
- **Review queue**: imports write immediately and flag each contact for review; the queue works
  through them one at a time, **resumable across days and devices** (state lives on the record,
  not in the tab). Confirm / edit / archive, with flags for the suspicious ones.
- **Personal / Work / All** filter on the People screen. Archive hides without deleting.
- Original behaviour still applies: Cleans as it goes and dedupes twice: duplicates
  within the file, and against contacts you already have (matched on email/phone,
  case-insensitive). Review screen shows **New vs Merge** before anything is written.

### Platform
- Installable PWA, offline support, in-app update prompt.
- **Optimistic sync with retry**: saves land locally first, then push; anything unconfirmed is
  retried and visibly flagged. A failed push must never read as "synced".
- Email/password auth, **password reset** (forgot link → emailed link → set new password),
  branded email via Resend, dark/light themes, account deletion.

### Infrastructure
- Frontend on GitHub Pages at contactcaptain.com (HTTPS); backend (FastAPI) on Railway;
  Supabase Postgres + Auth (RLS on, backend-only access).
- `main` is protected: PR + approval required. A pre-push audit gate blocks known-bad backend
  patterns. See `CONTRIBUTING.md`.

---

## 🗺️ Roadmap

### Now
1. **Import real contacts** — Gmail (x2 accounts) + iCloud exports, then work the review queue
   at your own pace. The engine only comes alive with real people in it.
2. **Re-enable "Confirm email"** in Supabase now that Resend delivers reliably.
3. Optional: URL-forward the old getinnerorbit.io → contactcaptain.com to rescue card links
   shared before 2026-08-19.

### Next features (rough priority)
4. **Google Contacts sync** — the realistic "sync back to my phone". Google has a contacts API;
   Apple has no cloud equivalent. Start one-way, then two-way with conflict rules.
5. **Live card preview** — see the card render while editing it, instead of opening the link.
6. **Email → auto-timeline** — match Gmail threads to contacts and log them automatically.
   Needs Google's restricted-scope review, so treat it as a project, not an afternoon.
7. **Enrichment** — fill missing company/title/social as *suggestions you confirm*, with the
   source shown. Never silent overwrites.
8. **Saved segments, contact photos, bulk actions.**

### Bigger milestones
9. **Native apps** (Capacitor → App Store / Play, under MilSpo Life LLC). Also the only way to
   reach on-device Apple Contacts.
10. **Push notifications** — needs Firebase; the frontend seam exists and is gated off.
11. **Pro tier** (Stripe) if this is ever monetized. Free today.

### Known platform limits (not effort problems)
- ❌ **Auto-importing texts / iMessage.** Apple exposes no API for it, at all. Android SMS access
  exists but Play only grants it to default SMS apps. Manual logging is the honest answer.
- ❌ **Apple Contacts sync from the web.** On-device only, so it waits for the native build.

---

## Good first tasks for a new contributor
Small, self-contained, and unlikely to collide with in-flight work:
- Live card preview in the editor (#5).
- Empty-state and copy polish across screens.
- Contact photos (avatar upload) on the contact form.
- Saved filters / segments on the People screen.

Check open PRs first, and say which one you're taking so two people don't build the same thing.
