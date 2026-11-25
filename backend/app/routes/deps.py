"""Shorthand dependency types for route signatures."""
import sqlite3
from typing import Annotated

from fastapi import Depends

from app.core.database import get_db
from app.core.security import current_user, require_admin

DB = Annotated[sqlite3.Connection, Depends(get_db)]
User = Annotated[sqlite3.Row, Depends(current_user)]
Admin = Annotated[sqlite3.Row, Depends(require_admin)]
