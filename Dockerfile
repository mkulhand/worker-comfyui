# Build argument for base image selection - use PyTorch image with CUDA 12.8
ARG BASE_IMAGE=pytorch/pytorch:2.8.0-cuda12.8-cudnn9-runtime

# Stage 1: Base image with common dependencies
FROM ${BASE_IMAGE} AS base

# Build arguments for this stage with sensible defaults for standalone builds
ARG COMFYUI_VERSION=latest
ARG CUDA_VERSION_FOR_COMFY=12.8
ARG ENABLE_PYTORCH_UPGRADE=false
ARG PYTORCH_INDEX_URL

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1
# Speed up some cmake builds
ENV CMAKE_BUILD_PARALLEL_LEVEL=8

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    git \
    wget \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    libavfilter-dev \
    libgomp1 \
    ffmpeg \
    g++ \
    gcc \
    make \
    cmake \
    build-essential \
    ninja-build \
    nvidia-cuda-toolkit \
 && ln -sf /usr/bin/python3 /usr/bin/python

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install uv (latest) using official installer and create isolated venv
RUN wget -qO- https://astral.sh/uv/install.sh | sh \
    && ln -s /root/.local/bin/uv /usr/local/bin/uv \
    && ln -s /root/.local/bin/uvx /usr/local/bin/uvx \
    && uv venv /opt/venv --python $(which python)

# Use the virtual environment for all subsequent commands
ENV PATH="/opt/venv/bin:${PATH}"

# Install comfy-cli + dependencies needed by it to install ComfyUI
RUN uv pip install comfy-cli pip setuptools wheel

# Install ComfyUI
RUN if [ -n "${CUDA_VERSION_FOR_COMFY}" ]; then \
      /usr/bin/yes | comfy --workspace /comfyui install --version "${COMFYUI_VERSION}" --cuda-version "${CUDA_VERSION_FOR_COMFY}" --nvidia; \
    else \
      /usr/bin/yes | comfy --workspace /comfyui install --version "${COMFYUI_VERSION}" --nvidia; \
    fi

# Upgrade PyTorch if needed (skip since we're already using PyTorch 2.8.0 with CUDA 12.8)
# RUN if [ "$ENABLE_PYTORCH_UPGRADE" = "true" ]; then \
#       uv pip install --force-reinstall torch torchvision torchaudio --index-url ${PYTORCH_INDEX_URL}; \
#     fi

# Change working directory to ComfyUI
WORKDIR /comfyui

ARG MODEL_TYPE

# Clone and install custom node for WAN
RUN case "${MODEL_TYPE}" in \
    wan*) \
        rm -rf custom_nodes/* && \
        cd custom_nodes && \
        git clone https://github.com/ltdrdata/ComfyUI-Manager && \
        git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
        git clone https://github.com/kijai/ComfyUI-KJNodes && \
        git clone https://github.com/cubiq/ComfyUI_essentials && \
        git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation && \
        git clone https://github.com/pollockjj/ComfyUI-MultiGPU && \
        git clone https://github.com/asagi4/ComfyUI-Adaptive-Guidance && \
        git clone https://github.com/city96/ComfyUI-GGUF && \
        git clone https://github.com/kijai/ComfyUI-WanVideoWrapper && \
        git clone https://github.com/rgthree/rgthree-comfy.git && \
        git clone https://github.com/ClownsharkBatwing/RES4LYF && \
        uv pip install -r ComfyUI-Manager/requirements.txt && \
        uv pip install -r ComfyUI-VideoHelperSuite/requirements.txt && \
        uv pip install -r ComfyUI-KJNodes/requirements.txt && \
        uv pip install -r ComfyUI_essentials/requirements.txt && \
        uv pip install -r ComfyUI-Frame-Interpolation/requirements-no-cupy.txt && \
        uv pip install -r ComfyUI-GGUF/requirements.txt && \
        uv pip install -r ComfyUI-WanVideoWrapper/requirements.txt && \
        uv pip install -r RES4LYF/requirements.txt \
        ;; \
    *) \
        echo "Skipping wan specific custom nodes installation" \
        ;; \
  esac

# Additional pip packages needed by custom WAN nodes
RUN case "${MODEL_TYPE}" in \
    wan*) \
        echo "Installing onnx for wan model type" && \
        uv pip install onnx onnxruntime sageattention==1.0.6 \
        ;; \
    *) \
        echo "Skipping onnx installation for model type: ${MODEL_TYPE}" \
        ;; \
  esac

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Go back to the root
WORKDIR /

# Install Python runtime dependencies for the handler
RUN uv pip install runpod requests websocket-client

# Add application code and scripts
ADD src/start.sh handler.py test_input.json ./
RUN chmod +x /start.sh

# Add script to install custom nodes
COPY scripts/comfy-node-install.sh /usr/local/bin/comfy-node-install
RUN chmod +x /usr/local/bin/comfy-node-install

# Prevent pip from asking for confirmation during uninstall steps in custom nodes
ENV PIP_NO_INPUT=1

# Copy helper script to switch Manager network mode at container start
COPY scripts/comfy-manager-set-mode.sh /usr/local/bin/comfy-manager-set-mode
RUN chmod +x /usr/local/bin/comfy-manager-set-mode

# Set the default command to run when starting the container
CMD ["/start.sh"]

# Stage 2: Download models
FROM base AS downloader

ARG HUGGINGFACE_ACCESS_TOKEN
ARG MODEL_TYPE

# Change working directory to ComfyUI
WORKDIR /comfyui

# Create necessary directories upfront
RUN mkdir -p models/checkpoints models/vae models/unet models/clip

# Download checkpoints/vae/unet/clip models to include in image based on model type

# WAN
RUN if [ "$MODEL_TYPE" = "wan2.1-i2v720" ]; then \
      wget -q -O models/diffusion_models/wan2.1-i2v-14b-720p-Q8_0.gguf https://huggingface.co/city96/Wan2.1-I2V-14B-720P-gguf/resolve/main/wan2.1-i2v-14b-720p-Q8_0.gguf; \
    fi

RUN if [ "$MODEL_TYPE" = "wan2.1-i2v480" ]; then \
      wget -q -O models/diffusion_models/wan2.1-i2v-14b-480p-Q8_0.gguf https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q8_0.gguf; \
    fi

RUN if [ "$MODEL_TYPE" = "wan2.1-t2v" ]; then \
    wget -q -O models/diffusion_models/wan2.1-T2V-14b-Q8_0.gguf https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-T2V-14b-Q8_0.gguf; \
  fi

  RUN case "${MODEL_TYPE}" in \
  wan*) \
    #   wget -q -O models/text_encoders/umt5_xxl_fp16.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors && \
      wget -q -O models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors && \
      wget -q -O models/clip_vision/clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors && \
      wget -q -O models/vae/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors \
      ;; \
  *) \
      echo "Skipping wan specific model downloads" \
      ;; \
esac

# Regular
RUN if [ "$MODEL_TYPE" = "sdxl" ]; then \
      wget -q -O models/checkpoints/sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors && \
      wget -q -O models/vae/sdxl_vae.safetensors https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors && \
      wget -q -O models/vae/sdxl-vae-fp16-fix.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors; \
    fi

RUN if [ "$MODEL_TYPE" = "sd3" ]; then \
      wget -q --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O models/checkpoints/sd3_medium_incl_clips_t5xxlfp8.safetensors https://huggingface.co/stabilityai/stable-diffusion-3-medium/resolve/main/sd3_medium_incl_clips_t5xxlfp8.safetensors; \
    fi

RUN if [ "$MODEL_TYPE" = "flux1-schnell" ]; then \
      wget -q --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O models/unet/flux1-schnell.safetensors https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.safetensors && \
      wget -q -O models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
      wget -q -O models/clip/t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors && \
      wget -q --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O models/vae/ae.safetensors https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors; \
    fi

RUN if [ "$MODEL_TYPE" = "flux1-dev" ]; then \
      wget -q --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O models/unet/flux1-dev.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors && \
      wget -q -O models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
      wget -q -O models/clip/t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors && \
      wget -q --header="Authorization: Bearer ${HUGGINGFACE_ACCESS_TOKEN}" -O models/vae/ae.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors; \
    fi

RUN if [ "$MODEL_TYPE" = "flux1-dev-fp8" ]; then \
      wget -q -O models/checkpoints/flux1-dev-fp8.safetensors https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors; \
    fi

# Stage 3: Final image
FROM base AS final

# Copy models from stage 2 to the final image
COPY --from=downloader /comfyui/models /comfyui/models