#!/bin/bash -e

LFS_CONFIG_FILE=$1
source $LFS_CONFIG_FILE

TOOL_TEMP_DIR="glibc-build"
TOOL_NAME=$GLIBC_STRING
TOOL_VERSION=$GLIBC_VERSION
TOOL_TAR=$GLIBC_TAR

decompress()
{
tar -xf $TOOL_NAME$TOOL_VERSION$TOOL_TAR
cd $TOOL_NAME$TOOL_VERSION
}

check_rpc_headers()
{
    if [ ! -r /usr/include/rpc/types.h ]; then
        su -c 'mkdir -pv /usr/include/rpc'
        su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
    fi
}

create_temp_dir()
{
rm -fr ../$TOOL_TEMP_DIR
mkdir ../$TOOL_TEMP_DIR
cd ../$TOOL_TEMP_DIR
}

configure()
{
../$TOOL_NAME$TOOL_VERSION/configure                                \
                                                                    \
--prefix=/tools                                                     \
--host=$LFS_TGT                                                     \
--build=$(../$TOOL_NAME$TOOL_VERSION/scripts/config.guess)          \
--disable-profile                                                   \
--enable-kernel=2.6.32                                              \
--with-headers=/tools/include                                       \
libc_cv_forced_unwind=yes                                           \
libc_cv_ctors_header=yes                                            \
libc_cv_c_cleanup=yes                                               
       
}

compile()
{
make
}

installer()
{
make install
}

cleanup()
{
cd $LFS_SOURCES
rm -fr $TOOL_NAME$TOOL_VERSION
rm -fr $TOOL_TEMP_DIR
}

#########################################
pushd $LFS_SOURCES
echo "starting to build " $TOOL_NAME$TOOL_VERSION " for " $LFS_TGT

    decompress
    check_rpc_headers
    create_temp_dir
    configure
    compile 
    installer
    cleanup
    
popd

echo "TEMP_GLIBC=Y" >> $LFS_DATA_FILE
########################################

