#!/bin/sh

export RELEASE=$(date +"%Y%m%d")
echo "RELEASE=$RELEASE" >> "$GITHUB_OUTPUT"

curl -L http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz --output archlinux.tar.gz
mkdir dump
sudo tar -xzf archlinux.tar.gz -C dump

cat <<- EOF | sudo unshare -mpf bash -e -
rm -f "./dump/etc/resolv.conf"
echo "nameserver 1.1.1.1" > "./dump/etc/resolv.conf"
sed -i 's/^#DisableSandbox/DisableSandbox/' "./dump/etc/pacman.conf"
mount --bind "./dump" "./dump"
mount --bind /dev "./dump/dev"
mount --bind /proc "./dump/proc"
mount --bind /sys "./dump/sys"
#chroot "./dump" useradd -r -s /usr/bin/nologin -d /var/lib/pacman alpm
chroot "./dump" pacman-key --init
chroot "./dump" pacman-key --populate archlinuxarm
chroot "./dump" pacman -Rnsc --noconfirm linux-$ARCH linux-firmware
chroot "./dump" pacman -Syu --noconfirm
chroot "./dump" pacman -Sy --noconfirm ca-certificates sudo dbus systemd mesa-utils
chroot "./dump" rm -f /var/cache/pacman/pkg/*
chroot ./dump sed -i 's/^# \(en_US.UTF-8\)/\1/' /etc/locale.gen
chroot ./dump locale-gen
chroot ./dump localectl set-locale LANG=en_US.UTF-8
sed -i 's/#DisableSandbox/DisableSandbox/' "./dump/etc/pacman.conf"
EOF

sudo cp ./wslconf/oobe.sh ./dump/etc/oobe.sh
sudo chmod 644 ./dump/etc/oobe.sh
sudo chmod +x ./dump/etc/oobe.sh
sudo cp ./wslconf/wsl.conf ./dump/etc/wsl.conf
sudo chmod 644 ./dump/etc/wsl.conf
sudo cp ./wslconf/wsl-distribution.conf ./dump/etc/wsl-distribution.conf
sudo chmod 644 ./dump/etc/wsl-distribution.conf
sudo mkdir -p ./dump/usr/lib/wsl/
sudo cp ./wslconf/icon.ico ./dump/usr/lib/wsl/icon.ico
          
cd $GITHUB_WORKSPACE/dump
sudo tar --numeric-owner --absolute-names -c  * | gzip --best > ../install.tar.gz
mv ../install.tar.gz ../archlinuxarm.wsl
