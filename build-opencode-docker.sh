#!/bin/bash   # Shebang: specify interpreter (Bash)

# Configuration
# Image name used for both building and running containers
IMAGE_NAME="arch-opencode-base"

# Path to Dockerfile
# This points to Dockerfile in the same directory as this script
# If your Dockerfile is elsewhere, update path accordingly (e.g., "$HOME/path/to/Dockerfile")
DOCKERFILE="$(dirname "$0")/Dockerfile"

# Path to local OpenCode auth file
# Currently unused - reserved for future authentication purposes
LOCAL_AUTH_FILE="$HOME/.local/share/opencode/auth.json"

# Function to handle building the Docker image
# - Validates GH_TOKEN is set (required for some build steps)
# - Runs docker build with error checking
# - Returns non-zero exit code on failure
build_image() {
    echo "🔨 Building image from $DOCKERFILE..."

    # Check if GH_TOKEN environment variable is set and non-empty
    # -z: Test if string is empty
    # This is required for GitHub CLI operations during build
    if [ -z "$GH_TOKEN" ]; then
        echo "❌ Error: GH_TOKEN is not set. Cannot build."
        echo "   Set with: export GH_TOKEN=your_github_token"
        exit 1
    fi

    # Build Docker image
    # -t: Tag the image with IMAGE_NAME
    # -f: Specify Dockerfile path
    # .: Use current directory as build context
    docker build -t $IMAGE_NAME -f $DOCKERFILE .

    # Check exit status of previous command
    # $?: Exit code of last command (0 = success)
    if [ $? -ne 0 ]; then
        echo "❌ Docker build failed. Exiting."
        exit 1
    fi
    echo "✅ Build successful."
}

# ---------------------------------------------------------
# 0. Check for "rebuild" parameter
# ---------------------------------------------------------
# Usage: ./build-opencode-docker.sh rebuild
# Forces a rebuild even if image already exists
# [ "$1" == "rebuild" ]: Check first command-line argument
if [ "$1" == "rebuild" ]; then
    echo "Force rebuild requested..."
    build_image
    exit 0   # Exit after rebuild (don't continue to auto-build check)
fi

# ---------------------------------------------------------
# 1. Auto-Build Image (if missing)
# ---------------------------------------------------------
# Check if image exists locally
# docker images -q: Quiet mode, only show image IDs
# 2> /dev/null: Redirect stderr to null (suppress warnings)
# [[ ... == "" ]]: Test if output is empty (image not found)
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "⚠️  Image '$IMAGE_NAME' not found locally."
    build_image   # Build image if not found
fi
# If image exists, script exits silently (no action needed)
