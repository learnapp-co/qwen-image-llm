#!/usr/bin/env bash
set -euo pipefail

# Preparation script for GPU hosts (e.g., AWS DLAMI PyTorch 2.9 Ubuntu 24.04)
# Installs Docker + NVIDIA Container Toolkit and performs a quick GPU check.
# Run as a user with sudo privileges. After completion, re-login so the docker
# group membership applies.

if [[ "$(id -u)" -eq 0 ]]; then
  echo "Please run as a non-root user with sudo privileges."
  exit 1
fi

echo "[prep] Updating apt sources..."
sudo apt-get update

echo "[prep] Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "[prep] Installing NVIDIA Container Toolkit..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "[prep] Verifying GPU visibility in containers..."
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi

echo "[prep] Done. Log out and back in (or run 'newgrp docker') before running Docker without sudo."

