from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from services.image_service import ImageService

router = APIRouter()
image_service = ImageService()


class ImageBody(BaseModel):
    prompt: str
    aspect_ratio: str = "1:1"
    model: str = "ultra"
    mode: str = "normal"   # normal | variation | upscale


@router.post("/generate/image")
def generate_image(body: ImageBody):
    try:
        img_b64 = image_service.generate(
            prompt=body.prompt,
            aspect_ratio=body.aspect_ratio,
            model=body.model,
            mode=body.mode,
        )

        return {"image_base64": img_b64}

    except Exception as e:
        print("❌ Image Router Error:", e)
        raise HTTPException(
            status_code=500,
            detail="Image generation failed"
        )
