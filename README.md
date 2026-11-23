# MSW Community

**The student operating system.** One community where students, colleges, companies and investors come together.

Students lose hours scrolling Instagram, struggle to land jobs, and have ideas nobody validates or mentors. MSW Community turns that screen time into progress. Students learn in 60-second reels, build at hackathons, ship paid tasks for companies, get mentored, and pitch to investors. Everything they do is stamped onto a verified digital ID.

It is the home base of the MSW ecosystem, and other MSW products plug into it. The main one is **[MSW Labs](https://intern.mystartupwave.com/)**, the 30-day full-stack learning platform. Hackathons, Services, Careers and Ventures plug in the same way.

> **Status:** UI only. Every screen uses mock data and there is no backend yet.

---

## Repository layout

```
website/   Marketing site + role-based dashboards (static HTML / CSS / JS, no build step)
app/       Mobile app (Flutter: iOS, Android, web, macOS)
```

## Website — `website/`

| Page | What it is |
|---|---|
| `index.html` | Landing page: halftone hero, the "touch" scroll animation, feature cards, MSW ecosystem, hackathons, digital ID, portals, investors, pricing, social & media |
| `login.html` | One login for all portals: `?role=student \| company \| investor \| college \| admin` |
| `student.html` | Feed and link posts, blogs, MSW Labs Day 1–30, quizzes, IQ & reasoning, games, hackathons and events (students can post events), jobs and internships, tasks and contributions, business ideas (pitch → validate → mentor → investors), resume builder, digital ID, credits and plans |
| `company.html` | Post jobs and internships, applicant pipeline (drag & drop), allocate paid tasks and review submissions, talent search |
| `investor.html` | Deal flow of student ideas, back an idea, portfolio, founder watchlist, pitch days |
| `college.html` | Host hackathons and events, teams and check-in, judging panel, student verification, placements |
| `admin.html` | Mission control: task allocation board, quiz builder and badges, approvals (contributions, events, verification), users, moderation |
| `blog.html` | Public blog |

**Run it:** open `website/index.html` in a browser, or serve the folder:

```bash
cd website && python3 -m http.server 5173
# → http://localhost:5173
```

Community photos are placeholders. Replace the list in `website/js/photos.js` with real images.

## App — `app/`

A Flutter app with the same design language as the website.

- **Opening:** a photo-collage splash, a role picker and a role-aware login.
- **Feed:** stories, "paste a link, get a post" from X, LinkedIn and Reddit, and double-tap to like.
- **Explore:** hackathons with live countdowns, events (students can post), jobs, internships, tasks (My tasks and Contribute) and business ideas with a pitch flow.
- **Reels:** the MSW Labs full-stack course, Day 1–30.
- **Grow:** courses, games, resume, ideas, plans, quizzes and IQ tests, badges, a GitHub analyser, refer and earn, and blogs (with writing).
- **ID:** a digital student ID card that tilts, flips and has a QR code.

**Run it:**

```bash
cd app
flutter pub get
flutter run -d chrome      # or an iOS / Android device (needs Xcode / Android Studio)
```

## Pricing (draft)

- **Starter:** free.
- **Pro:** ₹99 a month.
- **Pro+:** ₹299 a month.

Active students earn **credits** and can spend them to unlock Pro features.

## Design system

- **Typography:** Instrument Serif for display, Inter for body text, JetBrains Mono for labels.
- **Colours:** off-white `#f3f2ef`, ink `#121212`, teal `#7fd1bd` and lime `#d4f56b`.
- **Signature motif:** the halftone dot field.
