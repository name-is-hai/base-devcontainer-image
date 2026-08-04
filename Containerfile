FROM registry.fedoraproject.org/fedora:44

ARG REPO_OWNER
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

LABEL org.opencontainers.image.title="dev-container"
LABEL org.opencontainers.image.description="Personal development base image for DevPod/devcontainer-style development"
LABEL org.opencontainers.image.source="https://github.com/${REPO_OWNER}/base-devcontainer-image"
LABEL org.opencontainers.image.licenses="MIT"

# Install all needed packages at build time as root.
RUN dnf install -y \
  git \
  zsh \
  podman-compose\
  podman \
  neovim \
  shadow-utils \
  fuse-overlayfs \
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

# Delegate IDs available inside the outer container namespace.
# Skip UID/GID 1000 because it belongs to dev.
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

# Configure nested rootless storage through fuse-overlayfs.
RUN sed \
  -e 's|^#mount_program|mount_program|g' \
  -e '/additionalimage.*/a "/var/lib/shared",' \
  -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
  /usr/share/containers/storage.conf \
  > /etc/containers/storage.conf

RUN mkdir -p \
  /var/lib/shared/overlay-images \
  /var/lib/shared/overlay-layers \
  /var/lib/shared/vfs-images \
  /var/lib/shared/vfs-layers \
  && touch \
  /var/lib/shared/overlay-images/images.lock \
  /var/lib/shared/overlay-layers/layers.lock \
  /var/lib/shared/vfs-images/images.lock \
  /var/lib/shared/vfs-layers/layers.lock

RUN curl -fsSL https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

ENV HOME="/home/${USERNAME}" \
  _CONTAINERS_USERNS_CONFIGURED="" \
  BUILDAH_ISOLATION="chroot"

WORKDIR /home/${USERNAME}

CMD ["/usr/bin/zsh"]
