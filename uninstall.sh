#!/bin/bash
#
# Junie CLI Uninstaller
#

set -euo pipefail

JUNIE_BIN="$HOME/.local/bin/junie"
JUNIE_DATA="$HOME/.local/share/junie"
FORCE=0
DRY_RUN=0

log() { echo "[Junie] $*"; }
warn() { echo "[Junie] WARNING: $*" >&2; }
log_error() { echo "[Junie] ERROR: $*" >&2; }

usage() {
    cat <<'EOF'
Usage: bash junie-uninstall.sh [--force] [--dry-run]

Options:
  --force    Skip confirmation prompt
  --dry-run  Show what would be  removed without changing anything
  --help     Show this help
EOF
}

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] '
        printf '%q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

safe_path() {
    local path="$1"
    case "$path" in
        "$HOME/.local/bin/"* | "$HOME/.local/share/junie" | "$HOME/.local/share/junie/"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

remove_file_if_exists() {
    local path="$1"
    if [[ ! -e "$path" && ! -L "$path" ]]; then
        return 0
    fi
    if ! safe_path "$path"; then
        log_error "Refusing to remove unsafe path: $path"
        exit 1
    fi
    log "Removing $path"
    run rm -f "$path"
}

remove_dir_if_exists() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        return 0
    fi
    if ! safe_path "$path"; then
        log_error "Refusing to remove unsafe path: $path"
        exit 1
    fi
    log "Removing $path"
    run rm -rf "$path"
}

remove_dir_if_empty() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        return 0
    fi
    if ! safe_path "$path"; then
        log_error "Refusing to inspect unsafe path: $path"
        exit 1
    fi
    if [[ -z "$(ls -A "$path" 2>/dev/null)" ]]; then
        log "Removing empty directory $path"
        run rmdir "$path"
    fi
}

remove_line_from_file() {
    local file="$1"
    local exact_line
}
