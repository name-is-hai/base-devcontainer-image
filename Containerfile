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
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN groupadd --gid 1000 "${USERNAME}" \
  && useradd \
  --uid 1000 \
  --gid 1000 \
  --create-home \
  --shell /usr/bin/zsh \
  "${USERNAME}"

RUN printf '%s:100000:65536\n' "${USERNAME}" > /etc/subuid \
  && printf '%s:100000:65536\n' "${USERNAME}" > /etc/subgid

RUN rpm --setcaps shadow-utils \
  && getcap /usr/bin/newuidmap /usr/bin/newgidmap

RUN install -d \
  -m 0700 \
  -o "${USER_UID}" \
  -g "${USER_GID}" \
  "/run/user/${USER_UID}" \
  "/home/${USERNAME}/.config/containers" \
  "/home/${USERNAME}/.local/share/containers"

RUN printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${USERNAME}" \
  > "/etc/sudoers.d/${USERNAME}" \
  && chmod 0440 "/etc/sudoers.d/${USERNAME}"

RUN curl -fsSL https://mise.run \
  | MISE_INSTALL_PATH=/usr/local/bin/mise sh

ENV HOME="/home/${USERNAME}"
ENV XDG_RUNTIME_DIR="/run/user/${USER_UID}"

WORKDIR /home/${USERNAME}

CMD ["/usr/bin/zsh"]
