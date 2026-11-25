from tests.conftest import ADMIN, COLLEGE, COMPANY, INVESTOR, STUDENT, as_


def test_health(client):
    assert client.get("/health").json()["ok"] is True


def test_auth(client):
    assert client.get("/bootstrap").status_code == 401
    assert client.get("/bootstrap", headers=as_("nobody")).status_code == 401
    r = client.post("/auth/login", json={"user_id": COMPANY, "role": "company"})
    assert r.status_code == 200 and r.json()["user"]["role"] == "company"
    assert client.post("/auth/login", json={"user_id": "nope", "role": "company"}).status_code == 404


def test_bootstrap_is_seeded(client):
    d = client.get("/bootstrap", headers=as_(STUDENT)).json()
    assert d["me"]["id"] == STUDENT
    for key in ("users", "posts", "events", "opportunities", "tasks", "ideas", "announcements"):
        assert d[key], key


def test_posts_likes_comments(client):
    pid = client.post("/posts", json={"body": "hello"}, headers=as_(STUDENT)).json()["id"]
    assert client.post(f"/posts/{pid}/like", json={"liked": True}, headers=as_(COMPANY)).json() == {"likes": 1}
    assert client.post(f"/posts/{pid}/like", json={"liked": True}, headers=as_(COMPANY)).json() == {"likes": 1}  # idempotent
    assert client.post(f"/posts/{pid}/like", json={"liked": False}, headers=as_(COMPANY)).json() == {"likes": 0}
    assert client.post(f"/posts/{pid}/comments", json={"text": "  "}, headers=as_(COMPANY)).status_code == 400
    cid = client.post(f"/posts/{pid}/comments", json={"text": "nice"}, headers=as_(COMPANY)).json()["id"]
    assert client.delete(f"/comments/{cid}", headers=as_(STUDENT)).status_code == 403
    assert client.delete(f"/comments/{cid}", headers=as_(COMPANY)).status_code == 200
    assert client.delete(f"/posts/{pid}", headers=as_(COMPANY)).status_code == 403
    assert client.delete(f"/posts/{pid}", headers=as_(STUDENT)).status_code == 200
    assert client.delete(f"/posts/{pid}", headers=as_(STUDENT)).status_code == 404


def test_admin_can_hide_posts(client):
    assert client.patch("/posts/1", json={"hidden": True}, headers=as_(COMPANY)).status_code == 403
    assert client.patch("/posts/1", json={"hidden": True}, headers=as_(ADMIN)).status_code == 200
    assert 1 not in [p["id"] for p in client.get("/bootstrap", headers=as_(STUDENT)).json()["posts"]]
    admin_posts = {p["id"]: p for p in client.get("/bootstrap", headers=as_(ADMIN)).json()["posts"]}
    assert admin_posts[1]["hidden"] is True and admin_posts[1]["pinned"] is False


def test_events_and_announcements(client):
    assert client.post("/events", json={"title": "x"}, headers=as_(COMPANY)).status_code == 403
    eid = client.post("/events", json={"title": "Hack"}, headers=as_(COLLEGE)).json()["id"]
    client.post(f"/events/{eid}/register", json={"team": "A"}, headers=as_(STUDENT))
    client.post(f"/events/{eid}/register", json={}, headers=as_(STUDENT))
    regs = client.get(f"/events/{eid}/registrations", headers=as_(COLLEGE)).json()
    assert [r["user_id"] for r in regs] == [STUDENT]
    ev = next(e for e in client.get("/bootstrap", headers=as_(STUDENT)).json()["events"] if e["id"] == eid)
    assert ev["going"] is True and ev["registered"] == 1
    assert client.post("/announcements", json={"title": "a", "body": "b"}, headers=as_(COMPANY)).status_code == 403
    aid = client.post("/announcements", json={"title": "a", "body": "b"}, headers=as_(COLLEGE)).json()["id"]
    assert client.delete(f"/announcements/{aid}", headers=as_(COLLEGE)).status_code == 200


def test_jobs_and_applications(client):
    assert client.post("/opportunities", json={"title": "x"}, headers=as_(STUDENT)).status_code == 403
    oid = client.post("/opportunities", json={"title": "Dev", "company": "Lumen Labs", "live": False}, headers=as_(COMPANY)).json()["id"]
    assert client.patch(f"/opportunities/{oid}", json={"live": True}, headers=as_(INVESTOR)).status_code == 403
    assert client.patch(f"/opportunities/{oid}", json={"live": True}, headers=as_(COMPANY)).status_code == 200
    client.post(f"/opportunities/{oid}/apply", json={"link": "gh"}, headers=as_(STUDENT))
    client.post(f"/opportunities/{oid}/apply", json={}, headers=as_(STUDENT))  # duplicate is ignored
    assert len(client.get(f"/opportunities/{oid}/applications", headers=as_(COMPANY)).json()) == 1
    job = next(o for o in client.get("/bootstrap", headers=as_(STUDENT)).json()["opportunities"] if o["id"] == oid)
    assert job["live"] is True and job["applicants"] == 1 and job["applied"] is True


def test_tasks_and_reviews(client):
    tid = client.post("/tasks", json={"title": "Fix", "reward": 100}, headers=as_(COMPANY)).json()["id"]
    sid = client.post(f"/tasks/{tid}/submissions", json={"repo": "gh/pr/1", "shots": [1]}, headers=as_(STUDENT)).json()["id"]
    assert client.post(f"/tasks/{tid}/submissions", json={}, headers=as_(STUDENT)).status_code == 422
    assert client.patch(f"/submissions/{sid}", json={"status": "Bogus"}, headers=as_(COMPANY)).status_code == 400
    assert client.patch(f"/submissions/{sid}", json={"status": "Approved"}, headers=as_(STUDENT)).status_code == 403
    assert client.patch(f"/submissions/{sid}", json={"status": "Approved"}, headers=as_(COMPANY)).status_code == 200
    task = next(t for t in client.get("/bootstrap", headers=as_(STUDENT)).json()["tasks"] if t["id"] == tid)
    assert task["my_status"] == "Approved" and task["submissions"][0]["shots"] == [1]


def test_investor_decisions(client):
    base = next(i for i in client.get("/bootstrap", headers=as_(INVESTOR)).json()["ideas"] if i["id"] == 1)["raised"]
    assert client.post("/ideas/1/decision", json={"decision": "backed", "amount": 1}, headers=as_(STUDENT)).status_code == 403
    assert client.post("/ideas/1/decision", json={"decision": "backed", "amount": 1.5}, headers=as_(INVESTOR)).json()["raised"] == round(base + 1.5, 2)
    assert client.post("/ideas/1/decision", json={"decision": "backed", "amount": 2}, headers=as_(INVESTOR)).json()["raised"] == round(base + 2, 2)
    assert client.post("/ideas/1/decision", json={"decision": "passed"}, headers=as_(INVESTOR)).json()["raised"] == base
    assert client.post("/ideas/1/decision", json={"decision": None}, headers=as_(INVESTOR)).json()["raised"] == base
    assert client.post("/ideas/999/decision", json={"decision": "backed", "amount": 1}, headers=as_(INVESTOR)).status_code == 404


def test_admin_users(client):
    assert client.get("/admin/stats", headers=as_(COMPANY)).status_code == 403
    assert client.get("/admin/stats", headers=as_(ADMIN)).json()["users_by_role"]["admin"] == 1
    client.patch(f"/users/{STUDENT}", json={"status": "Suspended"}, headers=as_(ADMIN))
    assert client.get("/bootstrap", headers=as_(STUDENT)).status_code == 403
    client.patch(f"/users/{STUDENT}", json={"status": "Verified", "is_admin": True}, headers=as_(ADMIN))
    assert client.get("/admin/stats", headers=as_(STUDENT)).status_code == 200
    assert client.delete("/users/kabir-nair", headers=as_(ADMIN)).status_code == 200
    assert "kabir-nair" not in [u["id"] for u in client.get("/admin/users", headers=as_(ADMIN)).json()]


def test_failed_request_rolls_back(client):
    """A request that errors part-way must not leave half-written data."""
    before = client.get("/admin/stats", headers=as_(ADMIN)).json()["posts"]
    assert client.delete("/posts/9999", headers=as_(ADMIN)).status_code == 404
    assert client.get("/admin/stats", headers=as_(ADMIN)).json()["posts"] == before
