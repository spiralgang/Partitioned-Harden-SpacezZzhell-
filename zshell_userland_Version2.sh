#!/bin/bash
# ZShell UserLAnd Integration (Non-Root)
# Android 10 / SM-G965U1 Compatible
# v1.1.0

set -eo pipefail

ZSHELL_DIR="$HOME/zshell"
OVERLAY_DIR="$ZSHELL_DIR/overlay"
SYSTEM_IMG="$ZSHELL_DIR/system.img"
LOG_FILE="$ZSHELL_DIR/zshell.log"
ZRAM_CONF="$ZSHELL_DIR/zram.conf"
SSH_PORT=2022

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
fail() { log "ERROR: $1"; exit 1; }

# UserLAnd requires PROOT_NO_SECCOMP for Android 10 SELinux restrictions
export PROOT_NO_SECCOMP=1

check_deps() {
  for cmd in proot tar unzip; do
    command -v $cmd >/dev/null 2>&1 || fail "Missing $cmd. Run: apt-get update && apt-get install -y $cmd"
  done
}

setup() {
  mkdir -p "$OVERLAY_DIR" "$ZSHELL_DIR/work" "$ZSHELL_DIR/ssh"
  
  if [ ! -f "$SYSTEM_IMG" ]; then
    if [ -f "$1" ]; then
      log "Extracting system image from $1"
      if [[ "$1" == *.zip ]]; then
        # Extract from firmware package
        unzip -p "$1" "system.img" > "$SYSTEM_IMG" 2>/dev/null || \
        unzip -p "$1" "system.img.lz4" > "$SYSTEM_IMG.lz4" 2>/dev/null || \
        unzip -p "$1" "AP*.tar.md5" | tar -xOf - system.img > "$SYSTEM_IMG" 2>/dev/null || \
        fail "Could not find system image in firmware"
        
        # Handle LZ4 compression if needed
        if [ -f "$SYSTEM_IMG.lz4" ]; then
          command -v lz4 >/dev/null 2>&1 || apt-get install -y lz4
          lz4 -d "$SYSTEM_IMG.lz4" "$SYSTEM_IMG"
          rm "$SYSTEM_IMG.lz4"
        fi
      else
        log "Copying system image from $1"
        cp "$1" "$SYSTEM_IMG"
      fi
    else
      fail "System image not found. Usage: $0 setup /path/to/system.img|firmware.zip"
    fi
  fi

  # Create SSH key if needed
  if [ ! -f "$ZSHELL_DIR/ssh/id_ed25519" ]; then
    log "Generating SSH keys"
    ssh-keygen -t ed25519 -N "" -f "$ZSHELL_DIR/ssh/id_ed25519"
    cp "$ZSHELL_DIR/ssh/id_ed25519.pub" "$ZSHELL_DIR/ssh/authorized_keys"
  fi
  
  # Create launcher script in PATH
  cat > "$HOME/bin/zs" <<EOF
#!/bin/bash
$ZSHELL_DIR/zshell_userland.sh \$@
EOF
  mkdir -p "$HOME/bin"
  chmod +x "$HOME/bin/zs"
  
  # Add to PATH if needed
  if ! grep -q "$HOME/bin" "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  
  log "Setup complete. Run 'zs start' to begin"
}

start() {
  [ -f "$SYSTEM_IMG" ] || fail "System image not found. Run: $0 setup /path/to/system.img"

  # Optimize ZRAM if available (userspace approach)
  if [ -f "/proc/swaps" ] && ! grep -q zram "/proc/swaps" 2>/dev/null; then
    log "Configuring ZRAM in userspace mode"
    # UserLAnd can't modify real ZRAM without root, but we document settings
    echo "ZRAM_SIZE=2G" > "$ZRAM_CONF"
    echo "ZRAM_ALGORITHM=lz4" >> "$ZRAM_CONF"
    echo "ZRAM_PRIORITY=100" >> "$ZRAM_CONF"
  fi

  # Start dropbear SSH in UserLAnd context if available
  if command -v dropbear >/dev/null 2>&1; then
    log "Starting SSH service on port $SSH_PORT"
    dropbear -p $SSH_PORT -r "$ZSHELL_DIR/ssh/id_ed25519" -F -E &
    echo $! > "$ZSHELL_DIR/ssh.pid"
  fi

  # Launch isolated environment with proot
  log "Starting isolated environment"
  proot -r "$SYSTEM_IMG" \
    -b /dev -b /proc -b /sys \
    -b "$OVERLAY_DIR:/data/overlay" \
    -b "$ZSHELL_DIR/ssh:/data/ssh" \
    -w / /system/bin/sh
    
  # Clean up on exit
  if [ -f "$ZSHELL_DIR/ssh.pid" ]; then
    kill $(cat "$ZSHELL_DIR/ssh.pid") 2>/dev/null || true
    rm "$ZSHELL_DIR/ssh.pid"
  fi
}

case "$1" in
  setup) shift; setup "$1" ;;
  start) start ;;
  exec)  shift; proot -r "$SYSTEM_IMG" -b /dev -b /proc -b /sys -w / /system/bin/sh -c "$*" ;;
  status) 
    echo "=== ZShell Partition Status ==="
    if [ -f "$SYSTEM_IMG" ]; then
      echo "System Image: Available ($(du -h "$SYSTEM_IMG" | cut -f1))"
    else
      echo "System Image: Not found"
    fi
    if pgrep -f "proot.*$SYSTEM_IMG" >/dev/null; then
      echo "Status: Running (PID: $(pgrep -f "proot.*$SYSTEM_IMG"))"
    else
      echo "Status: Stopped"
    fi
    if [ -d "$OVERLAY_DIR" ]; then
      echo "Overlay Size: $(du -sh "$OVERLAY_DIR" | cut -f1)"
    fi
    ;;
  benchmark)
    echo "Running partition performance benchmark..."
    time_start=$(date +%s.%N)
    proot -r "$SYSTEM_IMG" -b /dev -b /proc -b /sys -w / /system/bin/sh -c "echo 'Benchmark test'; ls /system/bin | wc -l"
    time_end=$(date +%s.%N)
    echo "Execution time: $(echo "$time_end - $time_start" | bc)s"
    ;;
  *) echo "Usage: $0 {setup|start|exec|status|benchmark} [command]" ;;
esac