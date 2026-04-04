from groq import Groq
import os
from dotenv import load_dotenv

load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

SYSTEM_PROMPT = """You are an expert agricultural advisor for Sri Lankan farmers.
You have deep knowledge about:
- Crop cultivation (rice, vegetables, fruits, tea, rubber)
- Fertilizer types and application rates
- Pest and disease management
- Irrigation techniques
- Harvest timing and post-harvest handling
- Farm financial management and profit optimization

Always give practical, actionable advice for small-scale farmers.
Use simple language. Mention costs in Sri Lankan Rupees (Rs.) when relevant."""

def ask_groq(question: str, crop_context: str = "") -> str:
    try:
        context = ""
        if crop_context:
            context = f"\n\nFarmer's crop context: {crop_context}"

        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {
                    "role": "system",
                    "content": SYSTEM_PROMPT + context
                },
                {
                    "role": "user",
                    "content": question
                }
            ],
            temperature=0.7,
            max_tokens=1024,
        )
        return response.choices[0].message.content

    except Exception as e:
        raise Exception(f"Groq error: {str(e)}")