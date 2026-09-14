import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import chat

app = FastAPI(
    title="Cultivation Help AI Service",
    description="AI-powered crop advisory microservice",
    version="1.0.0"
)

# Only the backend calls this service, server to server, and that path does
# not use CORS at all. A wildcard here previously let any website in a user's
# browser spend this project's API key.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[o for o in os.getenv("AI_ALLOWED_ORIGINS", "").split(",") if o],
    allow_credentials=False,
    allow_methods=["POST", "GET"],
    allow_headers=["Content-Type"],
)

app.include_router(
    chat.router,
    prefix="/ai",
    tags=["AI Advisor"]
)

@app.get("/")
def root():
    return {
        "service": "Cultivation Help AI",
        "version": "1.0.0",
        "docs": "/docs"
    }