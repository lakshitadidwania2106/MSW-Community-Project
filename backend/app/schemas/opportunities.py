from __future__ import annotations

from typing import Optional

from pydantic import BaseModel


class OpportunityPatch(BaseModel):
    live: Optional[bool] = None


class ApplyIn(BaseModel):
    link: str = ""
    note: str = ""
