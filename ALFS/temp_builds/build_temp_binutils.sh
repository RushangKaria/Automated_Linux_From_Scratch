#!/bin/bash -e

LFS_CONFIG_FILE=$1
source $LFS_CONFIG_FILE

TOOL_TEMP_DIR="binutils-build"
TOOL_NAME=$BINUTILS_STRING
TOOL_VERSION=$BINUTILS_VERSION
TOOL_TAR=$BINUTILS_TAR


decompress()
{
tar -xf $TOOL_NAME$TOOL_VERSION$TOOL_TAR
}

create_temp_dir()
{

rm -fr $TOOL_TEMP_DIR
mkdir $TOOL_TEMP_DIR

cd $TOOL_TEMP_DIR
}

configure()
{
../$TOOL_NAME$TOOL_VERSION/configure  \
                                                \
--prefix=/tools                                 \
--with-sysroot=$LFS_HOME                        \
--with-lib-path=/tools/lib                      \
--target=$LFS_TGT                               \
--disable-nls                                   \
--disable-werror

}

compile()
{
make
}

create_links()
{
     case $(uname -m) in
       x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
     esac
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
echo "starting to build " $TOOL_NAME$TOOL_VERSION
    
    decompress
    create_temp_dir
    configure
    compile 
    create_links
    installer
    cleanup
    
popd

echo "TEMP_BINUTILS=Y" >> $LFS_DATA_FILE
########################################

