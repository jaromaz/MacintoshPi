#!/bin/bash

printf "\e[92m"; echo '
__     _____ ____ _____ 
\ \   / /_ _/ ___| ____|
 \ \ / / | | |   |  _|  
  \ V /  | | |___| |___ 
   \_/  |___\____|_____|

'; printf "\e[0m"; sleep 2
source ../assets/func.sh

# Packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget tcpser netcat automake gobjc libudev-dev xa65 build-essential byacc \
                    texi2html flex libreadline-dev libxaw7-dev texinfo libxaw7-dev libgtk2.0-cil-dev \
                    libgtkglext1-dev libpulse-dev bison libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev \
                    libvte-dev libasound2-dev

# SDL2 check && builder
[ -f $SDL2_FILE ] || Build_SDL2;

# VICE

mkdir -p ${SRC_DIR} 2>/dev/null
wget ${VICE_SOURCE} -O - | tar -xz -C ${SRC_DIR}

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

