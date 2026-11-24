# MSW Community — backend

FastAPI + SQLite. One file (`app.py`), no ORM, database in `msw.db`.

## Run

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/uvicorn app:app --reload --port 8000
```

- Interactive API docs: http://localhost:8000/docs
- On first start the database is created and filled from `seed.json`.
- To start fresh, stop the server, delete `msw.db` and start it again.
- `seed.json` is exported from the app's sample data. To regenerate it, run `flutter test test/export_seed_test.dart` in the app folder.

## What is stored

| Table | Holds |
|---|---|
| `users` | Students, companies, investors, colleges and admins (status, admin flag) |
| `posts`, `comments`, `post_likes`, `post_saves` | Feed posts made from links, captions, likes, saves, comments |
| `events`, `event_registrations` | Hackathons and events colleges host, plus who registered (team, track) |
| `announcements` | College announcements |
| `opportunities`, `applications` | Jobs and internships companies post, plus student applications |
| `tasks`, `submissions` | Paid company tasks (GitHub repo) and student submissions (PR, demo, screenshots, review status) |
| `ideas`, `idea_decisions` | Startup ideas, plus each investor's back or pass decision and cheque size |

## Permissions

- Only companies can post jobs and tasks.
- Only colleges can post announcements.
- Investors decide on ideas.
- Owners and admins can delete content.
- Admins can suspend, verify, promote or delete any account (`/admin/*`, `/users/*`).

## Auth (development only)

The app sends the signed-in account id in the `X-User` header. This must be replaced with real sign-in (JWT, or Google / GitHub OAuth) before launch.
