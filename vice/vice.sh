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
# VICE - auto-compile/install script
# ----------------------------------

printf "\e[92m"; echo '
__     _____ ____ _____ 
\ \   / /_ _/ ___| ____|
 \ \ / / | | |   |  _|  
  \ V /  | | |___| |___ 
   \_/  |___\____|_____|

'; printf "\e[0m"; sleep 2
source ../assets/func.sh
updateinfo
# Packages
sudo apt install -y wget tcpser netcat automake gobjc libudev-dev xa65 build-essential byacc \
                    texi2html flex libreadline-dev libxaw7-dev texinfo libxaw7-dev libgtk2.0-cil-dev \
                    libgtkglext1-dev libpulse-dev bison libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev \
                    libvte-dev libasound2-dev

[ $? -ne 0 ] && net_error "VICE apt packages"

# SDL2 check && builder
[ -f $SDL2_FILE ] || Build_SDL2;

# VICE

mkdir -p ${SRC_DIR} 2>/dev/null
wget ${VICE_SOURCE} -O - | tar -xz -C ${SRC_DIR}
[ $? -ne 0 ] && net_error "VICE sources"

cd ${SRC_DIR}/vice-3.4
./configure --without-pulse \
            --with-sdlsound \
            --enable-sdlui2 \
            --enable-ethernet \
            --enable-rs232
make
sudo make install
rm -rf ${SRC_DIR}
echo '* done'

