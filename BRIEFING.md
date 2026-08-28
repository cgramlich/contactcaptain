# ContactCaptain — BRIEFING

Deck-ready source material. Hand this to a design tool with a design type and an audience and it
should produce something accurate without asking follow-up questions.

**Every person, company and phone number in this file is fabricated.** ContactCaptain is a
personal CRM, so its real data is entirely personal information and none of it appears here. The
examples below are invented to match the shape of real data, not drawn from it.

---

## The arc

**Situation.** Everyone has a few hundred people they genuinely care about keeping up with, and
a contact list that has quietly become a junk drawer: three entries for the same person, a work
email from two jobs ago, a number nobody knows is a landline. Phone address books store contacts
but say nothing about relationships. Sales CRMs model relationships but are built for pipelines
and quotas, and they feel like work.

**Problem.** The gap is not storage; it is attention and trust. Two failures, and they compound.
People drift because nothing tells you it has been eight months since you last spoke to someone
you actually like. And when something finally does prompt you, the data is too stale to act on —
you do not know which of the three numbers is the one that reaches them.

**What was built.** ContactCaptain is a personal relationship manager. You set how often you want
to stay in touch with someone — every 30, 90, 180 days — log conversations as they happen, and
the home screen becomes a short list of who you owe a reach-out to, with birthdays and follow-ups
alongside. An AI assistant summarizes your history with a person and drafts a warm check-in. A
shareable digital business card (link and QR) lets someone you just met save your details and
send theirs back, landing in a review inbox rather than straight into your contacts. An optional
deals layer covers the light business case without imposing a sales workflow on a personal tool.

Underneath sits the part that makes the rest trustworthy: an import pipeline that treats contact
hygiene as a first-class problem rather than a one-time chore.

**What it means now.** The product is live on the web, installable on a phone, and feature
complete for version 1. It was scoped on 23 June 2026 and reached a working deployment the same
day; the contact-hygiene work landed on 20 August 2026. The remaining work is adoption and reach
— getting real contacts in, then syncing back out to the phone.

---

## The idea worth stealing: hygiene as a workflow, not a chore

Most tools treat contact cleanup as a modal task you complete once. That is wrong twice over.
Nobody reviews four thousand contacts in one sitting, and a review screen that blocks the import
holds the entire product hostage until you finish.

ContactCaptain separates them. The import runs immediately and flags every touched record for
review. A queue then presents one contact at a time, with the reason it was flagged, and four
choices: keep, edit, archive, skip. **Queue state lives on the record in the cloud, not in the
browser tab** — so you can spend five minutes on it at a stoplight, stop mid-way, and pick up
days later on a different device. The app is fully usable the entire time.

Two design rules fall out of that, and both are quotable:

- **Archive is not delete.** A record that looks like junk is usually the product of a bad
  import, not a bad relationship. Archived contacts leave your views and keep their history.
- **Never merge silently.** Every merge is shown before it happens. Automatic merging is the
  fastest way to destroy data a user cannot get back.

---

## Concrete figures

| Figure | Value | Date / source |
|---|---|---|
| Scoped to first live deployment | Same day | 23 June 2026, project log |
| Contact-hygiene release (typed numbers, E.164, review queue) | 20 August 2026 | project log |
| Commits on the main branch | 39 | repository, 28 August 2026 |
| Entire frontend | ~2,640 lines, one file, no build step | repository, 28 August 2026 |
| Backend | ~670 lines | repository, 28 August 2026 |
| Deploy time, commit to live | 1–3 minutes, both halves | measured across releases |
| Data types modelled | 5 (contacts, organizations, interactions, tasks, deals) | repository |
| Keep-in-touch intervals offered | 30 / 60 / 90 / 180 / 365 days | product |
| AI calls included on the free tier | 50 per month, per user | product configuration |
| AI model floor | Sonnet class for every task; no cheaper tier used | portfolio standard |
| Comparable product pricing | One-time $4.99, premium $5.99/mo or $49.99/yr | Toldari, toldari.app, retrieved August 2026 |

**The dedupe figure that explains itself.** A contact stored as `(555) 111-2222` in one account
and `555.111.2222` in another is one person to a human and two people to almost every importer.
Normalizing every number to a single canonical form before matching collapses that pair
automatically. *(Numbers fabricated.)*

---

## Quotable claims, all true

- "Your phone stores contacts. It does not help you keep them."
- "Archive is not delete — a record that looks like junk is usually a bad import, not a bad
  relationship."
- "Nobody cleans four thousand contacts in one sitting, so the queue remembers where you stopped
  — on any device."
- "In the United States you cannot tell a mobile number from a landline by looking at it. The
  export you already have knows, and most tools throw that away on import."
- "Every merge is shown before it happens. Silent merging is the fastest way to lose data a user
  can never recover."
- "The app is useful the whole time you are cleaning it up, not after."

---

## What deserves a picture

1. **Before and after of one messy contact.** Three entries for a fabricated "Dana Whitfield"
   across a phone, a personal account and a work account — inconsistent number formats, an
   expired work email — collapsing into a single record with the mobile correctly labelled.
   Carries the whole product thesis in one image.
2. **The home screen as a short list.** Not a dashboard of counts: four or five names with "reach
   out — 42 days overdue" beside them. The contrast with a conventional CRM dashboard is the
   point.
3. **The review queue as a progress arc.** One card, four choices, "312 left" — with a device
   handoff shown (laptop to phone) to make the resumability concrete.
4. **The digital card loop.** Meet someone → they scan a QR → they save your details and send
   theirs → the submission lands in a review inbox, not directly in your contacts. A small
   circular diagram.
5. **Positioning map.** Two axes: personal versus sales-oriented, and local-only versus
   cloud-and-AI. Shows where a phone address book, a sales CRM, a privacy-first personal CRM, and
   ContactCaptain each sit.

---

## Angles by audience

**Investor / strategic.** A category exists between the address book and the sales CRM, and the
current occupants split along a philosophical line: privacy-first and local, or cloud and
capable. Local-first competitors trade away AI, cross-device sync and shareable identity to make
their privacy claim. ContactCaptain takes the other side deliberately. That a nearby competitor
charges a one-time fee plus a subscription is evidence people pay for this category.

**Client / user.** You do not need discipline; you need a short list. Set how often you want to
stay in touch, log conversations in a couple of taps, and open the app to four names rather than
four hundred. Import from your phone and your email accounts, and clean up at your own pace
instead of losing a weekend to it.

**Team / technical.** A deliberately small stack: a single-file frontend with no build step, a
compact API, and a database the browser cannot touch directly — every read and write goes through
the backend. Push to the main branch and both halves deploy in a couple of minutes. Optimistic
saves with retry, and an explicit rule that a failed save must never look like a successful one.
Data hygiene is enforced at the boundary: canonical phone formats and preserved type labels at
import time, because that information cannot be reconstructed later.

---

## Do not say

- **Do not use any real contact, name, phone number, email address or interaction note.** The
  entire dataset is personal information. Every example must be fabricated and labelled as such.
- **No infrastructure identifiers** — no API endpoints, hosting URLs, project identifiers,
  database names or keys.
- **Do not claim a user base, revenue, growth or retention.** There are none; the product is in
  personal use and has not been marketed.
- **Do not claim contact sync with phones works today.** Sync back to Google Contacts is planned,
  not built. Apple offers no cloud contacts API at all, so anything on iPhone requires the native
  app, which is not built either.
- **Do not imply texts or iMessage can be imported.** They cannot, on any platform, by any app.
  Saying otherwise would be a false product claim.
- **Do not present competitor pricing as current** without re-checking it; the figure here was
  retrieved in August 2026.
- **Do not describe the AI as autonomous.** It summarizes and drafts; the user sends.
