#!/bin/sh
set -e

echo "--- Slack Notifier Test ---"
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "ERROR: SLACK_WEBHOOK_URL environment variable is not set."
    exit 1
else
    echo "SLACK_WEBHOOK_URL is set. Sending test message..."
    # Use curl to send a simple JSON payload
    curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Hello World from local Docker container!"}' \
    "$SLACK_WEBHOOK_URL"
    echo "\nTest message sent. Check your Slack channel."
fi
echo "--- Test Complete ---"
