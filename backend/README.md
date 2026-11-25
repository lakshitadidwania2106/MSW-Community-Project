# MSW Community — backend

FastAPI + SQLite, no ORM. The database is `msw.db`. It powers the Flutter app and the website.

## Run

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/uvicorn app.main:app --reload --port 8000
```

- Interactive API docs: http://localhost:8000/docs
- On first start the database is created and filled from `seed.json`.
- To start fresh, stop the server, delete `msw.db` and start it again.
- `seed.json` is exported from the app's sample data. To regenerate it, run `flutter test test/export_seed_test.dart` in the app folder.
- Settings (environment variables): `MSW_DB` (database file), `MSW_SEED` (seed file), `MSW_CORS_ORIGINS` (comma-separated, default `*`).

## Tests

```bash
.venv/bin/pip install -r requirements-dev.txt
.venv/bin/python -m pytest
```

Every test runs against its own fresh, seeded database.

## Layout

```
app/
  main.py            Creates the FastAPI app: CORS, error handling, startup, routers
  core/
    config.py        Settings (database path, seed path, CORS)
    database.py      SQLite connection per request: commit on success, rollback on error
    security.py      Signed-in user (X-User header), admin / role / owner checks
    errors.py        NotFound, Forbidden, BadRequest, Unauthorized
  models/
    tables.py        SQL schema (CREATE TABLE ...)
    mappers.py       Database rows -> JSON shapes the app expects
  schemas/           Request / response bodies (Pydantic): auth, posts, events, opportunities, tasks, ideas, users
  services/          Business logic, one file per area: feed, posts, events, opportunities, tasks, ideas, admin, auth, seed
  routes/            HTTP endpoints, one file per area. They only parse input and call a service
tests/               pytest suite covering every endpoint and permission rule
```

Adding a feature usually means a schema, a service function and a route.

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
