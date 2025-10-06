#!/bin/bash

echo "Downloading models files for WAN 480"

mkdir -p models_local/wan2.1-i2v480/checkpoints models_local/wan2.1-i2v480/diffusion_models models_local/wan2.1-i2v480/clip_vision models_local/wan2.1-i2v480/text_encoders models_local/wan2.1-i2v480/vae

# Checkpoints
wget -q -O models_local/wan2.1-i2v480/diffusion_models_local/wan2.1-i2v480/wan2.1-i2v-14b-480p-Q8_0.gguf https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q8_0.gguf
wget -q -O models_local/wan2.1-i2v480/checkpoints/aniWan2.1_i2v480p_new.safetensors https://civitai.com/api/download/models_local/wan2.1-i2v480/1852433?type=Model&format=SafeTensor&size=pruned&fp=fp8

# Additional models
# wget -q -O models_local/wan2.1-i2v480/text_encoders/umt5_xxl_fp16.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors
# wget -q -O models_local/wan2.1-i2v480/clip_vision/clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
wget -q -O models_local/wan2.1-i2v480/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors
wget -q -O models_local/wan2.1-i2v480/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
wget -q -O models_local/wan2.1-i2v480/clip_vision/wan21NSFWClipVisionH_v10.safetensors https://huggingface.co/ricecake/wan21NSFWClipVisionH_v10/resolve/main/wan21NSFWClipVisionH_v10.safetensors