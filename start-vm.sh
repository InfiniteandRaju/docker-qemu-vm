#!/bin/bash
set -e

VM_NAME="ubuntu-test"
IMG_FILE="/vms/ubuntu-22.04.qcow2"
SEED_FILE="/cloud-init/seed.img"
SSH_PORT=2222
MEMORY="1024M"
CPUS="1"

# Download image if not exists
if [[ ! -f "$IMG_FILE" ]]; then
    echo "[INFO] Downloading Ubuntu 22.04 cloud image..."
    wget -O "$IMG_FILE" https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
fi

# Create cloud-init seed
cloud-localds "$SEED_FILE" /cloud-init/user-data /cloud-init/meta-data

# Check KVM availability
if [[ -c /dev/kvm ]]; then
    ACCEL="-enable-kvm"
    echo "[INFO] Using KVM acceleration"
else
    ACCEL="-accel tcg"
    echo "[WARN] KVM not available, using software emulation"
fi

# Start VM
echo "[INFO] Starting VM..."
qemu-system-x86_64 $ACCEL \
    -m $MEMORY -smp $CPUS -cpu host \
    -drive file="$IMG_FILE",format=qcow2,if=virtio \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -netdev user,id=n0,hostfwd=tcp::$SSH_PORT-:22 \
    -device virtio-net-pci,netdev=n0 \
    -nographic \
    -serial mon:stdio
