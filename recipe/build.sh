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
            --enable-freetype-config

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
