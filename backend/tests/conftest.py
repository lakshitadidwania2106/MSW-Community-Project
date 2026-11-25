import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import create_app


@pytest.fixture()
def client(tmp_path, monkeypatch):
    """A fresh, seeded database for every test."""
    monkeypatch.setattr(settings, "db_path", tmp_path / "test.db")
    with TestClient(create_app()) as c:
        yield c


def as_(user: str) -> dict[str, str]:
    return {"X-User": user}


COMPANY, INVESTOR, ADMIN, STUDENT, COLLEGE = "lumen-labs", "nikhil-varma", "msw-admin", "aanya-sharma", "iit-bombay-e-cell"
