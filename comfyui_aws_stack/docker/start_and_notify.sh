#!/bin/bash

# Slack通知
if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"✅ ComfyUI 起動完了: \`$(hostname)\`\"}" \
    "$SLACK_WEBHOOK_URL"
fi

# ComfyUI起動
source /home/user/opt/ComfyUI/.venv/bin/activate
exec python /home/user/opt/ComfyUI/main.py --listen 0.0.0.0 --port 8181 --output-directory /home/user/opt/ComfyUI/output/
