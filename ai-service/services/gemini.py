import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

model = genai.GenerativeModel("gemini-2.0-flash")

SYSTEM_PROMPT = """
You are an expert agricultural advisor for Sri Lankan farmers.
You have deep knowledge about:
- Crop cultivation (rice, vegetables, fruits, tea, rubber)
- Fertilizer types and application rates
- Pest and disease management
- Irrigation techniques
- Harvest timing and post-harvest handling
- Farm financial management and profit optimization

Always give practical, actionable advice suitable for small-scale farmers.
Keep responses clear and concise. Use simple language.
When discussing costs, use Sri Lankan Rupees (Rs.).
"""

def ask_gemini(question: str, crop_context: str = "") -> str:
    try:
        context = ""
        if crop_context:
            context = f"\n\nFarmer's crop context: {crop_context}"

        prompt = f"{SYSTEM_PROMPT}{context}\n\nFarmer's question: {question}"

        response = model.generate_content(prompt)
        return response.text

    except Exception as e:
        raise Exception(f"Gemini error: {str(e)}")