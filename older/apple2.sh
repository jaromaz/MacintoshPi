#!/bin/bash
# --------------------------------------------------------
# MacintoshPi
# --------------------------------------------------------
# Author: Jaroslaw Mazurkiewicz  /  jaromaz
# www: https://jm.iq.pl  e-mail: jm at iq.pl
# --------------------------------------------------------
# Apple ][ Computer emulator - linapple
# --------------------------------------------------------


source ../assets/func.sh
clear; printf "\e[92m"; echo '
    _                _        __ __
   / \   _ __  _ __ | | ___  |_ | _|
  / _ \ |  _ \|  _ \| |/ _ \  | | |
 / ___ \| |_) | |_) | |  __/  | | |
/_/   \_\ .__/| .__/|_|\___|  | | |
        |_|   |_|            |__|__|
';

for i in {1..17}; do printf ' '; done
echo "MacintoshPi v.${VERSION}"
printf "\e[0m\n\n";

usercheck

cat <<EOF 
This script will install and configure the Apple ][ computer
emulator - linapple.

EOF

updateinfo
Base_dir
Asoft

L_DIR=$BASE_DIR/linapple
B_DIR=$L_DIR/build/bin

sudo rm -rf $L_DIR 2>/dev/null

sudo apt-get install -y git build-essential libzip-dev libsdl1.2-dev libsdl-image1.2-dev \
                        libcurl4-openssl-dev zlib1g-dev imagemagick

[ $? -ne 0 ] && net_error "Apple ][ linapple apt packages"

git clone https://github.com/linappleii/linapple.git $L_DIR

[ $? -ne 0 ] && net_error "Apple ][ linapple git repo"

cd $L_DIR

echo "$B_DIR/linapple --autoboot --conf $L_DIR/linapple.conf --d1 $L_DIR/build/share/linapple/Master.dsk" | \
      sudo tee /usr/bin/apple2
sudo chmod 755 /usr/bin/apple2

make -e REGISTRY_WRITEABLE=1

[ -f "$BASE_DIR/asoft/lina.dsk" ] && cp $BASE_DIR/asoft/lina.dsk $L_DIR/build/share/linapple/Master.dsk

cat << EOF > $L_DIR/linapple.conf
Computer Emulation = 3
Keyboard Type = 0
Keyboard Rocker Switch = 0
Sound Emulation = 1
Soundcard Type = 2
Joystick 0 = 2
Joystick 1 = 0
Joy0Index   = 0
Joy1Index   = 1
Joy0Button1 = 0
Joy0Button2 = 1
Joy1Button1 = 0
Joy0Axis0   = 0
Joy0Axis1   = 1
Joy1Axis0   = 0
Joy1Axis1   = 1
JoyExitEnable   = 0
JoyExitButton0  = 8
JoyExitButton1  = 9
Serial Port = 0
Emulation Speed = 10
Enhance Disk Speed = 1
Video Emulation = 5
Monochrome Color = #C0C0C0
Singlethreaded = 0
Mouse in slot 4 = 0
Printer idle limit = 10
Append to printer file = 1
Harddisk Enable = 0
Clock Enable = 4
Slot 6 Autoload = 0
Save State On Exit = 0
Fullscreen = 0
Boot at Startup = 1
Show Leds = 0
FTP Server    = ftp://ftp.apple.asimov.net/pub/apple_II/images/games/
FTP ServerHDD = ftp://ftp.apple.asimov.net/pub/apple_II/images/
FTP UserPass  = anonymous:my-mail@mail.com
Screen factor = 2.0
# Screen Width  = 560
# Screen Height = 384
EOF
echo "* done"

