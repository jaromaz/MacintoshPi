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
# Mac OS 8 - SheepShaver auto-compile/install script
# --------------------------------------------------------

printf "\e[92m"; echo '
 __  __             ___  ____     ___  
|  \/  | __ _  ___ / _ \/ ___|   / _ \ 
| |\/| |/ _` |/ __| | | \___ \  | (_) |
| |  | | (_| | (__| |_| |___) |  \__, |
|_|  |_|\__,_|\___|\___/|____/     /_/ 

'; printf "\e[0m"; sleep 2
source ../assets/func.sh
usercheck
updateinfo
MacOS_version 9

sudo apt install -y libdirectfb-dev automake gobjc libudev-dev xa65 build-essential \
                    alsa-oss osspd byacc texi2html flex libreadline-dev libxaw7-dev \
                    texinfo libxaw7-dev libgtk2.0-cil-dev libgtkglext1-dev libpulse-dev \
                    bison libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev libvte-dev \
                    libasound2-dev raspberrypi-kernel-headers build-essential git \
                    libgtk2.0-dev x11proto-xf86dga-dev libesd0-dev libxxf86dga-dev \
                    libxxf86dga1 libsdl1.2-dev 

[ $? -ne 0 ] && net_error "Mac OS 9 apt packages"

# Mac OS 9 config
echo "
rom    ${MACOS_DIR}/newworld86.rom
disk   ${MACOS_DIR}/hdd.dsk
frameskip 2
ramsize 134217728
ether slirp
nosound false
nocdrom false
nogui false
jit false
mousewheelmode 1
mousewheellines 3
dsp /dev/dsp
mixer
ignoresegv true
idlewait true
seriala /dev/tnt1
serialb /dev/null
extfs /home/pi/Downloads
screen win/800/600
# screen dga/800/600
# screen win/640/480
" > ${MACOS_CONFIG}

# ROM & System
cd ${MACOS_DIR}
wget ${ROM}
[ $? -ne 0 ] && net_error "Mac OS 9 ROM file"
unzip newworld86.rom.zip 2>/dev/null
wget -O ${MACOS_DIR}/hdd.dsk.gz ${HDD_IMAGE}
[ $? -ne 0 ] && net_error "Mac OS 9 HDD image"
echo "* Decompressing the hard drive image - please wait"
gzip -d hdd.dsk.gz


# SDL2 check && builder
[ -f $SDL2_FILE ] || Build_SDL2

# SheepShaver check && builder
[ -f $SHEEPSHAVER_FILE ] || Build_SheepShaver

echo "* Mac OS 9 installation complete"
sleep 2

