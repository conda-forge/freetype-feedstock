#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./builds/unix

mkdir $SRC_DIR/stage

./configure --prefix=${SRC_DIR}/stage \
            --with-zlib=yes \
            --with-png=yes \
            --without-harfbuzz \
            --with-bzip2=no \
            --with-brotli=no \
            --enable-freetype-config \
            --disable-static

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" || "$CROSSCOMPILING_EMULATOR" != "" ]]; then
    make check
fi
make install

# Remove Requires.private as it is not needed for shared libraries.
# A pkg-config bug requires the Requires.private pc files to be
# present even for shared build
sed -i.bak '/^Requires\.private/d' $SRC_DIR/stage/lib/pkgconfig/freetype2.pc
rm $SRC_DIR/stage/lib/pkgconfig/freetype2.pc.bak
