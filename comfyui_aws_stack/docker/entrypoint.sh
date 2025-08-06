#!/bin/bash

set -e
exec > >(tee -a /tmp/entrypoint.log) 2>&1
set -x

# --- Configuration ---
VENV_PATH="/home/user/opt/ComfyUI/.venv"
COMFYUI_PATH="/home/user/opt/ComfyUI"
MODELS_DIR="$COMFYUI_PATH/models"
OUTPUT_DIR="$COMFYUI_PATH/output"
PORT=8181

# --- Slack Notification Function ---
notify_slack() {
  if [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -s -X POST -H 'Content-type: application/json' --data "{\"text\":\"$1\"}" "$SLACK_WEBHOOK_URL" > /dev/null
  fi
}

# --- Ensure Directory Exists ---
mkdir -p "$MODELS_DIR/checkpoints"
mkdir -p "$OUTPUT_DIR"

# --- Model Download Function ---
download_model_if_not_exists() {
  local model_path="$1"
  local download_url="$2"
  if [ ! -f "$model_path" ]; then
    notify_slack "📥 Model not found. Downloading $(basename "$model_path")... ($HOSTNAME)"
    wget -O "$model_path" "$download_url"
    notify_slack "✅ Download complete: $(basename "$model_path") ($HOSTNAME)"
  else
    echo "Model already exists: $(basename "$model_path")"
  fi
}

# --- Main Execution ---
notify_slack "🚀 ComfyUI is starting... ($HOSTNAME)"

# Activate Python environment
if [ ! -f "$VENV_PATH/bin/activate" ]; then
  echo "❌ Python venv ($VENV_PATH) not found!"
  notify_slack "❌ Python venv ($VENV_PATH) not found on $HOSTNAME"
  exit 1
fi
source "$VENV_PATH/bin/activate"

# Download additional models to the EFS volume
# Example: Add RealVisXL V5.0 if it doesn't exist
download_model_if_not_exists \
  "$MODELS_DIR/checkpoints/RealVisXL_V5.0_fp16.safetensors" \
  "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors"

# Add more models here as needed...
# download_model_if_not_exists \
#   "$MODELS_DIR/loras/your_lora.safetensors" \
#   "https://example.com/your_lora.safetensors"


# Start ComfyUI
notify_slack "✅ All checks passed. Launching ComfyUI on port $PORT... ($HOSTNAME)"

exec python "$COMFYUI_PATH/main.py" \
  --listen 0.0.0.0 \
  --port $PORT \
  --output-directory "$OUTPUT_DIR" \
  --multi-user
