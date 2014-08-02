#!/bin/bash -e

LFS_CONFIG_FILE=$1
source $LFS_CONFIG_FILE

if [ ! $(grep "TEMP_BINUTILS=Y" $LFS_DATA_FILE) ]; then
$TEMP_TOOLCHAIN_BUILD_DIR/build_temp_binutils.sh `pwd`/$LFS_CONFIG_FILE
fi 

if [ ! $(grep "TEMP_GCC=Y" $LFS_DATA_FILE) ]; then
$TEMP_TOOLCHAIN_BUILD_DIR/build_temp_gcc.sh `pwd`/$LFS_CONFIG_FILE
fi

if [ ! $(grep "TEMP_LINUX_API=Y" $LFS_DATA_FILE) ]; then
$TEMP_TOOLCHAIN_BUILD_DIR/build_temp_linux_api.sh `pwd`/$LFS_CONFIG_FILE
fi

if [ ! $(grep "TEMP_GLIBC=Y" $LFS_DATA_FILE) ]; then
$TEMP_TOOLCHAIN_BUILD_DIR/build_temp_glibc.sh `pwd`/$LFS_CONFIG_FILE
fi
