#!/bin/bash

lower_case=$(echo "$1" | tr '[:upper:]' '[:lower:]')
 
if [ -z $1 ]; then 
	echo Need to provide platform. Possible platforms are linux, macosx, ios. Exiting!
	exit 
fi

CINDER_ROOT_DIR=""
if [ -z $2 ]; then
	CINDER_ROOT_DIR=`pwd`/../../../..
	echo Building with normal cinder dir...${CINDER_ROOT_DIR}.
else
	CINDER_ROOT_DIR=${2}
	echo Building with user specified cinder dir...${CINDER_ROOT_DIR}.
fi

#########################
## create prefix dirs
#########################

PANGO_BASE_DIR=`pwd`/..

PREFIX_BASE_DIR=${PANGO_BASE_DIR}/install/tmp

PREFIX_FONTCONFIG=${PREFIX_BASE_DIR}/fontconfig_install
rm -rf ${PREFIX_FONTCONFIG}
mkdir -p ${PREFIX_FONTCONFIG}

PREFIX_LIBFFI=${PREFIX_BASE_DIR}/libffi_install
rm -rf ${PREFIX_LIBFFI}
mkdir -p ${PREFIX_LIBFFI}

PREFIX_GETTEXT=${PREFIX_BASE_DIR}/gettext_install
rm -rf ${PREFIX_GETTEXT}
mkdir -p ${PREFIX_GETTEXT}

PREFIX_GLIB=${PREFIX_BASE_DIR}/glib_install
rm -rf ${PREFIX_GLIB}
mkdir -p ${PREFIX_GLIB}

PREFIX_PANGO=${PREFIX_BASE_DIR}/pango_install
rm -rf ${PREFIX_PANGO}
mkdir -p ${PREFIX_PANGO}

#########################
## create final path
#########################

FINAL_PATH=`pwd`/..
FINAL_LIB_PATH=${FINAL_PATH}/lib/${lower_case}
rm -rf ${FINAL_LIB_PATH}
mkdir -p ${FINAL_LIB_PATH}
 
FINAL_INCLUDE_PATH=${FINAL_PATH}/include/${lower_case}
rm -rf ${FINAL_INCLUDE_PATH}
mkdir -p ${FINAL_INCLUDE_PATH}

##########################
## cinder paths for cairo
##########################

CAIRO_BASE_DIR=${CINDER_ROOT_DIR}/blocks/Cairo
CAIRO_LIB_PATH=${FINAL_LIB_PATH}
CAIRO_INCLUDE_PATH=${FINAL_INCLUDE_PATH}/cairo
# make sure it's the correct version
echo "Setting up cairo flags..."

#############################
## cinder paths for harfbuzz
#############################

check_harfbuzz_dir=${CINDER_ROOT_DIR}/blocks/Cinder-Harfbuzz
HARFBUZZ_BASE_DIR=""
if [ -d ${check_harfbuzz_dir} ]; then
	echo Using Cinder Root harfbuzz block
  HARFBUZZ_BASE_DIR=${check_harfbuzz_dir}
else
	check_harfbuzz_dir=`pwd`/../../Cinder-Harfbuzz
	if [ ! -d ${check_harfbuzz_dir} ]; then
		echo "Can't find Harfbuzz cinder block. Exiting!"
		exit
	fi
  echo "Using relative harfbuzz block."
  HARFBUZZ_BASE_DIR=${check_harfbuzz_dir}
fi

HARFBUZZ_LIB_PATH=${FINAL_LIB_PATH}
HARFBUZZ_INCLUDE_PATH=${FINAL_INCLUDE_PATH}/harfbuzz
echo "Setting up Harfbuzz flags..."

#########################
## different archs
#########################

buildOSX() 
{
  echo Building OSX...

  buildLibffi
  export LDFLAGS="${LDFLAGS} -framework AppKit -framework CoreText -framework CoreFoundation -framework CoreGraphics -framework Carbon"
 
  buildGettext
	export LDFLAGS="${LDFLAGS} -L${PREFIX_GETTEXT}/lib -lintl -lgettextpo -lasprintf"
  buildGlib 

  downloadFontconfig
  buildFontconfig
  export FONTCONFIG_CFLAGS="-I${PREFIX_FONTCONFIG}/include"
  export FONTCONFIG_LIBS="-L${PREFIX_FONTCONFIG}/lib -lfontconfig"
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX_FONTCONFIG}/lib/pkgconfig:${PREFIX_BASE_DIR}/freetype/pkgconfig"

  buildCairoForPango
  export CAIRO_CFLAGS="-I${CAIRO_INCLUDE_PATH}"
  export CAIRO_LIBS="-L${CAIRO_LIB_PATH} -lcairo -lpixman-1 -lpng "

  buildHarfbuzzForPango
  export HARFBUZZ_CFLAGS="-I${HARFBUZZ_INCLUDE_PATH}"
  export HARFBUZZ_LIBS="-L${HARFBUZZ_LIB_PATH} -lharfbuzz -lharfbuzz-gobject"

  createFreetypePC
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX_BASE_DIR}/freetype/pkgconfig"  
  
  buildPango
}

buildLinux() 
{
  echo Building Linux...

  buildLibffi
  buildGettext
	
  export LDFLAGS="${LDFLAGS} -L${PREFIX_GETTEXT}/lib -lgettextpo -lasprintf"
  buildGlib 

  export FONTCONFIG_CFLAGS="-I/usr/include"
  export FONTCONFIG_LIBS="-L/usr/lib/x86_64-linux-gnu -lfontconfig"
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:usr/lib/x86_64-linux-gnu/pkgconfig:${PREFIX_BASE_DIR}/freetype/pkgconfig"
  
	buildCairoForPango
	export CAIRO_CFLAGS="-I${CAIRO_INCLUDE_PATH}"
  export CAIRO_LIBS="-L${CAIRO_LIB_PATH} -lcairo -lpixman-1 -lpng -L${CINDER_LIB_DIR} -lcinder"

  buildHarfbuzzForPango 
  export HARFBUZZ_CFLAGS="-I${HARFBUZZ_INCLUDE_PATH}"
  export HARFBUZZ_LIBS="-L${HARFBUZZ_LIB_PATH} -lharfbuzz -lharfbuzz-gobject -lharfbuzz-icu"
  
  createFreetypePC
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${PREFIX_BASE_DIR}/freetype/pkgconfig"  
  
	buildPango
}

#########################
## downloading libs
#########################

downloadFontconfig()
{
  echo Downloading fontconfig...
  curl https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.1.tar.gz -o fontconfig.tar.gz
  tar -xf fontconfig.tar.gz
  mv fontconfig-* fontconfig
  rm fontconfig.tar.gz
  echo Finished Downloading fontconfig...
}

downloadLibffi()
{
	echo Downloading libffi...
  curl ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz -o libffi.tar.gz
  tar -xf libffi.tar.gz
  mv libffi-* libffi
  rm libffi.tar.gz
  echo Finished Downloading libffi...
}

downloadGettext()
{
	echo Downloading gettext...
  curl ftp://ftp.gnu.org/pub/gnu/gettext/gettext-latest.tar.gz -o gettext.tar.gz
  tar -xf gettext.tar.gz
  mv gettext-* gettext
  rm gettext.tar.gz
  echo Finished Downloading gettext...
}

downloadGlib()
{
	echo Downloading Glib...
	curl -o glib.tar.xz ftp://ftp.gnome.org/pub/GNOME/sources/glib/2.50/glib-2.50.0.tar.xz
	tar xf glib.tar.xz
	mv glib-* glib
  rm glib.tar.xz
	echo Finished downloading glib...
}

downloadPango() 
{
	echo Downloading Pango
	curl -o pango.tar.xz http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-1.40.0.tar.xz
	tar xf pango.tar.xz
	mv pango-* pango
  rm pango.tar.xz
  echo Finished downloading Pango...
}

createFreetypePC()
{
  rm -rf freetype/pkgconfig
  mkdir -p freetype/pkgconfig
 
  echo "prefix=`pwd`/../../../..
  exec_prefix=${prefix}
  libdir=${prefix}/lib/macosx/Release
  includedir=/${prefix}/include/freetype

  Name: FreeType 2
  URL: http://freetype.org
  Description: A free, high-quality, and portable font engine.
  Version: 18.6.12
  Requires:
  Requires.private: 
  Libs: -L${libdir} -lcinder
  Cflags: -I${includedir}" >> freetype/pkgconfig/freetype2.pc
}

buildFontconfig()
{
  cd fontconfig

  echo "==================================================================="
  echo "Building and installing fontconfig, ${PREFIX_FONTCONFIG}"
  echo "==================================================================="
  
  PREFIX=${PREFIX_FONTCONFIG}

  ./configure --prefix=${PREFIX} --enable-static=yes --enable-shared=no

  make -j 6
  make install
  make clean
 
  cp -r ${PREFIX}/include/* ${FINAL_INCLUDE_PATH}
  cp ${PREFIX}/lib/*.a ${FINAL_LIB_PATH}

  cd ..
}

buildLibffi()
{
  cd libffi
  
  echo "==================================================================="
  echo "Building and installing libffi"
  echo "==================================================================="
  
  PREFIX=${PREFIX_LIBFFI}
    
  ./configure --prefix=${PREFIX}

  make -j 6
  make install
  make clean

  cp ${PREFIX}/lib/*.a ${FINAL_LIB_PATH}

  cd ..
}

buildGettext()
{
  cd gettext
  
  echo "==================================================================="
  echo "Building and installing gettext"
  echo "==================================================================="
  
  PREFIX=${PREFIX_GETTEXT}
  HOST=$1
  if [ -z "${HOST}"]; then
    ./configure --prefix=${PREFIX} --disable-java --without-emacs --disable-native-java --disable-openmp 
  else
    ./configure --host=${HOST} --prefix=${PREFIX} --disable-java --without-emacs --disable-native-java --disable-openmp 
  fi

  make -j 6
  make install
  make clean

  cp -r ${PREFIX}/include/* ${FINAL_INCLUDE_PATH}
  cp ${PREFIX}/lib/*.a ${FINAL_LIB_PATH}
  
  cd ..
}

buildGlib()
{
  cd glib
  
  echo "==================================================================="
  echo "Building glib, and installing $1"
  echo "==================================================================="
  
  PREFIX=$PREFIX_GLIB
  HOST=$1
  echo "Passed in $HOST"
  if [ -z "$HOST" ]; then
    ./configure --disable-shared --prefix=${PREFIX} --disable-gtk-doc-html --disable-installed-tests --disable-always-build-tests
  else
    echo Building with cross-compile
    ./configure --host=${HOST} --disable-shared --prefix=${PREFIX} --disable-gtk-doc-html --disable-installed-tests --disable-always-build-tests
  fi

  make -j 6
  make install
  make clean

  cp -r ${PREFIX}/include/* ${FINAL_INCLUDE_PATH}
  cp ${PREFIX}/lib/*.a ${FINAL_LIB_PATH}
  cp ${PREFIX}/lib/glib-2.0/include/* ${FINAL_INCLUDE_PATH}/glib-2.0

  cd ..
}

buildCairoForPango()
{
  # need to test for existence and quit
  cd ${CAIRO_BASE_DIR}/install
  
  echo "==================================================================="
  echo "Building Cairo"
  echo "==================================================================="
  
  ./install.sh ${lower_case} --with-pango ${PANGO_BASE_DIR}

  cd ${PANGO_BASE_DIR}/install/tmp
}

buildHarfbuzzForPango()
{
  # need to test for existence and quit
  cd ${HARFBUZZ_BASE_DIR}/install
  
  echo "==================================================================="
  echo "Building Harfbuzz"
  echo "==================================================================="
  
  ./install.sh ${lower_case} --with-pango ${CINDER_ROOT_DIR}

  cd ${PANGO_BASE_DIR}/install/tmp
}

buildPango()
{
  cd pango
  echo "==================================================================="
  echo "Building Pango, and installing $1"
  echo "==================================================================="
  PREFIX=$PREFIX_PANGO
  HOST=$1
  OPTIONS=$2
  echo "Passed in $HOST"
 
  ./configure --disable-shared --enable-static=yes --prefix=${PREFIX} --enable-gtk-doc-html=no --with-cairo=yes ${OPTIONS}
  
  automake --add-missing 
  
  make -j 6
  make install
  make clean

  cp -r ${PREFIX}/include/* ${FINAL_INCLUDE_PATH}
  cp ${PREFIX}/lib/*.a ${FINAL_LIB_PATH}

  cd ..
}

#########################
## echo the flags
#########################

echoFlags()
{
  echo "==================================================================="
  echo "Environment for ${lower_case}..."
  echo -e "\t CXX:      ${CXX}"
  echo -e "\t CC:       ${CC}"
  echo -e "\t CFLAGS:   ${CFLAGS}"
  echo -e "\t CXXFLAGS: ${CXXFLAGS}"
	echo -e "\t CPPFLAGS: ${CPPFLAGS}"
  echo -e "\t LDFLAGS:  ${LDFLAGS}"
  echo "==================================================================="
}

rm -rf tmp
mkdir tmp
cd tmp

downloadLibffi
downloadGettext
downloadGlib
downloadPango

declare -a config_settings=("debug" "release")
declare -a config_paths=("/Debug" "/Release")

export LIBFFI_LIBS="-L${PREFIX_LIBFFI}/lib -lffi"
export LIBFFI_CFLAGS="-I${PREFIX_LIBFFI}/lib/libffi-3.2.1/include"
export GLIB_CFLAGS="-I${PREFIX_GLIB}/include/glib-2.0 -I${PREFIX_GLIB}/lib/glib-2.0/include"
export GLIB_LIBS="-L${PREFIX_GLIB}/lib -lglib-2.0 -lgobject-2.0"
export GOBJECT_CFLAGS="-I${PREFIX_GLIB}/include/glib-2.0 -I${PREFIX_GLIB}/lib/glib-2.0/include"
export GOBJECT_LIBS="-L${PREFIX_GLIB}/lib -lgobject-2.0"
export PKG_CONFIG_PATH="${CAIRO_BASE_DIR}/install/tmp/cairo_install/lib/pkgconfig:${CAIRO_BASE_DIR}/install/tmp/libpng_install/lib/pkgconfig:${CAIRO_BASE_DIR}/install/tmp/pixman_install/lib/pkgconfig:${PREFIX_GLIB}/lib/pkgconfig"

echo ${PKG_CONFIG_PATH}

echo "Building pango for {$lower_case}"
if [ "${lower_case}" = "mac" ] || [ "${lower_case}" = "macosx" ];
then
  export PATH="${PATH}:${PREFIX_GETTEXT}/bin:${PREFIX_GLIB}/bin"
  
	export CPPFLAGS="${CPPFLAGS} -I${PREFIX_GETTEXT}/include"	
	export CXX="$(xcrun -find -sdk macosx clang++) -Wno-enum-conversion"
	export CC="$(xcrun -find -sdk macosx clang) -Wno-enum-conversion"
	export CFLAGS="-O3 -pthread -I${PREFIX_GETTEXT}/include ${CFLAGS}"
	export CXXFLAGS="-O3 -pthread ${CXXFLAGS}"
	export LDFLAGS="-stdlib=libc++ -L/usr/local/lib ${LDFLAGS}"

  ##################################
  ## we use cinder to link freetype
  ##################################

  CINDER_DIR=${CINDER_ROOT_DIR}
  CINDER_LIB_DIR=${CINDER_DIR}/lib/${lower_case}/Release
  CINDER_FREETYPE_INCLUDE_PATH=${CINDER_DIR}/include/
  CINDER_LIBZ_INCLUDE_PATH=${CINDER_DIR}/src/

  if [ ! -f "${CINDER_LIB_DIR}/libcinder.a" ]; then
    echo "Need to build release version of cinder to run this install. Cairo needs Freetype. Exiting!"
    exit
  fi

  export FREETYPE_LIBS="-L${CINDER_LIB_DIR} -lcinder"
  export FREETYPE_CFLAGS="-I${CINDER_FREETYPE_INCLUDE_PATH}/freetype -I${CINDER_FREETYPE_INCLUDE_PATH}"
  export ZLIB_LIBS="-L${CINDER_LIB_DIR}/lib -lcinder"
  export ZLIB_CFLAGS="-I${CINDER_LIBZ_INCLUDE_PATH}/zlib-1.2.8"
  
	echoFlags
  buildOSX
elif [ "${lower_case}" = "linux" ];
then
  export PATH="${PATH}:${PREFIX_GETTEXT}/bin"
	
	export CXX="/usr/bin/clang++ -Wno-enum-conversion"
	export CC="/usr/bin/clang -Wno-enum-conversion"
	export CFLAGS="-O3 -pthread -I${PREFIX_GETTEXT}/include ${CFLAGS}"
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX_GETTEXT}/include"
	export CXXFLAGS="-O3 -pthread ${CXXFLAGS}"
  
  ##################################
  ## we use cinder to link freetype
  ##################################

  CINDER_DIR=${CINDER_ROOT_DIR}
  CINDER_LIB_DIR=${CINDER_DIR}/lib/${lower_case}/x86_64/ogl/Release
  CINDER_FREETYPE_INCLUDE_PATH=${CINDER_DIR}/include/
  CINDER_LIBZ_INCLUDE_PATH=${CINDER_DIR}/src/

  if [ ! -f "${CINDER_LIB_DIR}/libcinder.a" ]; then
    echo "Need to build release version of cinder to run this install. Cairo needs Freetype. Exiting!"
    exit
  fi

  export FREETYPE_LIBS="-L${CINDER_LIB_DIR} -lcinder"
  export FREETYPE_CFLAGS="-I${CINDER_FREETYPE_INCLUDE_PATH}/freetype -I${CINDER_FREETYPE_INCLUDE_PATH}"
  export ZLIB_LIBS="-L${CINDER_LIB_DIR} -lcinder"
  export ZLIB_CFLAGS="-I${CINDER_LIBZ_INCLUDE_PATH}/zlib-1.2.8"
 
  echoFlags 
	buildLinux
else
  echo "Unkown selection: ${1}"
  echo "usage: ./install.sh [platform]"
  echo "accepted platforms are macosx, linux, ios"
  exit 1
fi

# rm -rf tmp
