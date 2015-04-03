#!/bin/bash
set -ex

# Remove any Linux kernel packages that we aren't using to boot.
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge

# Clean out any cached interfaces.
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules

# Clean out apt cache, lists, and autoremove any packages.
sudo rm -f /var/lib/apt/lists/lock
sudo rm -f /var/lib/apt/lists/*_*
sudo rm -f /var/lib/apt/lists/partial/*
sudo apt-get -y autoremove
sudo apt-get -y clean

# we get the lists again so we don't get an error message on "apt-get install" immediatelly after book
sudo apt-get update 

# Remove logs from initialization.
sudo rm -f /var/log/*.log /var/log/*.gz /var/log/dmesg*
sudo rm -fr /var/log/syslog /var/log/upstart/*.log /var/log/{b,w}tmp /var/log/udev

# Get rid of bash history.
sudo rm -rf $HOME/.bash_history $HOME/.cache $HOME/.lesshst

# re-enable vagrant insecure SSH key
# https://blog.engineyard.com/2014/building-a-vagrant-box
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
wget --no-check-certificate \
    https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub \
    -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

## Zero out empty sectors with sfill -- this would be much
## faster with zerofree, but would require a custom-compiled
## version of Packer, thus we stick with something that's
## slower, but stock.
#sudo sfill -f -l -l -z /

# changing to dd because "plain" installs may not have "secure-delete" installed
# https://blog.engineyard.com/2014/building-a-vagrant-box
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY

# exit while clearing history file
# http://www.if-not-true-then-false.com/2010/quit-bash-shell-without-saving-bash-history/
rm -f $HISTFILE && unset HISTFILE && exit

