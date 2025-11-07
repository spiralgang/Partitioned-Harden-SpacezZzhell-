#!/data/data/com.termux/files/usr/bin/bash
# Ubuntu Distro Installation Script for Hardened Partitioned Space
# Sets up a minimal Ubuntu environment within the hardened space

set -euo pipefail

# Configuration
DISTRO_NAME="ubuntu"
DISTRO_ROOTFS_DIR="$HOME/.local/share/proot-distro/$DISTRO_NAME"
DEFAULT_UBUNTU_URL="https://github.com/termux/proot-distro/releases/download/v4.9.0/ubuntu-22.04_aarch64_rootfs.tar.xz"
UBUNTU_URL="${PROOT_DISTRO_UBUNTU_URL:-$DEFAULT_UBUNTU_URL}"

# Create the distro directory
echo "Setting up Ubuntu distro environment..."

# Create directory structure
mkdir -p "$DISTRO_ROOTFS_DIR"

# Download Ubuntu rootfs if not present
if [ ! -f "$DISTRO_ROOTFS_DIR/rootfs.tar.xz" ] && [ ! -d "$DISTRO_ROOTFS_DIR/rootfs" ]; then
    echo "Downloading Ubuntu rootfs..."
    wget "$UBUNTU_URL" -O "$DISTRO_ROOTFS_DIR/rootfs.tar.xz"
fi

# Extract rootfs if not already extracted
if [ ! -d "$DISTRO_ROOTFS_DIR/rootfs" ]; then
    echo "Extracting Ubuntu rootfs..."
    tar -xf "$DISTRO_ROOTFS_DIR/rootfs.tar.xz" -C "$DISTRO_ROOTFS_DIR"
fi

# Create additional directories for hardened space integration
mkdir -p "$DISTRO_ROOTFS_DIR/rootfs"/{home/ubuntu,etc/apt,dev,proc,sys,tmp,var/run}

# Setup basic configuration
cat > "$DISTRO_ROOTFS_DIR/rootfs/etc/hosts" << 'EOF'
127.0.0.1 localhost
::1 localhost ip6-localhost ip6-loopback
EOF

# Setup basic profile
cat > "$DISTRO_ROOTFS_DIR/rootfs/etc/profile" << 'EOF'
export PS1='\u@\h:\w\$ '
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANG=C.UTF-8
EOF

# Setup password for root
echo "root:root" | chroot "$DISTRO_ROOTFS_DIR/rootfs" chpasswd

echo "Ubuntu distro installation completed in $DISTRO_ROOTFS_DIR"