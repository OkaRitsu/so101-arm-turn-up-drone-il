#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env FOLLOWER_PORT LEADER_PORT
build_cameras
uv run lerobot-teleoperate \
  "--robot.type=so101_follower" \
  "--robot.port=$FOLLOWER_PORT" \
  --robot.id=my_awesome_follower_arm \
  "--robot.cameras=$CAMERAS" \
  "--teleop.type=so101_leader" \
  "--teleop.port=$LEADER_PORT" \
  --teleop.id=my_awesome_leader_arm \
  --display_data=true
