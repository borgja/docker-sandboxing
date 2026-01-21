# Start from the latest Arch Linux release
FROM archlinux:latest

# Install core development tools and utilities
# -Syu: Full system upgrade (sync database + upgrade all packages)
# --noconfirm: Don't prompt for confirmation (automated build)
# --needed: Only install packages that aren't already installed
# Then: Remove pacman cache to reduce final image size
RUN pacman -Syu --noconfirm --needed \
    wget \                    # Download tool for fetching files from web
    vim \                     # Terminal text editor
    ca-certificates \         # SSL/TLS certificates for HTTPS connections
    curl \                    # Transfer data with URLs (often used for scripts)
    unzip \                   # Extract .zip archives
    gnupg \                   # GNU Privacy Guard for cryptographic operations
    sudo \                    # Allow users to execute commands as superuser
    jq \                      # Command-line JSON processor
    openssh \                 # SSH client/server for remote connections
    git \                     # Version control system
    github-cli \              # GitHub CLI tool (gh) for GitHub operations
    && rm -rf /var/cache/pacman/pkg/*    # Clean pacman package cache to reduce image size


# 1. Create the non-root user
#    RECOMMENDATION: Set <username> and <uid> to match the user who will be creating
#    the sandboxes. This simplifies ownership and permissions when using shared/bound
#    mounts between the container and host (no UID/GID mapping conflicts).
#
# -u: Set UID (REPLACE <uid> with your host user's UID, e.g., run `id -u` on host)
#     Recommended UIDs:
#     - 1000 - Standard first user UID
#     - 1001-29999 - Available range on most systems
#     - 9999 - High value, less likely to conflict
# -m: Create home directory
# -d: Set home directory path (REPLACE <username> with your actual username)
# -s: Set default shell (Bash is standard in Arch Linux)
RUN useradd -u <uid> -m -d /home/<username> -s /bin/bash <username>

# 2. Add to sudoers with passwordless sudo access
#    SECURITY NOTE: NOPASSWD is acceptable for disposable sandbox environments only
#    (REPLACE <username> with your actual username)
RUN echo "<username> ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set default user to non-root <username> for security
# (REPLACE <username> with your actual username)
USER <username>

# Set default working directory to user's home
# (REPLACE <username> with your actual username)
WORKDIR /home/<username>

# Create .ssh directory and populate known_hosts
# - mkdir -p: Create directory with parents, no error if exists
# - chmod 700: Restrict .ssh to owner-only (SSH security requirement)
# - ssh-keyscan: Add GitHub's SSH host key to known_hosts (prevents interactive prompt)
# - chmod 644: known_hosts can be read by user, but not modified by others
# No sudo needed: Running as <username>, creating in own home directory
# (REPLACE <username> with your actual username)
RUN mkdir -p /home/<username>/.ssh \
    && chmod 700 /home/<username>/.ssh \
    && ssh-keyscan github.com >> /home/<username>/.ssh/known_hosts \
    && chmod 644 /home/<username>/.ssh/known_hosts

# Create OpenCode AI directories (XDG Base Directory Specification)
# .local/share/opencode: User-specific data files
# .config/opencode: User-specific configuration files
# (REPLACE <username> with your actual username)
RUN mkdir -p /home/<username>/.local/share/opencode \
    && mkdir -p /home/<username>/.config/opencode


# Install OpenCode AI CLI tool
# -f: Fail silently on server errors
# -s: Silent mode (no progress output)
# -S: Show errors even with -s
# -L: Follow redirects if server returns 301/302
# Pipe to bash: Execute the downloaded installer script
RUN curl -fsSL https://opencode.ai/install | bash
