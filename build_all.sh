#!/bin/bash
# --------------------------------------------------------
# MacintoshPi / 2022
# --------------------------------------------------------
# It is a small project that allows running full-screen
# versions of Apple's Mac OS 7, 8 and 9 with audio,
# active online connection and modem emulation under
# Raspberry Pi. All that without the window manager,
# and entirely from the CLI / Raspberry Pi OS Lite level.
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
source assets/func.sh
usercheck
logo
exit
updateinfo
installinfo
for APP in macos7 macos8 macos9 vice cdemu vmodem syncterm; do
    ( cd ${APP} && ./${APP}.sh )
done
echo '** all done'

