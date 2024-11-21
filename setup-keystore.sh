#! /bin/bash

if [ ! -d "$HOME/.key-store/" ]; then
  mkdir "$HOME/.key-store"

  systemctl --user enable rclone-keystore.service
  systemctl --user start rclone-keystore.service
fi

