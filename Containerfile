FROM registry.fedoraproject.org/fedora:44

ARG REPO_OWNER
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

LABEL org.opencontainers.image.title="dev-container"
LABEL org.opencontainers.image.description="Personal development base image for DevPod/devcontainer-style development"
LABEL org.opencontainers.image.source="https://github.com/${REPO_OWNER}/base-devcontainer-image"
LABEL org.opencontainers.image.licenses="MIT"

USER root

RUN dnf install -y \
  curl \
  fuse-overlayfs \
  git \
  neovim \
  podman \
  podman-compose \
  shadow-utils \
  zsh \
  && rpm --setcaps shadow-utils 2>/dev/null || true \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN groupadd \
  --gid "${USER_GID}" \
  "${USERNAME}" \
  && useradd \
  --uid "${USER_UID}" \
  --gid "${USER_GID}" \
  --create-home \
  --shell /usr/bin/zsh \
  "${USERNAME}"

# Match the strategy used by Podman's official nested image:
# delegate container IDs while excluding UID/GID 1000 itself.
RUN printf '%s\n' \
  "root:1:65535" \
  "${USERNAME}:1:999" \
  "${USERNAME}:1001:64535" \
  > /etc/subuid \
  && printf '%s\n' \
  "root:1:65535" \
  "${USERNAME}:1:999" \
  "${USERNAME}:1001:64535" \
  > /etc/subgid

RUN install -d \
  -m 0755 \
  -o "${USER_UID}" \
  -g "${USER_GID}" \
  "/home/${USERNAME}/.config/containers" \
  "/home/${USERNAME}/.local/share/containers" \
  && chown -R \
  "${USER_UID}:${USER_GID}" \
  "/home/${USERNAME}"

# Enable fuse-overlayfs for nested Podman storage.
RUN sed \
  -e 's|^#mount_program|mount_program|g' \
  -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
  /usr/share/containers/storage.conf \
  > /etc/containers/storage.conf

RUN curl -fsSL https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

ENV HOME="/home/${USERNAME}" \
  _CONTAINERS_USERNS_CONFIGURED="" \
  BUILDAH_ISOLATION="chroot"

WORKDIR /home/${USERNAME}

USER ${USERNAME}

CMD ["/usr/bin/zsh"]
