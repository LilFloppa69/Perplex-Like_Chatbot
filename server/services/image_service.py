import base64
import requests
from config.settings import settings


class ImageService:

    def generate(
        self,
        prompt: str,
        aspect_ratio: str,
        model: str,
        mode: str = "normal",
    ) -> str:
        
        # ===== Modify prompt based on mode =====
        if mode == "variation":
            prompt += " (slightly different variation, creative remix)"
        elif mode == "upscale":
            prompt += " (same image but higher resolution, more details, 4k quality)"

        # Stability endpoint
        url = f"https://api.stability.ai/v2beta/stable-image/generate/{model}"

        headers = {
            "authorization": f"Bearer {settings.STABILITY_API_KEY}",
            "accept": "image/*"
        }

        data = {
            "prompt": prompt,
            "output_format": "webp",
            "aspect_ratio": aspect_ratio,
        }

        try:
            resp = requests.post(
                url,
                headers=headers,
                data=data,
                files={"none": ""}
            )
        except Exception as e:
            print("❌ STABILITY REQUEST ERROR:", e)
            raise Exception("Image API request failed")

        # ===== Handle API Error =====
        if resp.status_code != 200:
            print("❌ STABILITY ERROR:", resp.text)
            raise Exception("Image generation failed")

        # ===== Convert Image to Base64 =====
        img_bytes = resp.content
        img_base64 = base64.b64encode(img_bytes).decode("utf-8")

        return img_base64
