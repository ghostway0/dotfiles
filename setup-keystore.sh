#! /bin/bash

if [ ! -d "$HOME/.key-store/" ]; then
  mkdir -p ~/.key-store
  rclone sync backblaze:key-store ~/.key-store
fi

