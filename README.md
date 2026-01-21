[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/borgja/docker-sandboxing?style=social)]

# docker-sandboxing

Scripts for creating disposable Docker sandbox environments pre-configured with OpenCode AI and essential development tools.

## Overview

This repository provides scripts for spinning up isolated, disposable Docker sandboxes with OpenCode AI installed. Perfect for quickly setting up clean development environments for testing, experimentation, or running OpenCode AI in a controlled setting.

## Features

- Pre-configured Arch Linux-based Docker image with OpenCode AI CLI
- Essential development tools pre-installed: git, vim, curl, wget, jq, openssh, github-cli
- Automatic volume mounting for project files
- SSH and Git configuration sharing from host
- Automatic container cleanup on exit (disposable)
- Support for multiple concurrent sandboxes (one per directory)
- Host UID matching for seamless file permissions

## Prerequisites

- Docker installed and running
- GitHub Personal Access Token (for GitHub CLI during build)

## Quick Start

### 1. Replace Placeholders

Before building, replace the following placeholders in both `Dockerfile` and `sandbox-opencode.sh`:

| Placeholder | Where to Find | How to Get | Example |
|-------------|---------------|------------|---------|
| `<username>` | Dockerfile, sandbox-opencode.sh | Your actual username | Run `whoami` |
| `<uid>` | Dockerfile only | Your host user's UID | Run `id -u` |

**Important:** Set `<uid>` to match your host user's UID to simplify permissions when using bind mounts.

### 2. Set GitHub Token

A GitHub Personal Access Token is required for GitHub CLI operations during the build process (e.g., authenticating with GitHub repositories).

Create a token at: [GitHub Personal Access Tokens documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

Then export it before building:
```bash
export GH_TOKEN=your_github_personal_access_token
```

### 3. Build the Docker Image

```bash
./build-opencode-docker.sh
```

This will automatically build the image if it doesn't exist locally.

**Force Rebuild:**
```bash
./build-opencode-docker.sh rebuild
```

Force a rebuild when you've made changes to the Dockerfile or want to refresh the base image with latest package updates.

### 4. Run a Sandbox

Navigate to your project directory and run:

```bash
./sandbox-opencode.sh
```

Your shell prompt will change to `<username>@sandbox` to indicate you're in the sandbox environment.

## Usage

### Container Naming

Containers are named based on the current directory:

- `/home/user/projects/myapp` → `myapp-sandbox`
- `/home/user/experiments/test` → `test-sandbox`

This allows running multiple sandboxes simultaneously from different directories.

### Multiple Connections to a Running Sandbox

Once you have a sandbox running, you can create additional connections to it from other terminals:

```bash
./sandbox-opencode.sh
```

**Behavior when exiting:**
- **Additional connections**: When you exit from an additional connection, **only that connection closes** - the sandbox continues running.
- **Starting connection**: When you exit from the terminal that originally started the sandbox, the container is **automatically removed** along with **all active connections** to it (due to the `--rm` flag).

### Volume Mounts

The following host paths are automatically mounted into the container:

| Host Path | Container Path | Mode | Purpose |
|-----------|---------------|------|---------|
| `$PWD` (current directory) | `/home/<username>/project` | Read-write | Your project files |
| `$HOME/.ssh` | `/home/<username>/.ssh` | Read-only | SSH keys for git/GitHub |
| `$HOME/.config/git/config` | `~/.config/git/config` | Read-only | Git configuration |
| `$HOME/.config/opencode` | `~/.config/opencode` | Read-only | OpenCode AI configuration |

### Automatic Cleanup

Containers are automatically removed when you exit from the starting connection due to the `--rm` flag. No manual cleanup is required.

## Configuration

### Build Script (`build-opencode-docker.sh`)

| Variable | Default | Description |
|----------|---------|-------------|
| `IMAGE_NAME` | `arch-opencode-base` | Name for the Docker image |
| `DOCKERFILE` | `$(dirname "$0")/Dockerfile` | Path to Dockerfile |

If your Dockerfile is not in the same directory as the script, update the `DOCKERFILE` variable.

### Sandbox Script (`sandbox-opencode.sh`)

| Variable | Default | Description |
|----------|---------|-------------|
| `IMAGE_NAME` | `arch-opencode-base` | Docker image to run (must match build script) |
| `CONTAINER_NAME` | `$(basename "$PWD")-sandbox` | Container name based on directory |

## Installed Packages

The Docker image includes the following tools:

| Package | Purpose |
|---------|---------|
| `wget` | Download tool for fetching files |
| `vim` | Terminal text editor |
| `ca-certificates` | SSL/TLS certificates for HTTPS |
| `curl` | Transfer data with URLs |
| `unzip` | Extract .zip archives |
| `gnupg` | GNU Privacy Guard for cryptographic operations |
| `sudo` | Execute commands as superuser |
| `jq` | Command-line JSON processor |
| `openssh` | SSH client/server for remote connections |
| `git` | Version control system |
| `github-cli` | GitHub CLI tool (gh) |

## Troubleshooting

### "GH_TOKEN is not set"

Export your GitHub token before building:
```bash
export GH_TOKEN=your_github_personal_access_token
```

### "Dockerfile not found"

Check that the `DOCKERFILE` variable in `build-opencode-docker.sh` points to the correct path.

### "Docker build failed"

- Verify all placeholders (`<username>`, `<uid>`) have been replaced in Dockerfile
- Check the error output for specific issues
- Ensure Docker is running and you have permissions to use it

### "Permission denied on volume mounts"

This usually occurs when the container UID doesn't match your host UID:
- Run `id -u` on your host to get your UID
- Ensure `<uid>` in Dockerfile matches this value
- Rebuild the image: `./build-opencode-docker.sh rebuild`

### "Container is already running"

This is normal - the script will create an additional connection to the existing sandbox. If you need to start fresh, manually remove the container:
```bash
docker rm -f <container-name>
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

[MIT License](LICENSE)
