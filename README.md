# base-devcontaner-images

Personal container image builds for development environments.

This repository builds and publishes a reusable UBI 9 development base image to GitHub Container Registry.

## Image

```txt
ghcr.io/YOUR_USERNAME/base-dev-image:latest
ghcr.io/YOUR_USERNAME/base-dev-image:sha-<git-sha>
```

## Purpose

This image is meant to be a clean development base image for tools like DevPod, devcontainers, and toolbox-style workflows.

It includes common Linux development tools only, such as:

```txt
git
zsh
wget 
unzip 
openssh-clients 
procps-ng 
hostname
mise
```

Project-specific runtimes should not be baked into this base image. Install them per project instead.

Examples of project-specific tools:

```txt
node
pnpm
dotnet
terraform
kubectl
helm
awscli
go
rust
python dependencies
```

## Repository structure

```txt
cosmkit-images/
├── Containerfile
└── .github/
    └── workflows/
        └── build-base-dev-image.yml
```

## Build locally

From the repository root:

```bash
podman build \
  -t ghcr.io/YOUR_USERNAME/base-dev-image:latest \
  -f Containerfile \
  .
```

## Build with custom user arguments

The image supports build arguments for the default user:

```bash
podman build \
  --build-arg USERNAME=user \
  --build-arg USER_UID=1000 \
  --build-arg USER_GID=1000 \
  -t ghcr.io/YOUR_USERNAME/base-dev-image:latest \
  -f Containerfile \
  .
```

## Test locally

```bash
podman run --rm -it ghcr.io/YOUR_USERNAME/base-dev-image:latest
```

Inside the container:

```bash
whoami
id
git --version
zsh --version
jq --version
gcc --version
```

## Push manually to GHCR

Create a GitHub Personal Access Token with package write permission, then login:

```bash
echo "$GHCR_TOKEN" | podman login ghcr.io -u YOUR_USERNAME --password-stdin
```

Push the image:

```bash
podman push ghcr.io/YOUR_USERNAME/base-dev-image:latest
```

## Automated build

GitHub Actions builds and pushes the image when files under `images/base-dev-image/` change.

The workflow publishes these tags:

```txt
latest
base-dev-image
sha-<git-sha>
```

Use `latest` for testing.

Use `sha-<git-sha>` when you want reproducible development environments.

## Example usage in another project

This repository does not contain a `devcontainer.json`.

Project repositories should reference the published image themselves.

Example:

```json
{
  "name": "my-project",
  "image": "ghcr.io/YOUR_USERNAME/base-dev-image:latest",
  "remoteUser": "user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/my-project"
}
```

For a pinned image:

```json
{
  "name": "my-project",
  "image": "ghcr.io/YOUR_USERNAME/base-dev-image:sha-abc1234",
  "remoteUser": "user",
  "updateRemoteUserUID": true,
  "workspaceFolder": "/workspaces/my-project"
}
```

## License

This repository is licensed under the MIT License.
