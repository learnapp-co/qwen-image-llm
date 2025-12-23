# PyTorch 2.9.0 + CUDA 12.4 + cuDNN 9 runtime base
FROM pytorch/pytorch:2.9.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive \
    HF_HOME=/opt/hf-cache \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${HF_HOME}

WORKDIR /app

# Torch is preinstalled in the base image; install the remaining deps.
RUN pip install --upgrade pip && \
    pip install \
      git+https://github.com/huggingface/diffusers \
      "transformers>=4.51.3" \
      pillow \
      python-pptx \
      fastapi uvicorn[standard]

# Copy application code.
COPY app/ /app/

VOLUME ["/opt/hf-cache"]

ENTRYPOINT ["python", "-m", "uvicorn", "serve:app", "--host", "0.0.0.0", "--port", "8000"]

