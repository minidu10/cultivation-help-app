from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.groq_service import ask_groq
from services.ollama import ask_ollama
import os

router = APIRouter()

class ChatRequest(BaseModel):
    question: str
    crop_context: str = ""
    mode: str = "groq"  # "groq" or "ollama"

class ChatResponse(BaseModel):
    answer: str
    mode: str

class InsightRequest(BaseModel):
    crop_name: str
    total_expenses: float
    total_revenue: float
    net_profit: float
    status: str

@router.post("/ask", response_model=ChatResponse)
async def ask_advisor(request: ChatRequest):
    if not request.question.strip():
        raise HTTPException(
            status_code=400,
            detail="Question cannot be empty"
        )

    mode = os.getenv("AI_MODE", "groq")

    try:
        if mode == "groq":
            answer = ask_groq(request.question, request.crop_context)
        elif mode == "ollama":
            answer = ask_ollama(request.question, request.crop_context)
        else:
            answer = ask_groq(request.question, request.crop_context)

        return ChatResponse(answer=answer, mode=mode)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI service error: {str(e)}"
        )
@router.post("/insights")
async def get_crop_insights(request: InsightRequest):
    question = f"""
    Analyze this crop performance and give 3 specific recommendations:

    Crop: {request.crop_name}
    Status: {request.status}
    Total Expenses: Rs. {request.total_expenses:,.2f}
    Total Revenue: Rs. {request.total_revenue:,.2f}
    Net Profit: Rs. {request.net_profit:,.2f}

    Give:
    1. One sentence summary of performance
    2. Top 3 actionable recommendations to improve profitability
    3. One risk to watch out for
    """

    try:
        answer = ask_groq(question)
        return {"insights": answer, "crop": request.crop_name}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
@router.get("/health")
async def health():
    return {
        "status": "UP",
        "service": "AI Advisor",
        "mode": os.getenv("AI_MODE", "groq")
    }