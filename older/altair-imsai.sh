#!/bin/bash
# --------------------------------------------------------
# MacintoshPi
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
# Altair 8800, IMSAI 8080, CP/M emulator - z80pack
# --------------------------------------------------------

source ../assets/func.sh
clear; printf "\e[92m"; echo '

    _    _ _        _         ___      ___ __  __ ____    _    ___
   / \  | | |_ __ _(_)_ __   ( _ )    |_ _|  \/  / ___|  / \  |_ _|
  / _ \ | | __/ _` | |  __|  / _ \/\   | || |\/| \___ \ / _ \  | |
 / ___ \| | || (_| | | |    | (_>  <   | || |  | |___) / ___ \ | |
/_/   \_\_|\__\__,_|_|_|     \___/\/  |___|_|  |_|____/_/   \_\___|
'; 
for i in {1..48}; do printf ' '; done
echo "MacintoshPi v.${VERSION}"
printf "\e[0m\n\n";

usercheck

cat <<EOF 
This script will install and configure the Altair 8800
and IMSAI 8080 computers emulator - z80pack.

EOF
updateinfo
Base_dir
Z_DIR=$BASE_DIR/z80pack
sudo rm -rf $Z_DIR 2>/dev/null
Asoft

git clone --depth 1 --branch dev https://github.com/udo-munk/z80pack.git $Z_DIR

[ $? -ne 0 ] && net_error "z80pack git"

sudo apt install -y gcc libncurses5-dev liblua5.3-dev git make zip unzip libjpeg-dev \
	            git libpthread-stubs0-dev libxmu-dev mesa-common-dev z80asm \
                    libglu1-mesa-dev freeglut3-dev build-essential

[ $? -ne 0 ] && net_error "Altair/IMSAI apt packages"

# sudo apt install -y g++ libjpeg9-dev libglu1-mesa-dev libxmu-dev
# sudo apt install x11-common

printf "\e[92m"; echo '

  ____ ____   ____  __
 / ___|  _ \ / /  \/  |
| |   | |_) / /| |\/| |
| |___|  __/ / | |  | |
 \____|_| /_/  |_|  |_|

               Step 1/3

'; printf "\e[0m"; sleep 2


cd $Z_DIR/cpmsim/srcsim
make -f Makefile.linux
make -f Makefile.linux clean
mkdir ~/bin
cd $Z_DIR/cpmsim/srctools
make
sudo cp mkdskimg bin2hex send receive ptp2bin /usr/bin
make clean

echo "cd $Z_DIR/cpmsim && ./cpm2" | sudo tee /usr/bin/cpm
sudo chmod 755 /usr/bin/cpm


printf "\e[92m"; echo '

    _    _ _        _ 
   / \  | | |_ __ _(_)_ __
  / _ \ | | __/ _` | |  __|
 / ___ \| | || (_| | | |
/_/   \_\_|\__\__,_|_|_|

                   Step 2/3

'; printf "\e[0m"; sleep 2


cd $Z_DIR/webfrontend/civetweb
make

cd $Z_DIR/frontpanel
make -f Makefile.linux
sudo cp libfrontpanel.so /usr/lib/

cd $Z_DIR/altairsim/srcsim

make -f Makefile.linux
make -f Makefile.linux clean

echo "cd $Z_DIR/altairsim && ./cpm22" | sudo tee /usr/bin/altair
sudo chmod 755 /usr/bin/altair

printf "\e[92m"; echo '

 ___ __  __ ____    _    ___
|_ _|  \/  / ___|  / \  |_ _|
 | || |\/| \___ \ / _ \  | |
 | || |  | |___) / ___ \ | |
|___|_|  |_|____/_/   \_\___|

                     Step 3/3

'; printf "\e[0m"; sleep 2


cd $Z_DIR/imsaisim/srcsim
sed -i 's/\/\*#define HAS_NETSERVER\*\//#define HAS_NETSERVER/g' sim.h
make -f Makefile.linux
make -f Makefile.linux clean
cd ..
rm conf
ln -s conf_2d conf
echo "cd $Z_DIR/imsaisim && ./cpm22" | sudo tee /usr/bin/imsai
echo "cd $Z_DIR/imsaisim && ./imsaisim -x roms/xybasic.hex" | \
    sudo tee /usr/bin/imsaibasic
sudo chmod 755 /usr/bin/imsai*
echo "* done"
