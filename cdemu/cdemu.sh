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
# CDemu auto-compile/install script 
# ---------------------------------

printf "\e[92m"; echo '
  ____ ____  _____                 
 / ___|  _ \| ____|_ __ ___  _   _ 
| |   | | | |  _| |  _ ` _ \| | | |
| |___| |_| | |___| | | | | | |_| |
 \____|____/|_____|_| |_| |_|\__,_|
'; printf "\e[0m"; sleep 2

source ./assets/func.sh
updateinfo

# Software
sudo apt-get install -y dpkg-dev dkms libao-dev intltool libsndfile1-dev libbz2-dev \
                        liblzma-dev gtk-doc-tools gobject-introspection libgirepository1.0-dev \
                        python3-matplotlib libsamplerate0-dev cmake raspberrypi-kernel-headers \
                        dh-systemd

[ $? -ne 0 ] && net_error "CDEmu apt packages"

# CDemu git repo
rm -rf ~/cdemusrc
git clone -b 'vhba-module-20210418' --single-branch --depth 1 https://github.com/cdemu/cdemu.git ~/cdemusrc
[ $? -ne 0 ] && net_error "CDEmu sources"

# vhba-module
cd ~/cdemusrc/vhba-module
dpkg-buildpackage -b -uc -tc
cd ..
sudo dpkg -i vhba-dkms*.deb


# libmirage
cd ~/cdemusrc/libmirage
dpkg-buildpackage -b -uc -tc
cd ..
sudo dpkg -i libmirage11*.deb
sudo dpkg -i gir1.2-mirage*.deb
sudo dpkg -i libmirage11-dev*.deb


# cdemu-daemon
cd ~/cdemusrc/cdemu-daemon
dpkg-buildpackage -b -uc -tc
cd ..
sudo dpkg -i cdemu-daemon_*.deb
sudo dpkg -i cdemu-daemon-dbg*.deb


# cdemu-client
cd ~/cdemusrc/cdemu-client
dpkg-buildpackage -b -uc -tc
cd ..
sudo dpkg -i cdemu-client_*.deb


# image-analyzer
cd ~/cdemusrc/image-analyzer
dpkg-buildpackage -b -uc -tc
cd ..
sudo dpkg -i image-analyzer_*.deb

cd ~/
rm -rf ~/cdemusrc

cat << EOF > /tmp/cdload
#!/bin/sh
echo "CD/DVD device: /dev/sr0"
cdemu load 0 \$1
cdemu status
EOF

cat << EOF > /tmp/cdunload
#!/bin/sh
echo "CD/DVD device: /dev/sr0"
cdemu unload 0
cdemu status
EOF


chmod 755 /tmp/cdload /tmp/cdunload
sudo mv /tmp/cd*oad /usr/bin

echo "** all done **"

