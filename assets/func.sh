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
# Author: Jarosław Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
# MacintoshPi functions 
# --------------------------------------------------------

VERSION="1.1.0"
BASE_DIR="/usr/share/macintoshpi"
CONF_DIR="/etc/macintoshpi"
SRC_DIR="${BASE_DIR}/src"
BASILISK_REPO="https://github.com/kanjitalk755/macemu/archive/master.zip"
SHEEPSHAVER_REPO=${BASILISK_REPO}
SDL2_SOURCE="https://www.libsdl.org/release/SDL2-2.0.7.tar.gz" 
VICE_SOURCE="https://downloads.sourceforge.net/project/vice-emu/releases/vice-3.4.tar.gz"
BASILISK_FILE="/usr/local/bin/BasiliskII"
SHEEPSHAVER_FILE="/usr/local/bin/SheepShaver"
SDL2_FILE="/usr/local/lib/libSDL2-2.0.so.0.7.0"
HDD_IMAGES="http://homer-retro.space/appfiles"
ROM4OS[7]="https://github.com/macmade/Macintosh-ROMs/raw/18e1d0a9756f8ae3b9c005a976d292d7cf0a6f14/Performa-630.ROM"
ROM4OS[8]="https://github.com/macmade/Macintosh-ROMs/raw/main/Quadra-650.ROM"
ROM4OS[9]="https://www.redundantrobot.com/sheepshaver_files/roms/newworld86.rom.zip"

function usercheck {
  [ $USER != "pi" ] && echo 'Run this script as the "pi" user.' && exit
}

function updateinfo {
parent=$(cat /proc/$PPID/comm)
if [ "$parent" != "build_all.sh" ]; then
cat <<EOF

* WARNING: To install this software, you must first update and reboot your
           system. If you want to perform these steps now, then press "y" key.
           If your system is up to date and rebooted, then press any other
           key or wait 30 seconds.

EOF

read -t 30 -n 1 -s updinfo
[ "$updinfo" = "y" ] && sudo apt update && sudo apt upgrade -y && sudo reboot && exit
fi
}

function installinfo {
echo "   * INFO: The build and installation process will take approximately"
echo "           two hours"
printf "\n           "
for i in {10..0}; do printf "$i ... "; sleep 1; done
}

function Base_dir {
   [ -d ${BASE_DIR} ] || ( sudo mkdir -p ${BASE_DIR} && sudo chown pi:pi ${BASE_DIR} )
}

function Build_NetDriver {

printf "\e[95m"; echo '
 _   _      _   ____       _                
| \ | | ___| |_|  _ \ _ __(_)_   _____ _ __ 
|  \| |/ _ \ __| | | |  __| \ \ / / _ \  __|
| |\  |  __/ |_| |_| | |  | |\ V /  __/ |   
|_| \_|\___|\__|____/|_|  |_| \_/ \___|_|   

'; printf "\e[0m"; sleep 2

cd Linux/NetDriver
make
sudo make dev
sudo chown pi /dev/sheep_net
sudo make install
sudo modprobe sheep_net

}


function Build_SheepShaver {

printf "\e[95m"; echo '
 ____  _                    ____  _                          
/ ___|| |__   ___  ___ _ __/ ___|| |__   __ ___   _____ _ __ 
\___ \|  _ \ / _ \/ _ \  _ \___ \|  _ \ / _` \ \ / / _ \  __|
 ___) | | | |  __/  __/ |_) |__) | | | | (_| |\ V /  __/ |   
|____/|_| |_|\___|\___| .__/____/|_| |_|\__,_| \_/ \___|_|   
                      |_|                                    
'; printf "\e[0m"; sleep 2

mkdir -p ${SRC_DIR} 2>/dev/null

wget -O ${SRC_DIR}/master.zip ${SHEEPSHAVER_REPO} &&
unzip ${SRC_DIR}/master.zip -d ${SRC_DIR}
cd ${SRC_DIR}/macemu-*/SheepShaver
make links
cd src/Unix

NO_CONFIGURE=1 ./autogen.sh &&
./configure --enable-sdl-audio \
            --enable-sdl-video \
            --enable-sdl-framework \
            --without-gtk \
            --without-mon \
            --without-esd \
            --enable-addressing=direct,0x10000000
            #   --enable-sdl-framework-prefix=/Library/Frameworks

make -j3
sudo make install

modprobe --show sheep_net 2>/dev/null || Build_NetDriver

echo "no-sighandler" | sudo tee /etc/directfbrc
grep -q mmap_min_addr /etc/sysctl.conf || \
echo "vm.mmap_min_addr = 0" | sudo tee -a /etc/sysctl.conf 

rm -rf ${SRC_DIR}

}



function Build_BasiliskII {

printf "\e[95m"; echo '
 ____            _ _ _     _      ___ ___ 
| __ )  __ _ ___(_) (_)___| | __ |_ _|_ _|
|  _ \ / _` / __| | | / __| |/ /  | | | | 
| |_) | (_| \__ \ | | \__ \   <   | | | | 
|____/ \__,_|___/_|_|_|___/_|\_\ |___|___|
  
'; printf "\e[0m"; sleep 2

mkdir -p ${SRC_DIR} 2>/dev/null

wget -O ${SRC_DIR}/master.zip ${BASILISK_REPO}
unzip ${SRC_DIR}/master.zip -d /${SRC_DIR}
cd ${SRC_DIR}/macemu-*/BasiliskII/src/Unix/
NO_CONFIGURE=1 ./autogen.sh &&
./configure --enable-sdl-audio --enable-sdl-framework \
            --enable-sdl-video --disable-vosf \
            --without-mon --without-esd --without-gtk --disable-nls &&
make -j3
sudo make install

modprobe --show sheep_net 2>/dev/null || Build_NetDriver

rm -rf ${SRC_DIR}

}


function Build_SDL2 {

printf "\e[95m"; echo '
 ____  ____  _     ____  
/ ___||  _ \| |   |___ \ 
\___ \| | | | |     __) |
 ___) | |_| | |___ / __/ 
|____/|____/|_____|_____|

'; printf "\e[0m"; sleep 2

sudo apt install -y automake gobjc libudev-dev xa65 build-essential byacc texi2html flex \
                    libreadline-dev libxaw7-dev texinfo libxaw7-dev libgtk2.0-cil-dev \
                    libgtkglext1-dev libpulse-dev bison libnet1 libnet1-dev libpcap0.8 \
                    libpcap0.8-dev libvte-dev libasound2-dev raspberrypi-kernel-headers

Base_dir
mkdir -p ${SRC_DIR}


wget ${SDL2_SOURCE} -O - | tar -xz -C ${SRC_DIR}

cd ${SRC_DIR}/SDL2-2.0.7 && 
./configure --host=arm-raspberry-linux-gnueabihf \
            --disable-video-opengl \
            --disable-video-x11 \
            --disable-pulseaudio \
            --disable-esd \
            --disable-video-mir \
            --disable-video-wayland \
            --enable-video-kmsdrm \
            --enable-alsa \
            --enable-audio &&
make -j3
sudo make install

rm -rf ${SRC_DIR}

}


function Launcher {
    if ! [ -d ${CONF_DIR} ]; then
        cd ../launcher
        sudo mkdir /etc/macintoshpi
        sudo cp -r config/* /etc/macintoshpi
        sudo cp mac /usr/bin
    fi
}


function MacOS_version {
    Base_dir
    VER=$1
    MACOS_DIR=${BASE_DIR}/macos${VER}
    HDD_IMAGE=${HDD_IMAGES}/${VER}/hdd.dsk.gz
    MACOS_CONFIG=${MACOS_DIR}/macos${VER}.cfg
    ROM=${ROM4OS[$1]}
    rm -rf $MACOS_DIR 2>/dev/null
    mkdir $MACOS_DIR 2>/dev/null
    Launcher
}


function logo {

    logotype=( " __  __            _       _            _     "
               "____  _ \n"
               '|  \/  | __ _  ___(_)_ __ | |_ ___  ___| |__ '
               "|  _ \\(_)\n"
               '| |\/| |/ _  |/ __| |  _ \| __/ _ \/ __|  _ \'
               "| |_) | |\n"
               '| |  | | (_| | (__| | | | | || (_) \__ \ | | '
               "|  __/| |\n"
               '|_|  |_|\__,_|\___|_|_| |_|\__\___/|___/_| |_'
               "|_|   |_|\n" 
             );

    clear && echo
    for i in {0..9}; do 
        [ $(($i % 2)) -gt "0" ] && printf "\e[93m" || printf "\e[96m"
        printf "${logotype[${i}]}"
    done
    echo
    for i in {1..47}; do printf ' '; done
    echo "v.${VERSION}"
    printf "\e[0m\n"
}

