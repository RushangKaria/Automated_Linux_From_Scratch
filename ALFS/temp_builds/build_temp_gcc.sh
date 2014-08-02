#!/bin/bash -e

LFS_CONFIG_FILE=$1
source $LFS_CONFIG_FILE

TOOL_TEMP_DIR="gcc-build"
TOOL_NAME=$GCC_STRING
TOOL_VERSION=$GCC_VERSION
TOOL_TAR=$GCC_TAR

decompress()
{
tar -xf $TOOL_NAME$TOOL_VERSION$TOOL_TAR
cd $TOOL_NAME$TOOL_VERSION

tar -xf ../$MPFR_STRING$MPFR_VERSION$MPFR_TAR
tar -xf ../$GMP_STRING$GMP_VERSION$GMP_TAR
tar -xf ../$MPC_STRING$MPC_VERSION$MPC_TAR

mv $MPFR_STRING$MPFR_VERSION "mpfr"
mv $GMP_STRING$GMP_VERSION "gmp"
mv $MPC_STRING$MPC_VERSION "mpc"

}

unlink_gcc()
{
for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
    
sed -i '/k prot/agcc_cv_libc_provides_ssp=yes' gcc/configure
}

create_temp_dir()
{
rm -fr ../$TOOL_TEMP_DIR
mkdir ../$TOOL_TEMP_DIR
cd ../$TOOL_TEMP_DIR
}

configure()
{
../$TOOL_NAME$TOOL_VERSION/configure                               \
                                                                   \
--prefix=/tools                                                    \
--target=$LFS_TGT                                                  \
--with-sysroot=$LFS_HOME                                           \
--with-newlib                                                      \
--without-headers                                                  \
--with-local-prefix=/tools                                         \
--with-native-system-header-dir=/tools/include                     \
--disable-nls                                                      \
--disable-shared                                                   \
--disable-multilib                                                 \
--disable-decimal-float                                            \
--disable-threads                                                  \
--disable-libatomic                                                \
--disable-libgomp                                                  \
--disable-libitm                                                   \
--disable-libmudflap                                               \
--disable-libquadmath                                              \
--disable-libsanitizer                                             \
--disable-libssp                                                   \
--disable-libstdc++-v3                                             \
--enable-languages=c,c++                                           \
--with-mpfr-include=$(pwd)/../$TOOL_NAME$TOOL_VERSION/mpfr/src     \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs           

}

compile()
{
make
}

installer()
{
make install
}

link_static()
{
ln -sv libgcc.a `$LFS_TGT-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`
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
    unlink_gcc
    create_temp_dir
    configure
    compile 
    installer
    link_static
    cleanup
    
popd

echo "TEMP_GCC=Y" >> $LFS_DATA_FILE
########################################

