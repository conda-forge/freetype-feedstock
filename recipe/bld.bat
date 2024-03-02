set CXXFLAGS=
set CFLAGS=

mkdir %SRC_DIR%\stage

mkdir build
cd build

:: Configure.
cmake -G"Ninja" ^
      -DCMAKE_INSTALL_PREFIX:PATH=%SRC_DIR%\stage ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%:/=\\" ^
      -DCMAKE_SYSTEM_PREFIX_PATH="%LIBRARY_PREFIX:/=\\%" ^
      -DBUILD_SHARED_LIBS:BOOL=true ^
      -DFT_WITH_BZIP2=False ^
      -DFT_WITH_HARFBUZZ=False ^
      -DCMAKE_DISABLE_FIND_PACKAGE_BZip2=True ^
      -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=True ^
      -DFT_WITH_ZLIB=True ^
      -DFT_WITH_PNG=True ^
      -DFT_WITH_BROTLI=False ^
      "%SRC_DIR:/=\\%"
if errorlevel 1 exit 1

:: Build.
ninja install
if errorlevel 1 exit 1

:: Test.
ctest -C Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Move everything 1-level down.
move %SRC_DIR%\stage\include\freetype2\freetype %SRC_DIR%\stage\include || exit 1
move %SRC_DIR%\stage\include\freetype2\ft2build.h %SRC_DIR%\stage\include || exit 1

:: vs2008 created libfreetype.dll instead of freetype.dll
set LIB="%SRC_DIR%\stage\bin\libfreetype.dll"
if exist %LIB% (copy %LIB% %SRC_DIR%\stage\bin\freetype.dll) || exit 1

setlocal EnableExtensions ENABLEDELAYEDEXPANSION
for %%f in ( "%SRC_DIR%\stage\lib\pkgconfig\*.pc" ) do (
    sed -i.bak "s,prefix=.*,prefix=/opt/anaconda1anaconda2anaconda3/Library,g" %%f
    del %%f.bak
)
endlocal
