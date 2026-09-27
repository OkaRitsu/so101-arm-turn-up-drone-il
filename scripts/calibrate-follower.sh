#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env FOLLOWER_PORT
uv run lerobot-calibrate \
  "--robot.type=so101_follower" \
  "--robot.port=$FOLLOWER_PORT" \
  --robot.id=my_awesome_follower_arm
