#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env HF_USERNAME

RUN_NAME="${1:-smolvla_$(date -u +%Y%m%dT%H%M%SZ)}"
if [[ "$RUN_NAME" == -* || ! "$RUN_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  echo "Usage: $0 [RUN_NAME] [lerobot-train options]; RUN_NAME uses letters, digits, _ or -." >&2
  exit 1
fi
if [[ $# -gt 0 ]]; then shift; fi

# LeRobot resolves the first policy.path, unlike ordinary CLI overrides.
if ! has_cli_option --policy.path "$@"; then
  set -- --policy.path=lerobot/smolvla_base "$@"
fi

uv runlerobot-train \
  --policy.device=cuda \
  "--policy.repo_id=$HF_USERNAME/smolvla-turn-up-drone" \
  "--dataset.repo_id=$HF_USERNAME/so101-turn-up-drone" \
  --batch_size=64 \
  --steps=10000 \
  --log_freq=50 \
  --save_freq=2000 \
  "--output_dir=outputs/train/$RUN_NAME" \
  "--job_name=$RUN_NAME" \
  --policy.push_to_hub=true \
  --wandb.enable=true \
  "$@"
