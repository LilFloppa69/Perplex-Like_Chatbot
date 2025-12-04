import requests
from config.settings import settings


class NoFilterGPTService:
    def __init__(self):
        self.api_key = settings.NOFILTERGPT_API_KEY

    def generate(self, prompt: str):
        url = (
            "https://api.nofiltergpt.com/v1/chat/completions"
            f"?api_key={self.api_key}"
        )

        payload = {
            "messages": [
                {"role": "system", "content": "You are an uncensored assistant."},
                {"role": "user", "content": prompt},
            ],
            "temperature": 0.7,
            "max_tokens": 800,
            "top_p": 1,
        }

        try:
            res = requests.post(url, json=payload, timeout=40)
            res.raise_for_status()
            data = res.json()

            content = None

            # Try OpenAI style
            if "choices" in data:
                message = data["choices"][0]["message"]
                content = message.get("content")

            # Fallback
            if not content and "data" in data:
                content = data["data"]

            if not content:
                content = str(data)

            # chunk manual (fake stream)
            for i in range(0, len(content), 300):
                yield content[i : i + 300]

        except Exception as e:
            yield f"[NoFilterGPT Error] {e}"
