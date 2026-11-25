from __future__ import annotations

import sqlite3

from app.core.errors import BadRequest
from app.core.security import require_owner_or_admin
from app.schemas.posts import ModeratePostIn, PostIn
from app.services.ownership import owner_of


def create(con: sqlite3.Connection, user: sqlite3.Row, p: PostIn) -> int:
    return con.execute("INSERT INTO posts (author_id, data) VALUES (?, ?)", (user["id"], p.model_dump_json())).lastrowid


def set_like(con: sqlite3.Connection, user: sqlite3.Row, pid: int, liked: bool) -> int:
    if liked:
        if con.execute("INSERT OR IGNORE INTO post_likes VALUES (?, ?)", (pid, user["id"])).rowcount:
            con.execute("UPDATE posts SET likes = likes + 1 WHERE id = ?", (pid,))
    elif con.execute("DELETE FROM post_likes WHERE post_id=? AND user_id=?", (pid, user["id"])).rowcount:
        con.execute("UPDATE posts SET likes = MAX(likes - 1, 0) WHERE id = ?", (pid,))
    row = con.execute("SELECT likes FROM posts WHERE id = ?", (pid,)).fetchone()
    return row[0] if row else 0


def set_saved(con: sqlite3.Connection, user: sqlite3.Row, pid: int, saved: bool) -> None:
    if saved:
        con.execute("INSERT OR IGNORE INTO post_saves VALUES (?, ?)", (pid, user["id"]))
    else:
        con.execute("DELETE FROM post_saves WHERE post_id=? AND user_id=?", (pid, user["id"]))


def add_comment(con: sqlite3.Connection, user: sqlite3.Row, pid: int, text: str) -> int:
    text = text.strip()
    if not text:
        raise BadRequest("Empty comment")
    return con.execute("INSERT INTO comments (post_id, author_id, text) VALUES (?, ?, ?)", (pid, user["id"], text)).lastrowid


def delete(con: sqlite3.Connection, user: sqlite3.Row, pid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "posts", pid))
    con.execute("DELETE FROM posts WHERE id = ?", (pid,))


def moderate(con: sqlite3.Connection, pid: int, body: ModeratePostIn) -> None:
    if body.hidden is not None:
        con.execute("UPDATE posts SET hidden = ? WHERE id = ?", (int(body.hidden), pid))
    if body.pinned is not None:
        con.execute("UPDATE posts SET pinned = ? WHERE id = ?", (int(body.pinned), pid))


def delete_comment(con: sqlite3.Connection, user: sqlite3.Row, cid: int) -> None:
    require_owner_or_admin(user, owner_of(con, "comments", cid))
    con.execute("DELETE FROM comments WHERE id = ?", (cid,))
