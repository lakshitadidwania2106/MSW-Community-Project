"""HTTP endpoints. Routes only parse input and call services."""
from fastapi import APIRouter

from app.routes import admin, auth, events, feed, health, ideas, opportunities, posts, tasks

api_router = APIRouter()
for module in (health, auth, feed, posts, events, opportunities, tasks, ideas, admin):
    api_router.include_router(module.router)
