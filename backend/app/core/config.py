"""Settings read from the environment, with development defaults."""
from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[2]


@dataclass
class Settings:
    app_name: str = "MSW Community API"
    version: str = "0.2.0"
    db_path: Path = field(default_factory=lambda: Path(os.environ.get("MSW_DB", BACKEND_DIR / "msw.db")))
    seed_path: Path = field(default_factory=lambda: Path(os.environ.get("MSW_SEED", BACKEND_DIR / "seed.json")))
    cors_origins: list[str] = field(default_factory=lambda: os.environ.get("MSW_CORS_ORIGINS", "*").split(","))


settings = Settings()
