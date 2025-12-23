import io
import torch
from fastapi import FastAPI, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from diffusers import QwenImageLayeredPipeline
from PIL import Image

app = FastAPI(title="Qwen-Image-Layered API")

device = "cuda"
dtype = torch.bfloat16

# Load the pipeline once at startup to avoid re-initialization per request.
pipe = QwenImageLayeredPipeline.from_pretrained("Qwen/Qwen-Image-Layered")
pipe = pipe.to(device, dtype=dtype)
pipe.set_progress_bar_config(disable=None)


@app.get("/health")
async def health() -> JSONResponse:
    return JSONResponse({"status": "ok"})


@app.post("/decompose")
async def decompose(file: UploadFile) -> JSONResponse:
    try:
        raw = await file.read()
        image = Image.open(io.BytesIO(raw)).convert("RGBA")
    except Exception as exc:  # pragma: no cover - defensive guard
        raise HTTPException(status_code=400, detail=f"Invalid image: {exc}") from exc

    inputs = dict(
        image=image,
        generator=torch.Generator(device=device).manual_seed(777),
        true_cfg_scale=4.0,
        negative_prompt=" ",
        num_inference_steps=50,
        num_images_per_prompt=1,
        layers=4,
        resolution=640,
        cfg_normalize=True,
        use_en_prompt=True,
    )

    with torch.inference_mode():
        output = pipe(**inputs).images[0]

    # Return a minimal response; persist or encode images in a real service.
    return JSONResponse({"layers": len(output), "message": "Decomposition complete"})
