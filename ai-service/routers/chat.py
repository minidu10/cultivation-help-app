from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from services import advisor

router = APIRouter()


class ChatRequest(BaseModel):
    question: str
    crop_context: str = ""


class ChatResponse(BaseModel):
    answer: str
    model: str


class InsightRequest(BaseModel):
    crop_name: str
    total_expenses: float
    total_revenue: float
    net_profit: float
    status: str


@router.post("/ask", response_model=ChatResponse)
async def ask_advisor(request: ChatRequest):
    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    try:
        answer = advisor.ask(request.question, request.crop_context)
        return ChatResponse(answer=answer, model=advisor.model())
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))


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
        return {"insights": advisor.ask(question), "crop": request.crop_name}
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))


@router.get("/health")
async def health():
    return {
        "status": "UP",
        "service": "AI Advisor",
        "model": advisor.model() or None,
        # Surfaces missing configuration here rather than only on the first
        # real question a farmer asks.
        "configured": advisor.is_configured(),
    }
