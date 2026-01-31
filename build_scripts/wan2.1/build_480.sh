#!/bin/bash

docker build --platform linux/amd64 \
  --build-arg COMFYUI_VERSION=latest \
  --build-arg CUDA_VERSION_FOR_COMFY= \
  --build-arg ENABLE_PYTORCH_UPGRADE=false \
  --build-arg PYTORCH_INDEX_URL= \
  --build-arg MODEL_TYPE=wan2.1-i2v480 \
  -t mkulhand/comfy-image .