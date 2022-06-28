#!/bin/bash

# -------------------------------------------------------
# MacintoshPi
# -------------------------------------------------------
# Description:
# -------------------------------------------------------
# It is a small project that allows running full-screen
# versions of Apple's Mac OS 7, 8 and 9 with audio,
# active online connection and modem emulation under
# Raspberry Pi. All that without the window manager,
# and entirely from the CLI / Raspberry Pi OS Lite level.
# -------------------------------------------------------
clear
printf "\e[96m"; echo '
 __  __            _       _            _     ____  _ 
|  \/  | __ _  ___(_)_ __ | |_ ___  ___| |__ |  _ \(_)
| |\/| |/ _  |/ __| |  _ \| __/ _ \/ __|  _ \| |_) | |
| |  | | (_| | (__| | | | | || (_) \__ \ | | |  __/| |
|_|  |_|\__,_|\___|_|_| |_|\__\___/|___/_| |_|_|   |_|
 
'; printf "\e[0m"
source assets/func.sh
usercheck
updateinfo
installinfo
for APP in macos7 macos8 macos9 vice cdemu vmodem syncterm; do
    ( cd ${APP} && ./${APP}.sh )
done
echo '** all done'

