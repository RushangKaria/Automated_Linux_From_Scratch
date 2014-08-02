#!/bin/bash -e

LFS_CONFIG_FILE=$1
source $LFS_CONFIG_FILE

TOOL_NAME=$LINUX_API_STRING
TOOL_VERSION=$LINUX_API_VERSION
TOOL_TAR=$LINUX_API_TAR

decompress()
{
tar -xf $TOOL_NAME$TOOL_VERSION$TOOL_TAR
cd $TOOL_NAME$TOOL_VERSION
}

clean()
{
make mrproper
}

headers_check()
{
make headers_check
}

installer()
{
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
}

cleanup()
{
cd $LFS_SOURCES
rm -fr $TOOL_NAME$TOOL_VERSION
}

#########################################
pushd $LFS_SOURCES
echo "starting to build " $TOOL_NAME$TOOL_VERSION

    decompress
    clean
    headers_check
    installer
    cleanup
    
popd

echo "TEMP_LINUX_API=Y" >> $LFS_DATA_FILE
########################################

