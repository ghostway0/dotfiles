# xset +fp /usr/share/fonts/NerdFonts/ */
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" &
sh .xprofile &
pipewire &
pipewire-pulse &
pipewire-media-session &
wireplumber &
dbus-launch leftwm
