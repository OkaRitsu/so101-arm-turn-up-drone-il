#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env LEADER_PORT
uv run lerobot-calibrate \
  "--teleop.type=so101_leader" \
  "--teleop.port=$LEADER_PORT" \
  --teleop.id=my_awesome_leader_arm
