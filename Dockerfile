# Start from the latest official Ubuntu release
FROM archlinux:latest

# Install core tools
RUN pacman -Syu --noconfirm --needed \
    wget \
    vim \
    ca-certificates \
    curl \
    unzip \
    gnupg \
    sudo \
    jq \
    openssh \
    github-cli \
    && rm -rf /var/cache/pacman/pkg/*


# 1. Create the user
# -u: Sets the UID to match your host
# -d: Sets the home directory path
# -m: Creates the home directory (better than -M if you need a skeleton home)
# -s: Sets the default shell (Bash is standard in the archlinux image)
RUN useradd -u 9999 -m -d /home/<username> -s /bin/bash <username>

# 2. Add to sudoers if you need root privileges later
RUN echo "<username> ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set the existing non-root '<username>' user as the default user
USER <username>
WORKDIR /home/<username>

# Create .ssh and populate known_hosts
# No sudo needed here because you are '<username>' and it's your home directory
RUN mkdir -p /home/<username>/.ssh \
    && chmod 700 /home/<username>/.ssh \
    && ssh-keyscan github.com >> /home/<username>/.ssh/known_hosts \
    && chmod 644 /home/<username>/.ssh/known_hosts

# Opencode directories
RUN mkdir -p /home/<username>/.local/share/opencode \
    && mkdir -p /home/<username>/.config/opencode


# Install OpenCode AI
RUN curl -fsSL https://opencode.ai/install | bash
