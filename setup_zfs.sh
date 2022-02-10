#!/bin/bash


# https://www.centos.org/centos-linux-eol/
# so this is workaround to use vault 
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

yum install -y yum-utils

dnf install -y https://zfsonlinux.org/epel/zfs-release.el8_5.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum install -y zfs
modprobe zfs


# enable bash completion

cd /usr/share/bash-completion/completions/
curl -O https://raw.githubusercontent.com/openzfs/zfs/zfs-0.8-release/contrib/bash_completion.d/zfs
chmod +x zfs


