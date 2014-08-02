#!/bin/bash

LFS_CONFIG_FILE="lfs_data.config"
source $LFS_CONFIG_FILE

if [ $USER != "root" ]; then
echo "Please run this script as root user only!"
exit 1
fi

rm -fr /home/$LFS_USER

if [ ! $(grep $LFS_HOME /etc/mtab) ]; then
mount $LFS_PARTITION $LFS_HOME
fi

rm -fr $LFS_HOME/*

if [ $(grep $LFS_HOME /etc/mtab) ]; then
umount $LFS_HOME
fi

rm -fr /tools
userdel $LFS_USER
groupdel $LFS_GROUP

rmdir $LFS_HOME

rm $LFS_DATA_FILE
