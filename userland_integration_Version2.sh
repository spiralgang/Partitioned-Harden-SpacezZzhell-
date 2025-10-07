#!/bin/bash
# Android 10 UserLAnd Integration for ZShell
# Target: SM-G965U1 / UserLAnd CLI Environment
# v1.0.0

ZSHELL_DIR="/data/data/tech.ula/files/home/zshell"
SYSTEM_IMG="${ZSHELL_DIR}/system.img"
MOUNT_POINT="${ZSHELL_DIR}/mnt"
LOG_FILE="${ZSHELL_DIR}/zshell.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "${LOG_FILE}"; }

# Essential Android 10 fixes
fix_selinux() {
  if command -v getenforce >/dev/null; then
    # For UserLAnd context without needing root
    log "SELinux workaround applied for UserLAnd context"
    export PROOT_NO_SECCOMP=1
  fi
}

mount_system() {
  mkdir -p "${MOUNT_POINT}/system" "${MOUNT_POINT}/overlay" "${MOUNT_POINT}/work"
  
  # UserLAnd-compatible mount approach (no real mount needed)
  proot -r "${SYSTEM_IMG}" \
    -b /dev -b /proc -b /sys \
    -b "${ZSHELL_DIR}/overlay:/overlay" \
    -w / /system/bin/sh -c "$@" || {
    log "Failed to execute in isolated environment"
    return 1
  }
  
  return 0
}

# Setup CLI hooks for UserLAnd
setup_cli_hooks() {
  local HOOK_PATH="${HOME}/.bashrc"
  
  cat >> "${HOOK_PATH}" << EOF
# ZShell CLI hooks
alias zshell='${ZSHELL_DIR}/zshell.sh'
function zsh_exec() {
  ${ZSHELL_DIR}/zshell.sh exec "\$@"
}
EOF

  log "CLI hooks installed to ${HOOK_PATH}"
}

case "$1" in
  setup)
    mkdir -p "${ZSHELL_DIR}"
    fix_selinux
    setup_cli_hooks
    log "Setup complete - restart UserLAnd session to apply changes"
    ;;
  exec)
    shift
    fix_selinux
    mount_system "$@"
    ;;
  *)
    echo "Usage: $0 {setup|exec command}"
    ;;
esac