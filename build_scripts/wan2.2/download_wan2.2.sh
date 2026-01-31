#!/bin/bash

echo "Downloading models files for WAN 2.2 I2V"

mkdir -p models_local/wan2.2-i2v/diffusion_models models_local/wan2.2-i2v/clip_vision models_local/wan2.2-i2v/text_encoders models_local/wan2.2-i2v/vae

# Manually download both low and high checkpoints from https://civitai.com/models/2053259?modelVersionId=2477548 and put them in models_local/wan2.2/diffusion_models

# Additional models
wget -q -O models_local/wan2.2-i2v/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
wget -q -O models_local/wan2.2-i2v/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
wget -q -O models_local/wan2.2-i2v/clip_vision/clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

echo "Manually download both low and high checkpoints from https://civitai.com/models/2053259?modelVersionId=2477548 and put them in models_local/wan2.2-i2v/diffusion_models"