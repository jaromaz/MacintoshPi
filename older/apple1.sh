#!/bin/bash
# --------------------------------------------------------
# MacintoshPi
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
# Apple 1 Computer emulator - pom1
# --------------------------------------------------------


source ../assets/func.sh
clear; printf "\e[92m"; echo '
    _                _         ___
   / \   _ __  _ __ | | ___   |_ _|
  / _ \ |  _ \|  _ \| |/ _ \   | |
 / ___ \| |_) | |_) | |  __/   | |
/_/   \_\ .__/| .__/|_|\___|  |___|
        |_|   |_| 
';

for i in {1..16}; do printf ' '; done
echo "MacintoshPi v.${VERSION}"
printf "\e[0m\n\n"

usercheck

cat <<EOF 
This script will install and configure the Apple 1 computer
emulator - pom1.

EOF

updateinfo
Base_dir
Asoft
Src_dir
sudo apt install -y git build-essential libtool autoconf libsdl1.2-dev

[ $? -ne 0 ] && net_error "Apple 1 apt packages"

git clone --depth 1 --branch pom1-1.0.0 https://github.com/anarkavre/pom1.git $SRC_DIR/pom1

[ $? -ne 0 ] && net_error "Apple 1 - pom1 emulator git repo"

cd $SRC_DIR/pom1
sed -i 's/_scanlines = 0, terminalSpeed = 60/_scanlines = 1, terminalSpeed = 30/g' src/screen.c
libtoolize --force
aclocal
autoheader
automake --force-missing --add-missing
autoconf
./configure
make
sudo make install
cd ~/
rm -rf $SRC_DIR
echo pom1 | sudo tee /usr/bin/apple1
sudo chmod 755 /usr/bin/apple1
echo "* done"

