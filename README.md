# MSW Community

**The student operating system.** One community where students, colleges, companies and investors come together.

Students lose hours scrolling Instagram, struggle to land jobs, and have ideas nobody validates or mentors. MSW Community turns that screen time into progress. Students learn in 60-second reels, build at hackathons, ship paid tasks for companies, get mentored, and pitch to investors. Everything they do is stamped onto a verified digital ID.

It is the home base of the MSW ecosystem, and other MSW products plug into it. The main one is **[MSW Labs](https://intern.mystartupwave.com/)**, the 30-day full-stack learning platform. Hackathons, Services, Careers and Ventures plug in the same way.

> **Status:** website (Next.js) and app (Flutter) talk to a FastAPI + SQLite backend; both fall back to sample data when the backend is offline.

---

## Repository layout

```
web/       Website — Next.js 16 (App Router, React 19, TypeScript)
app/       Mobile app for students (Flutter: iOS, Android, web)
backend/   API — FastAPI + SQLite
```

## Website — `web/`

The website is for **companies, investors and admins**. Students are sent to the app (`/get-app`).

| Route | What it is |
|---|---|
| `/` | Landing page: halftone hero, the "touch" scroll animation, platform bento, MSW ecosystem, hackathons, digital ID, portals, investors, blog, pricing, social & media |
| `/login` | Log in as Company, Investor or Admin (`?role=company \| investor \| admin`) |
| `/get-app` | For students: App Store / Google Play and a QR code |
| `/blog`, `/blog/[slug]` | Blog |
| `/company/...` | Overview, job postings (detailed form, live toggle), applicants board, paid tasks (GitHub repo, review PR / demo / screenshots, approve & pay or request changes), talent search, profile |
| `/investor/...` | Overview, deals (click a deal for the full pitch, traction, founders, use of funds; back with a cheque slider or pass), portfolio, watchlist, profile |
| `/admin/...` | Platform stats, posts & comments moderation, listings, users (verify, suspend, make admin, delete), quizzes & badges, profile |

Click the avatar in the top-right of any portal to open the profile page. Light and dark themes are supported everywhere (sun/moon button).

**Run it:**

```bash
cd backend && .venv/bin/uvicorn app.main:app --port 8000   # API (optional — the site works offline too)
cd web && npm install && npm run dev                  # → http://localhost:3000
```

Demo logins: `lumen-labs` (company), `nikhil-varma` (investor), `msw-admin` (admin). Point the site at another API with `NEXT_PUBLIC_API_URL`.

Community photos are placeholders. Replace the list in `web/src/lib/photos.ts` with real images.

## App — `app/`

A Flutter app with the same design language as the website, in **light and dark themes**. Switch with the sun/moon button or under Account → Appearance.

- **Onboarding:** a splash collage with the MSW logo, then three illustrated welcome slides with hills, a halftone sun, stickers and page dots.
- **"Who's joining?":** every portal has its own illustrated world.
  - Student: lilac.
  - Company: coral sunset.
  - Investor: indigo night.
  - College: sky blue.
  - Admin: teal night.
- **Login:** an illustrated header per role, a rotating sticker seal, and sign-in / create-account.
- **A separate app per role:**
  - **Student:** Feed, Explore (hackathons, events, jobs, internships, tasks, ideas), Reels (MSW Labs Day 1–30), Grow (courses, games, resume, pitch, plans, quizzes, IQ, badges, GitHub analyser, referrals, blogs) and a digital ID.
  - **Company:** hiring overview, job postings with a live preview, an applicant pipeline, task allocation and paid reviews.
  - **Investor:** portfolio, a swipeable deal deck with a pledge slider, pitch days and a watchlist.
  - **College:** host events with a live poster designer, a judging panel with a live leaderboard, student verification and team check-in.
  - **Admin:** mission control with a live activity feed, task allocation, approvals and moderation, a quiz builder, badges and users.

**Run it:**

```bash
cd app
flutter pub get
flutter run -d chrome      # or an iOS / Android device (needs Xcode / Android Studio)
```

Brand assets live in `app/assets/brand/` and `web/public/img/`.

## Pricing

- **Pro:** ₹99 a month. Can also be unlocked with credits earned by posting, watching reels and finishing challenges.
- **Pro Verified:** ₹299 a month. Same features as Pro, plus the verified badge. Cannot be unlocked with credits.

## Design system

- **Typography:** Instrument Serif for display, Inter for body text, JetBrains Mono for labels.
- **Colours:** off-white `#f3f2ef`, ink `#121212`, teal `#7fd1bd` and lime `#d4f56b`.
- **Signature motif:** the halftone dot field.
