#!/bin/bash

# Configuration
IMAGE_NAME="arch-opencode-base"
DOCKERFILE="$HOME/Docker/arch-opencode/Dockerfile"

LOCAL_AUTH_FILE="$HOME/.local/share/opencode/auth.json"

# Function to handle building
build_image() {
    echo "🔨 Building image from $DOCKERFILE..."
    
    if [ -z "$GH_TOKEN" ]; then
        echo "❌ Error: GH_TOKEN is not set. Cannot build."
        exit 1
    fi

    docker build -t $IMAGE_NAME -f $DOCKERFILE .
    
    if [ $? -ne 0 ]; then
        echo "❌ Docker build failed. Exiting."
        exit 1
    fi
    echo "✅ Build successful."
}

# ---------------------------------------------------------
# 0. Check for "rebuild" parameter
# ---------------------------------------------------------
if [ "$1" == "rebuild" ]; then
    echo "Force rebuild requested..."
    build_image
    exit 0
fi

# ---------------------------------------------------------
# 1. Auto-Build Image (if missing)
# ---------------------------------------------------------
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "⚠️  Image '$IMAGE_NAME' not found locally."
    build_image
fi
