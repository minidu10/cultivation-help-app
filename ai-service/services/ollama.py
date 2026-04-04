import requests

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "phi3.5"

SYSTEM_PROMPT = """You are an expert agricultural advisor for Sri Lankan farmers.
Give practical farming advice about crops, fertilizers, pests, irrigation and finances.
Use simple language. Mention costs in Sri Lankan Rupees (Rs.) when relevant."""

def ask_ollama(question: str, crop_context: str = "") -> str:
    try:
        context = ""
        if crop_context:
            context = f"\nFarmer context: {crop_context}"

        prompt = f"{SYSTEM_PROMPT}{context}\n\nQuestion: {question}\n\nAnswer:"

        response = requests.post(OLLAMA_URL, json={
            "model": OLLAMA_MODEL,
            "prompt": prompt,
            "stream": False
        }, timeout=60)

        if response.status_code == 200:
            return response.json().get("response", "No response from Ollama")
        else:
            raise Exception(f"Ollama returned status {response.status_code}")

    except requests.exceptions.ConnectionError:
        raise Exception("Ollama is not running. Start it with: ollama serve")
    except Exception as e:
        raise Exception(f"Ollama error: {str(e)}")