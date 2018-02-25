#!/bin/bash

# http://blog.self.li/post/74294988486/creating-a-post-installation-script-for-ubuntu

# add repos
sudo add-apt-repository -y ppa:webupd8team/atom
sudo add-apt-repository -y ppa:noobslab/themes
sudo add-apt-repository -y ppa:numix/ppa

# sublime text 3
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# basic update
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# install apps
sudo apt-get -y install \
	open-vm-tools open-vm-tools-desktop git \
	libreadline6-dev libcurl4-gnutls-dev libncurses5-dev xorg-dev gcc g++ gfortran perl-modules python-dev make build-essential libx11-dev libxt-dev \
	sublime-text atom \
	gnome-shell-extensions gnome-tweak-tool arc-theme dconf-cli chrome-gnome-shell numix-icon-theme \

# terminal theme
wget -O xt  http://git.io/v3Dlm && chmod +x xt && ./xt && rm xt

# atom packages
apm install city-lights-icons city-lights-ui city-lights-syntax
apm install highlight-selected atom-bracket-highlight
apm install uber-juno

# dirs
mkdir -p ~/Software/heasoft/logs
mkdir ~/Scratch

# setup fstab
echo '.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0' | sudo tee -a /etc/fstab

# exclude due to vm error
echo 'blacklist i2c-piix4' | sudo tee -a /etc/modprobe.d/blacklist.conf

# setup .bashrc
echo '' >> ~/.bashrc
echo '# move julia pkgdir to ~/Scratch' >> ~/.bashrc
echo 'export JULIA_PKGDIR=~/Scratch/.julia' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '# for heasoft/caldb' >> ~/.bashrc
echo 'export HEADAS=~/Software/heasoft/x86_64-unknown-linux-gnu-libc2.26/' >> ~/.bashrc
echo 'export CALDB=~/Software/caldb/' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '# for pipeline.sh' >> ~/.bashrc
echo 'export NU_ARCHIVE_LIVE=/home/robert/Scratch/.nustar_archive/' >> ~/.bashrc
echo 'export NU_ARCHIVE_CL_LIVE=/home/robert/Scratch/.nustar_archive_cl/' >> ~/.bashrc
echo 'export NU_ARCHIVE=/mnt/hgfs/.nustar_archive/' >> ~/.bashrc
echo 'export NU_ARCHIVE_CL=/mnt/hgfs/.nustar_archive_cl/' >> ~/.bashrc

# setup .bash_aliases
echo 'HEADAS=~/Software/heasoft/x86_64-unknown-linux-gnu-libc2.26/' >> ~/.bash_aliases
echo 'export HEADAS' >> ~/.bash_aliases
echo 'alias heainit=". $HEADAS/headas-init.sh"' >> ~/.bash_aliases
echo '' >> ~/.bash_aliases
echo 'CALDB=~/Software/caldb' >> ~/.bash_aliases
echo 'export CALDB' >> ~/.bash_aliases
echo 'alias caldbinit="source $CALDB/software/tools/caldbinit.sh"' >> ~/.bash_aliases

# manual
echo 'set up vmware shared folders'
echo 'compile/install heasoft and caldb'
echo ''
echo 'gparted format sdb1'
echo 'set up sdb1 scratch: https://ubuntuforums.org/showthread.php?t=1145596'
echo 'link julia with sudo ln -s ~/Scratch/julia-d386e40c17/bin/julia /usr/local/bin'
echo ''

# heasoft config
# ./configure --prefix="/home/robert/Software/heasoft" >& config.out & tail -f config.out
# mv ./config.out ~/Software/heasoft/logs

# make >& build.log & tail -f build.log
# mv ./build.log ~/Software/heasoft/logs

# make install >& install.log & tail -f install.log
# mv ./install.log ~/Software/heasoft/logs
