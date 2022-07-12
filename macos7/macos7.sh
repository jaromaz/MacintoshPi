#!/bin/bash
# --------------------------------------------------------
# MacintoshPi
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
# Mac OS 7 - Basilisk II auto-compile/install script
# --------------------------------------------------------

printf "\e[92m"; echo '
 __  __               ___  ____    _____ 
|  \/  | __ _  ___   / _ \/ ___|  |___  |
| |\/| |/ _` |/ __| | | | \___ \     / / 
| |  | | (_| | (__  | |_| |___) |   / /  
|_|  |_|\__,_|\___|  \___/|____/   /_/   

'; printf "\e[0m"; sleep 2
source ../assets/func.sh
usercheck
updateinfo
MacOS_version 7

sudo apt install -y automake gobjc libudev-dev xa65 build-essential byacc texi2html \
                    flex libreadline-dev unzip libxaw7-dev texinfo libxaw7-dev unar \
                    libgtk2.0-cil-dev libgtkglext1-dev libpulse-dev bison libnet1 \
                    libnet1-dev libpcap0.8 libpcap0.8-dev libvte-dev libasound2-dev \
                    raspberrypi-kernel-headers

[ $? -ne 0 ] && net_error "Mac OS 7 apt packages"

# Mac OS 7 config
echo "
#disk   ${MACOS_DIR}/system70.dsk
#disk   ${MACOS_DIR}/system75.dsk
rom    ${MACOS_DIR}/Performa-630.ROM
disk   ${MACOS_DIR}/hdd.dsk
frameskip 2
ramsize 67108864
ether slirp
modelid 5
cpu 4
fpu true
nosound false
nocdrom false
nogui false
jit false
jitfpu false
jitdebug false
mousewheelmode 1
mousewheellines 3
mixer
ignoresegv true
idlewait true
seriala /dev/tnt1
serialb /dev/null
udptunnel false
extfs /home/pi/Downloads
# screen dga/800/600
screen win/640/480
# screen win/512/342
" > ${MACOS_CONFIG}


# ROM & System
cd ${MACOS_DIR}
wget ${ROM}
[ $? -ne 0 ] && net_error "Mac OS 7 ROM file"

wget -O ${MACOS_DIR}/hdd.dsk.gz ${HDD_IMAGE}
[ $? -ne 0 ] && net_error "Mac OS 7 HDD image"

echo "* Decompressing the hard drive image - please wait"
gzip -d hdd.dsk.gz


# SDL2 check && builder
[ -f $SDL2_FILE ] || Build_SDL2;

# BasiliskII check && builder
[ -f $BASILISK_FILE ] || Build_BasiliskII;

echo "* Mac OS 7 / System 7.5.5 installation complete"
sleep 2

