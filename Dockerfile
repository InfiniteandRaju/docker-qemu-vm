# Dockerfile
#
# Minimal environment to run QEMU.
# Uses host /dev/kvm if passed in at runtime, otherwise falls back to TCG.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install QEMU and basic tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        qemu-system-x86 \
        wget \
        xz-utils \
        sudo \
        ca-certificates \
        iproute2 \
        net-tools \
        vim \
        less && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

# Copy helper script
COPY run-qemu.sh /home/dev/run-qemu.sh
RUN chmod +x /home/dev/run-qemu.sh

# Default command: print help
CMD ["/home/dev/run-qemu.sh", "--help"]
