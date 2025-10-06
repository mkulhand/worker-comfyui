#!/bin/bash

echo "Downloading models files for WAN 480"

mkdir -p models/checkpoints models/diffusion_models models/clip_vision models/text_encoders models/vae

# Checkpoints
wget -q -O models/diffusion_models/wan2.1-i2v-14b-480p-Q8_0.gguf https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q8_0.gguf
wget -q -O models/checkpoints/aniWan2.1_i2v480p_new.safetensors https://civitai.com/api/download/models/1852433?type=Model&format=SafeTensor&size=pruned&fp=fp8

# Additional models
# wget -q -O models/text_encoders/umt5_xxl_fp16.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors
# wget -q -O models/clip_vision/clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
wget -q -O models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
wget -q -O models/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
wget -q -O models/clip_vision/wan21NSFWClipVisionH_v10.safetensors https://huggingface.co/ricecake/wan21NSFWClipVisionH_v10/resolve/main/wan21NSFWClipVisionH_v10.safetensors