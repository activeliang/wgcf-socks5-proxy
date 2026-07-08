FROM ubuntu:20.04 AS builder

RUN apt-get update && apt-get install -y \
  git gcc make libc6-dev ca-certificates --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/rofl0r/microsocks.git \
  && cd microsocks \
  && make \
  && make install

FROM ubuntu:20.04

ARG TARGETARCH
ARG WGCF_VERSION=2.2.31

COPY --from=builder /usr/local/bin/microsocks /usr/local/bin/microsocks

RUN apt-get update && apt-get install -y \
  curl ca-certificates \
  iproute2 net-tools iptables \
  wireguard-tools openresolv  kmod --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*
RUN set -eux; \
  arch="${TARGETARCH:-$(uname -m)}"; \
  case "$arch" in \
    amd64|x86_64) arch="amd64" ;; \
    arm64|aarch64) arch="arm64" ;; \
    386|i386|i686) arch="386" ;; \
    *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /usr/local/bin/wgcf "https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_${arch}"; \
  chmod +x /usr/local/bin/wgcf; \
  wgcf --help >/dev/null; \
  mkdir -p /wgcf

WORKDIR /wgcf

VOLUME /wgcf


COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

ENTRYPOINT ["/entry.sh"]
