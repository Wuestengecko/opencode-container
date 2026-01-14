FROM docker.io/library/archlinux:base

RUN --mount=type=cache,id=pacman-cache-opencode,target=/var/cache/pacman/pkg \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Syu --noconfirm jujutsu ripgrep which && \
    pacman -Sc --noconfirm

ARG OC_URL=https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-x64.tar.gz
RUN curl -#LsSf "$OC_URL" | tar -xzOf- opencode | install -Dm755 /dev/stdin /usr/bin/opencode

CMD ["/usr/bin/opencode"]
