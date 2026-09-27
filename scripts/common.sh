#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
LEROBOT_DIR="$REPO_ROOT/lerobot"
ENV_FILE="$REPO_ROOT/.env"

# Mac uses .env; containers receive configuration from their runtime.
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

require_env() {
  local name
  for name in "$@"; do
    if [[ -z "${!name:-}" ]]; then
      echo "Required environment variable '$name' is empty. Set it in .env or the runtime environment." >&2
      exit 1
    fi
  done
}

build_cameras() {
  require_env WRIST_CAMERA_INDEX TOP_CAMERA_INDEX
  CAMERAS="{wrist.top: {type: opencv, index_or_path: $WRIST_CAMERA_INDEX, width: 640, height: 480, fps: 30}, top: {type: opencv, index_or_path: $TOP_CAMERA_INDEX, width: 640, height: 480, fps: 30}}"
}

has_cli_option() {
  local option="$1" arg
  shift
  for arg in "$@"; do
    if [[ "${arg%%=*}" == "$option" ]]; then return 0; fi
  done
  return 1
}