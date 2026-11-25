from __future__ import annotations

from typing import Any

from pydantic import BaseModel

# Events, jobs and tasks carry rich, app-defined details that are stored as JSON.
FreeForm = dict[str, Any]


class Ok(BaseModel):
    ok: bool = True


class Created(BaseModel):
    id: int
