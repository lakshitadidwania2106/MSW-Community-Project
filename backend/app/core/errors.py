"""Domain errors raised by services. `main.py` turns them into JSON responses."""
from __future__ import annotations


class AppError(Exception):
    status_code = 400
    default = "Bad request"

    def __init__(self, detail: str | None = None) -> None:
        super().__init__(detail or self.default)
        self.detail = detail or self.default


class BadRequest(AppError):
    status_code = 400


class Unauthorized(AppError):
    status_code = 401
    default = "Not signed in"


class Forbidden(AppError):
    status_code = 403
    default = "Not allowed"


class NotFound(AppError):
    status_code = 404
    default = "Not Found"
