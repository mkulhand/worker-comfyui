#!/bin/bash

echo "Downloading models files for WAN 480"

mkdir -p models_local/wan2.1-i2v480/loras models_local/wan2.1-i2v480/checkpoints models_local/wan2.1-i2v480/diffusion_models models_local/wan2.1-i2v480/clip_vision models_local/wan2.1-i2v480/text_encoders models_local/wan2.1-i2v480/vae

# Loras
aws s3 cp --recursive --region eu-ro-1 --endpoint-url https://s3api-eu-ro-1.runpod.io/ s3://r2lhnb51y4/loras ./models_local/wan2.1-i2v480/loras

# Checkpoints
wget --progress=bar:force:noscroll -O models_local/wan2.1-i2v480/diffusion_models/wan2.1-i2v-14b-480p-Q8_0.gguf https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q8_0.gguf
wget --progress=bar:force:noscroll -O models_local/wan2.1-i2v480/checkpoints/aniWan2.1_i2v480p_new.safetensors https://civitai.com/api/download/models/1852433?type=Model&format=SafeTensor&size=pruned&fp=fp8

# Additional models
wget --progress=bar:force:noscroll -O models_local/wan2.1-i2v480/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
wget --progress=bar:force:noscroll -O models_local/wan2.1-i2v480/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
wget --progress=bar:force:noscroll -O models_local/wan2.1-i2v480/clip_vision/wan21NSFWClipVisionH_v10.safetensors https://huggingface.co/ricecake/wan21NSFWClipVisionH_v10/resolve/main/wan21NSFWClipVisionH_v10.safetensors
