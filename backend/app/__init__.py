"""MSW Community API package.

`uvicorn app.main:app` is the entry point. `uvicorn app:app` also works,
because the FastAPI instance is exposed lazily here.
"""


def __getattr__(name: str):
    if name == "app":
        from app.main import app

        return app
    raise AttributeError(name)
