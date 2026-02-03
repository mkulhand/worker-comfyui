#!/bin/bash
set -e

# Make sure the key is added to ssh-agent
ssh-add ~/.ssh/ssh_github

DOCKER_BUILDKIT=1 docker build \
  --ssh default \
  --platform linux/amd64 \
  --build-arg COMFYUI_VERSION=latest \
  --build-arg CUDA_VERSION_FOR_COMFY= \
  --build-arg ENABLE_PYTORCH_UPGRADE=false \
  --build-arg PYTORCH_INDEX_URL= \
  --build-arg MODEL_TYPE=wan2.2-i2v \
  -t mkulhand/comfy-image-wan2.2 .
