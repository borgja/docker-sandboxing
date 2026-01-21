#!/bin/bash
# sandbox.sh

IMAGE_NAME="arch-opencode-base"
CONTAINER_NAME="$(basename "$PWD")-sandbox"

if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🔄 Container '$CONTAINER_NAME' is already running."
    echo "🔗 Connecting to OpenCode..."
    exec docker exec -it $CONTAINER_NAME /bin/bash
else
    echo "🔄 Container '$CONTAINER_NAME' starting..."
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        --hostname sandbox \
        --label "com.docker.sandbox.workspace=$PWD" \
        -v "$PWD:/home/<username>/project" \
        -v "$HOME/.ssh:/home/<username>/.ssh:ro" \
        -v "$HOME/.config/git/config":"$HOME/.config/git/config":ro \
        -v "$HOME/.config/opencode":"$HOME/.config/opencode":ro \
        "$IMAGE_NAME" /bin/bash
    echo "🗑️  Removing old container..."
fi
