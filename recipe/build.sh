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
sed -i.bak "s,$SRC_DIR/stage,/opt/anaconda1anaconda2anaconda3,g" $SRC_DIR/stage/lib/pkgconfig/*.pc
rm $SRC_DIR/stage/lib/pkgconfig/*.bak

# Use placeholder for stage paths in freetype-config
sed -i.bak "s,$SRC_DIR/stage,$PREFIX,g" $SRC_DIR/stage/bin/freetype-config
# Use conda pkg-config
sed -i.bak "s,/usr/bin/,$PREFIX/bin/,g" $SRC_DIR/stage/bin/freetype-config
rm $SRC_DIR/stage/bin/freetype-config.bak
