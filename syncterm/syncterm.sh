#!/bin/bash

printf "\e[92m"; echo '
 ____                  _____ _____ ____  __  __ 
/ ___| _   _ _ __   __|_   _| ____|  _ \|  \/  |
\___ \| | | |  _ \ / __|| | |  _| | |_) | |\/| |
 ___) | |_| | | | | (__ | | | |___|  _ <| |  | |
|____/ \__, |_| |_|\___||_| |_____|_| \_\_|  |_|
       |___/                                    
'; printf "\e[0m"; sleep 2
BDIR=~/syncterm-build
mkdir $BDIR
sudo apt update && sudo apt -y upgrade
sudo apt install -y libncurses5-dev libsdl1.2-dev build-essential libsdl2-dev

wget https://sourceforge.net/projects/syncterm/files/syncterm/syncterm-1.1/syncterm-1.1-src.tgz/download -O $BDIR/syncterm.tgz

cd $BDIR

tar -xf syncterm.tgz
cd syncterm-1.1/src/syncterm
sudo make USE_SDL=1 NO_X=1
sudo make install
cd /
sleep 2
sudo rm -rf $BDIR

printf "\e[92m";
echo *** all done ***
printf "\e[0m";

