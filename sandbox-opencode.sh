#!/bin/bash   # Shebang: specify interpreter (Bash)

# Configuration
# Image name used to start the container (must match build script's IMAGE_NAME)
IMAGE_NAME="arch-opencode-base"

# Container name based on current directory
# $(basename "$PWD"): Get current directory name
# -sandbox: Suffix to identify this as a sandbox container
# Example: If PWD is /home/user/projects/myapp, container name will be "myapp-sandbox"
CONTAINER_NAME="$(basename "$PWD")-sandbox"

# ---------------------------------------------------------
# Check if container is already running
# ---------------------------------------------------------
# docker ps: List running containers
# -q: Quiet mode (only show container IDs)
# -f name=$CONTAINER_NAME: Filter by container name
# If container is running, attach to it instead of starting new one
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "🔄 Container '$CONTAINER_NAME' is already running."
    echo "🔗 Connecting to OpenCode..."

    # exec (shell built-in): Replace current shell process with container process
    # When you exit, the entire shell session terminates (no lingering process)
    # docker exec: Run command inside existing container
    # -it: Interactive mode with TTY (required for interactive shell)
    exec docker exec -it $CONTAINER_NAME /bin/bash
else
    echo "🔄 Container '$CONTAINER_NAME' starting..."

    # Start new container with volume mounts
    # docker run: Create and start a new container
    # -it: Interactive mode with TTY
    # --rm: Automatically remove container when it exits (cleanup)
    # --name: Set container name for identification
    # --hostname: Set container hostname (visible in shell prompt as <username>@sandbox)
    #              Helps visually identify you are in the sandbox environment
    # --label: Add metadata to container (useful for filtering/managing)
    # -v: Mount host directory into container (bind mount)
    #    (REPLACE <username> with your actual username - must match Dockerfile)
    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        --hostname sandbox \
        --label "com.docker.sandbox.workspace=$PWD" \
        -v "$PWD:/home/<username>/project" \                    # Mount current directory as project folder
        -v "$HOME/.ssh:/home/<username>/.ssh:ro" \                # Mount SSH keys (read-only)
        -v "$HOME/.config/git/config":"$HOME/.config/git/config":ro \  # Mount git config (read-only)
        -v "$HOME/.config/opencode":"$HOME/.config/opencode":ro \      # Mount OpenCode config (read-only)
        "$IMAGE_NAME" /bin/bash   # Use the built image and start bash shell
    echo "🗑️  Container removed."
fi
