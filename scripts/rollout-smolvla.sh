#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env HF_USERNAME FOLLOWER_PORT
build_cameras
if ! has_cli_option --policy.path "$@"; then
  set -- "--policy.path=$HF_USERNAME/smolvla-turn-up-drone" "$@"
fi

uv run lerobot-rollout \
  --strategy.type=base \
  --robot.type=so101_follower \
  "--robot.port=$FOLLOWER_PORT" \
  --robot.id=my_awesome_follower_arm \
  "--robot.cameras=$CAMERAS" \
  --task="Lift the upside-down drone by its central body, turn it upright, place it stably on the table, and release it." \
  --duration=40 \
  --device=mps \
  --inference.type=rtc \
  --inference.rtc.execution_horizon=10 \
  --inference.rtc.max_guidance_weight=10.0 \
  "$@"
