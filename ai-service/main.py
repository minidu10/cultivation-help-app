from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import chat
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="Cultivation Help AI Service",
    description="AI-powered crop advisory microservice",
    version="1.0.0"
)

# Allow requests from React and Spring Boot
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
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