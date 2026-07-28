FROM registry.fedoraproject.org/fedora:44

ARG REPO_OWNER
ARG USERNAME=dev

LABEL org.opencontainers.image.title="dev-container"
LABEL org.opencontainers.image.description="Personal development base image for DevPod/devcontainer-style development"
LABEL org.opencontainers.image.source="https://github.com/${REPO_OWNER}/base-devcontainer-image"
LABEL org.opencontainers.image.licenses="MIT"

# Install all needed packages at build time as root.
RUN dnf install -y \
  git \
  zsh \
  neovim \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN groupadd --gid 1000 "${USERNAME}" \
  && useradd \
  --uid 1000 \
  --gid 1000 \
  --create-home \
  --shell /usr/bin/zsh \
  "${USERNAME}"

# Install mise globally so every project/user can use it.

RUN curl -fsSL https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

WORKDIR /home/dev

CMD ["/usr/bin/zsh"]
