#!/bin/bash

lower_case=$(echo "$1" | tr '[:upper:]' '[:lower:]')
 
if [ -z $1 ]; then 
	echo Need to provide platform. Possible platforms are linux, macosx, ios. Exiting!
	exit 
fi 

#########################
## create prefix dirs
#########################

PREFIX_BASE_DIR=`pwd`/tmp

PREFIX_LIBZ=${PREFIX_BASE_DIR}/libz_install
#rm -rf ${PREFIX_LIBZ}
#mkdir -p ${PREFIX_LIBZ}

PREFIX_LIBFFI=${PREFIX_BASE_DIR}/libffi_install
#rm -rf ${PREFIX_LIBFFI}
#mkdir -p ${PREFIX_LIBFFI}

PREFIX_GETTEXT=${PREFIX_BASE_DIR}/gettext_install
#rm -rf ${PREFIX_GETTEXT}
#mkdir -p ${PREFIX_GETTEXT}

PREFIX_GLIB=${PREFIX_BASE_DIR}/glib_install
#rm -rf ${PREFIX_GLIB}
#mkdir -p ${PREFIX_GLIB}

PREFIX_PANGO=${PREFIX_BASE_DIR}/pango_install
rm -rf ${PREFIX_PANGO}
mkdir -p ${PREFIX_PANGO}

#############################
## cinder paths for freetype
#############################

CINDER_DIR=`pwd`/../../..
CINDER_LIB_DIR=${CINDER_DIR}/lib/${lower_case}/Release
CINDER_FREETYPE_INCLUDE_PATH=${CINDER_DIR}/include/freetype

##########################
## cinder paths for cairo
##########################

CAIRO_BASE_DIR=`pwd`/../../Cairo
CAIRO_LIB_PATH="${CAIRO_BASE_DIR}/lib/${lower_case}"
CAIRO_INCLUDE_PATH="${CAIRO_BASE_DIR}/include/${lower_case}/cairo"
# make sure it's the correct version
echo "Setting up cairo flags..."

#############################
## cinder paths for harfbuzz
#############################

HARFBUZZ_BASE_DIR=`pwd`/../../Cinder-Harfbuzz
HARFBUZZ_LIB_PATH="${HARFBUZZ_BASE_DIR}/lib_p/${lower_case}"
HARFBUZZ_INCLUDE_PATH="${HARFBUZZ_BASE_DIR}/include_p/${lower_case}"
echo "Setting up Harfbuzz flags..."

#########################
## create final path
#########################

FINAL_PATH=`pwd`/..
FINAL_LIB_PATH=${FINAL_PATH}/lib/${lower_case}
#rm -rf ${FINAL_LIB_PATH}
#mkdir -p ${FINAL_LIB_PATH}
 
FINAL_INCLUDE_PATH=${FINAL_PATH}/include/${lower_case}
#rm -rf ${FINAL_INCLUDE_PATH}
#mkdir -p ${FINAL_INCLUDE_PATH}

#########################
## different archs
#########################

buildOSX() 
{
  echo Building OSX...

  #buildZlib
  #buildLibffi
  #buildGettext
	export LDFLAGS="${LDFLAGS} -L${PREFIX_GETTEXT}/lib -lintl -lgettextpo -lasprintf"
  #buildGlib 
  #buildHarfbuzzForPango
  export HARFBUZZ_CFLAGS="-I${HARFBUZZ_INCLUDE_PATH}/harfbuzz"
  export HARFBUZZ_LIBS="-L${HARFBUZZ_LIB_PATH} -lharfbuzz -lharfbuzz-gobject"
  buildPango
}

buildLinux() 
{
  echo Building Linux...

  buildZlib
  buildLibffi
  buildGettext
	export LDFLAGS="${LDFLAGS} -L${PREFIX_GETTEXT}/lib -lgettextpo -lasprintf"
  buildGlib 
  buildHarfbuzz
  buildPango
}

#########################
## downloading libs
#########################

downloadZlib()
{
	echo Downloading zlib...
  curl http://zlib.net/zlib-1.2.8.tar.gz -o zlib.tar.gz
  tar -xf zlib.tar.gz
  mv zlib-* zlib
  rm zlib.tar.gz
  echo Finished Downloading zlib...
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
	echo Finished downloading glib...
}

downloadPango() 
{
	echo Downloading Pango
	curl -o pango.tar.xz http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-1.40.0.tar.xz
	tar xf pango.tar.xz
	mv pango-* pango
  echo Finished downloading Pango...
}

buildZlib()
{
  cd zlib
  
  echo "==================================================================="
  echo "Building and installing zlib, ${PREFIX_LIBZ}"
  echo "==================================================================="
  
  PREFIX=${PREFIX_LIBZ}
 
  ./configure --prefix=${PREFIX}

  make -j 6
  make install
  make clean

  cd ..
}

buildLibffi()
{
  cd libffi
  
  echo "==================================================================="
  echo "Building and installing libffi"
  echo "==================================================================="
  
  PREFIX=${PREFIX_LIBFFI}
  HOST=$1
  if [ -z "$HOST" ]; then
    ./configure --prefix=${PREFIX}
  else
    #python ./generate-darwin-source-and-headers.py
    ./configure --prefix=${PREFIX} --host=${HOST}
  fi

  make -j 6
  make install
  make clean

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

  cd ..
}

buildHarfbuzzForPango()
{
  # need to test for existence and quit
  cd ${HARFBUZZ_BASE_DIR}/install
  
  echo "==================================================================="
  echo "Building Harfbuzz"
  echo "==================================================================="
  
  ./install.sh ${lower_case} --with-pango

  cd ../../Cinder-Pango/install/tmp
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

#rm -rf tmp
#mkdir tmp
cd tmp

#downloadZlib
#downloadLibffi
#downloadGettext
#downloadGlib
downloadPango

declare -a config_settings=("debug" "release")
declare -a config_paths=("/Debug" "/Release")

export ZLIB_LIBS="-L${PREFIX_LIBZ}/lib -lz"
export ZLIB_CFLAGS="-I${PREFIX_LIBZ}/include"
export LIBFFI_LIBS="-L${PREFIX_LIBFFI}/lib -lffi"
export LIBFFI_CFLAGS="-I${PREFIX_LIBFFI}/lib/libffi-3.2.1/include/"
export FREETYPE_LIBS="-L${CINDER_LIB_DIR} -lcinder"
export FREETYPE_CFLAGS="-I${CINDER_FREETYPE_INCLUDE_PATH}"
export GLIB_CFLAGS="-I${PREFIX_GLIB}/include/glib-2.0 -I${PREFIX_GLIB}/lib/glib-2.0/include"
export GLIB_LIBS="-L${PREFIX_GLIB}/lib -lglib-2.0 -lgobject-2.0"
export GOBJECT_CFLAGS="-I${PREFIX_GLIB}/include/glib-2.0 -I${PREFIX_GLIB}/lib/glib-2.0/include"
export GOBJECT_LIBS="-L${PREFIX_GLIB}/lib -lgobject-2.0"
export CAIRO_CFLAGS="-I${CAIRO_INCLUDE_PATH}"
export CAIRO_LIBS="-L${CAIRO_LIB_PATH} -lcairo -lpixman-1 -lpng -L${PREFIX_LIBZ}/lib -lz"
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
	export LDFLAGS="-stdlib=libc++ -framework AppKit -framework CoreText -framework CoreFoundation -framework CoreGraphics  -framework Carbon -L/usr/local/lib ${LDFLAGS}"
	
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
 
  echoFlags 
	buildLinux
else
  echo "Unkown selection: ${1}"
  echo "usage: ./install.sh [platform]"
  echo "accepted platforms are macosx, linux, ios"
  exit 1
fi

# rm -rf tmp
