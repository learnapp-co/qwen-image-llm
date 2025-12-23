# Qwen-Image-Layered Dockerized API

Docker packaging for `Qwen/Qwen-Image-Layered` with a FastAPI wrapper, targeting GPU nodes (e.g., Deep Learning OSS Nvidia Driver AMI GPU PyTorch 2.9 on Ubuntu 24.04).

## Prerequisites (host)
- Docker and NVIDIA Container Toolkit installed.
- GPU visible via `nvidia-smi`.

## Build
```
docker build -t qwen-image-layered .
```

## Run (standalone)
```
docker run --rm -it \
  --gpus all \
  -p 8000:8000 \
  -e HF_HOME=/opt/hf-cache \
  -v /data/hf-cache:/opt/hf-cache \
  qwen-image-layered
```
- Adjust `/data/hf-cache` to a persistent host path. Add `-e HF_TOKEN=...` if you need a private HF token.

## Run (docker-compose)
```
docker compose up --build
```

## Test
```
curl -X POST -F "file=@/path/to/rgba.png" http://localhost:8000/decompose
```

## API
- `GET /health` → basic health check.
- `POST /decompose` → uploads an RGBA image; returns layer count. Extend to return images/base64/URLs as needed.

## Notes
- Pipeline uses `torch.bfloat16` on CUDA to save VRAM.
- Tweak `layers`, `resolution`, and `num_inference_steps` in `serve.py` to balance quality vs. speed/memory.

