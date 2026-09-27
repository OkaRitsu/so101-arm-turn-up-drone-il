#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_env FOLLOWER_PORT LEADER_PORT HF_USERNAME
build_cameras
uv run lerobot-record \
  "--robot.type=so101_follower" \
  "--robot.port=$FOLLOWER_PORT" \
  --robot.id=my_awesome_follower_arm \
  "--robot.cameras=$CAMERAS" \
  "--teleop.type=so101_leader" \
  "--teleop.port=$LEADER_PORT" \
  --teleop.id=my_awesome_leader_arm \
  --display_data=true \
  "--dataset.repo_id=$HF_USERNAME/so101-turn-up-drone" \
  --dataset.num_episodes=50 \
  --dataset.single_task="Lift the upside-down drone by its central body, turn it upright, place it stably on the table, and release it." \
  --dataset.streaming_encoding=true \
  --dataset.encoder_threads=2 \
  --dataset.root=data/so101-turn-up-drone \
  --resume=true \
  "$@"
