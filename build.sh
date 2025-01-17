#!/bin/sh

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0



########
###### install deps yum install autoconf automake bzip2 bzip2-devel cmake  gcc gcc-c++  zlib-devel python-devel libtool
######

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${TARGET_DIR}/lib/pkgconfig
export PATH=${PATH}:${TARGET_DIR}/bin
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${TARGET_DIR}/lib/
export PATH=$BIN_DIR:$PATH


[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.15.05.tar.gz" \
  "" \
  "4ab99e8e777c249f32d5c10e82c658f1" \
  "https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/"

download \
  "cmake-3.23.1.tar.gz" \
  "" \
  "b0d46fdcca030372f0a464146243e193" \
  "https://github.com/Kitware/CMake/releases/download/v3.23.1/"

download \
  "autoconf-2.70.tar.gz" \
  "" \
  "0496b8e1f39d84f4ff8e775fa7ae8b4e" \
  "ftp.gnu.org/gnu/autoconf/"

download \
  "m4-1.4.18.tar.gz" \
  "" \
  "a077779db287adf4e12a035029002d28" \
  "http://mirrors.kernel.org/gnu/m4/"

download \
  "perl-5.26.1.tar.gz" \
  "" \
  "a7e5c531ee1719c53ec086656582ea86" \
  "http://search.cpan.org/CPAN/authors/id/S/SH/SHAY/"

download \
  "automake-1.16.tar.gz" \
  "" \
  "7fb7155e553dc559ac39cf525f0bb5de" \
  "http://mirrors.kernel.org/gnu/automake/"

download \
  "libtool-2.2.6b.tar.gz" \
  "" \
  "07da460450490148c6d2df0f21481a25" \
  "mirrors.kernel.org/gnu/libtool/"

download \
  "OpenSSL_1_0_2o.tar.gz" \
  "" \
  "5b5c050f83feaa0c784070637fac3af4" \
  "https://github.com/openssl/openssl/archive/"

download \
  "v1.2.11.tar.gz" \
  "zlib-1.2.11.tar.gz" \
  "0095d2d2d1f3442ce1318336637b695f" \
  "https://github.com/madler/zlib/archive/"

download \
  "x264-stable.tar.gz" \
  "" \
  "nil" \
  "https://code.videolan.org/videolan/x264/-/archive/stable/"

download \
  "x265_3.2.tar.gz" \
  "" \
  "374e6359a00d17fd82195c02c341c861" \
  "http://mirrors.nju.edu.cn/videolan-ftp/x265/"

download \
  "fdk-aac-0.1.6.tar.gz" \
  "" \
  "13c04c5f4f13f4c7414c95d7fcdea50f" \
  "https://jaist.dl.sourceforge.net/project/opencore-amr/fdk-aac/"

download \
  "bzip2-1.0.6.tar.gz" \
  "" \
  "00b516f4704d4a7cb50a1d97e6e8e15b" \
  "sourceware.org/pub/bzip2/"

#download \
#  "v0.1.6.tar.gz" \
#  "fdk-aac.tar.gz" \
#  "223d5f579d29fb0d019a775da4e0e061" \
#  "https://github.com/mstorsjo/fdk-aac/archive"


#download \
#  "zlib-1.2.10.tar.gz" \
#  "" \
#  "d9794246f853d15ce0fcbf79b9a3cf13" \
#  "http://www.zlib.net/fossils/"


# libass dependency
download \
  "harfbuzz_2.6.4.orig.tar.xz" \
  "" \
  "2b3a4dfdb3e5e50055f941978944da9f" \
  "mirrors.nju.edu.cn/ubuntu/pool/main/h/harfbuzz/"

download \
  "fribidi_0.19.7.orig.tar.bz2" \
  "" \
  "6c7e7cfdd39c908f7ac619351c1c5c23" \
  "http://mirrors.nju.edu.cn/ubuntu/pool/main/f/fribidi/" 

download \
  "libpng-1.2.58.tar.xz" \
  "" \
  "1fe68fa3cdab99dbcfd2a6b4de95645f" \
  "https://sourceforge.net/projects/libpng/files/libpng12/1.2.58"

# if want to change python version, dont for get the python head file path when build libxml2
download \
  "Python-3.8.0.tar.xz" \
  "" \
  "dbac8df9d8b9edc678d0f4cacdb7dbb0" \
  "https://www.python.org/ftp/python/3.8.0/"


download \
  "libxml2-2.9.12.tar.gz" \
  "" \
  "f433a39be087a9f0b197eb2307ad9f75" \
  "http://xmlsoft.org/sources/"

download \
  "freetype-2.10.2.tar.gz" \
  "" \
  "b1cb620e4c875cd4d1bfa04945400945" \
  "http://download.savannah.gnu.org/releases/freetype" 
  
#download \
#  "fribidi-1.0.2.tar.bz2" \
#  "" \
#  "bd2eb2f3a01ba11a541153f505005a7b" \
#  "https://github.com/fribidi/fribidi/releases/download/v1.0.2/"

download \
  "0.13.6.tar.gz" \
  "libass-0.13.6.tar.gz" \
  "nil" \
  "https://github.com/libass/libass/archive/"

download \
  "fontconfig-2.12.0.tar.gz" \
  "" \
  "d8b056231abcb6257db6dc6d745360b2" \
  "https://www.freedesktop.org/software/fontconfig/release/"

download \
  "lame-3.99.5.tar.gz" \
  "" \
  "84835b313d4a8b68f5349816d33e07ce" \
  "http://downloads.sourceforge.net/project/lame/lame/3.99"

download \
  "opus-1.1.2.tar.gz" \
  "" \
  "1f08a661bc72930187893a07f3741a91" \
  "ftp.mozilla.org/pub/opus/" 

download \
  "libvpx_1.10.0.orig.tar.gz" \
  "" \
  "cded283be38dc0078c3fbe751722efc5" \
  "mirrors.nju.edu.cn/kali/pool/main/libv/libvpx/" 

#download \
#  "v1.6.1.tar.gz" \
#  "vpx-1.6.1.tar.gz" \
#  "b0925c8266e2859311860db5d76d1671" \
#  "https://github.com/webmproject/libvpx/archive"

download \
  "rtmpdump-2.3.tgz" \
  "" \
  "eb961f31cd55f0acf5aad1a7b900ef59" \
  "https://rtmpdump.mplayerhq.hu/download/"

download \
  "soxr-0.1.2-Source.tar.xz" \
  "" \
  "0866fc4320e26f47152798ac000de1c0" \
  "https://sourceforge.net/projects/soxr/files/"

download \
  "release-0.98b.tar.gz" \
  "vid.stab-release-0.98b.tar.gz" \
  "299b2f4ccd1b94c274f6d94ed4f1c5b8" \
  "https://github.com/georgmartius/vid.stab/archive/"

#download \
#  "v3.1.0.tar.gz" \
#  "" \
#  "e2d003f9fe981ff7839a8a47b9a54dcc" \
#  "https://github.com/buaazp/zimg/archive/refs/tags/"


#download \
#  "release-2.7.4.tar.gz" \
#  "zimg-release-2.7.4.tar.gz" \
#  "1757dcc11590ef3b5a56c701fd286345" \
#  "https://github.com/sekrit-twc/zimg/archive/"

download \
  "v2.1.2.tar.gz" \
  "openjpeg-2.1.2.tar.gz" \
  "40a7bfdcc66280b3c1402a0eb1a27624" \
  "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v0.6.1.tar.gz" \
  "libwebp-0.6.1.tar.gz" \
  "1c3099cd2656d0d80d3550ee29fc0f28" \
  "https://github.com/webmproject/libwebp/archive/"

#download \
#  "v1.3.6.tar.gz" \
#  "vorbis-1.3.6.tar.gz" \
#  "03e967efb961f65a313459c5d0f4cbfb" \
#  "https://github.com/xiph/vorbis/archive/"

#download \
#  "v1.3.3.tar.gz" \
#  "ogg-1.3.3.tar.gz" \
#  "b8da1fe5ed84964834d40855ba7b93c2" \
#  "https://github.com/xiph/ogg/archive/"

download \
  "speex-1.2.0.tar.gz" \
  "" \
  "8ab7bb2589110dfaf0ed7fa7757dc49c" \
  "downloads.us.xiph.org/releases/speex/"


#download \
#  "Speex-1.2.0.tar.gz" \
#  "Speex-1.2.0.tar.gz" \
#  "4bec86331abef56129f9d1c994823f03" \
#  "https://github.com/xiph/speex/archive/"

#download \
#  "n4.0.tar.gz" \
#  "ffmpeg4.0.tar.gz" \
#  "4749a5e56f31e7ccebd3f9924972220f" \
#  "https://github.com/FFmpeg/FFmpeg/archive"

download \
  "ffmpeg-5.0.1.tar.xz" \
  "" \
  "c9541d321f08021d28503d89956e80dd" \
  "https://ffmpeg.org/releases/"


[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

if [ $is_x86 -eq 1 ]; then
    echo "*************************************************************************************************** Building bzip2 *****************************************************************************************"
    echo "*************************************************************************************************** Building bzip2 *****************************************************************************************"
    echo "*************************************************************************************************** Building bzip2 *****************************************************************************************"
    cd $BUILD_DIR/bzip2*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    #[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval PREFIX=${TARGET_DIR}
    make install PREFIX=${TARGET_DIR}
fi

echo "******************************************************************************************************** Building zlib *****************************************************************************************"
echo "******************************************************************************************************** Building zlib *****************************************************************************************"
echo "******************************************************************************************************** Building zlib *****************************************************************************************"
cd $BUILD_DIR/zlib*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --static
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --static
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

if [ $is_x86 -eq 1 ]; then
    echo "***************************************************************************************************** Building yasm ****************************************************************************************"
    echo "***************************************************************************************************** Building yasm ****************************************************************************************"
    echo "***************************************************************************************************** Building yasm ****************************************************************************************"
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo "***************************************************************************************************** Building nasm ****************************************************************************************"
    echo "***************************************************************************************************** Building nasm ****************************************************************************************"
    echo "***************************************************************************************************** Building nasm ****************************************************************************************"
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

echo "******************************************************************************************************** Building OpenSSL ***************************************************************************************"
echo "******************************************************************************************************** Building OpenSSL ***************************************************************************************"
echo "******************************************************************************************************** Building OpenSSL ***************************************************************************************"
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./config --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "********************************************************************************************************* Building m4 ******************************************************************************************"
echo "********************************************************************************************************* Building m4 ******************************************************************************************"
echo "********************************************************************************************************* Building m4 ******************************************************************************************"
cd $BUILD_DIR/m4*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR --bindir=$BIN_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi

echo "********************************************************************************************************* Building cmake ***************************************************************************************"
echo "********************************************************************************************************* Building cmake ***************************************************************************************"
echo "********************************************************************************************************* Building cmake ***************************************************************************************"
cd $BUILD_DIR/cmake*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR --bindir=$BIN_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi

echo "********************************************************************************************************** Building perl **************************************************************************************"
echo "********************************************************************************************************** Building perl **************************************************************************************"
echo "********************************************************************************************************** Building perl **************************************************************************************"
cd $BUILD_DIR/perl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure -des -Dprefix=$TARGET_DIR 
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi

echo "********************************************************************************************************* Building autoconf ***********************************************************************************"
echo "********************************************************************************************************* Building autoconf ***********************************************************************************"
echo "********************************************************************************************************* Building autoconf ***********************************************************************************"
cd $BUILD_DIR/autoconf*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR --bindir=$BIN_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi


echo "********************************************************************************************************* Building automake ***********************************************************************************"
echo "********************************************************************************************************* Building automake ***********************************************************************************"
echo "********************************************************************************************************* Building automake ***********************************************************************************"
cd $BUILD_DIR/automake*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR --bindir=$BIN_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi


echo "********************************************************************************************************* Building libtool *************************************************************************************"
echo "********************************************************************************************************* Building libtool *************************************************************************************"
echo "********************************************************************************************************* Building libtool *************************************************************************************"
cd $BUILD_DIR/libtool*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR --enable-static=yes --enable-shared=no
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static=yes --enable-shared=no
  PATH="$BIN_DIR:$PATH" make -j $jval
  make install
fi



PATH="$BIN_DIR:$PATH" make -j $jval
make install
echo "*********************************************************************************************************** Building x264 ***"************************************************************************************"
echo "*********************************************************************************************************** Building x264 ***"************************************************************************************"
echo "*********************************************************************************************************** Building x264 ***"************************************************************************************"
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-opencl --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*********************************************************************************************************** Building x265 *****************************************************************************************"
echo "*********************************************************************************************************** Building x265 *****************************************************************************************"
echo "*********************************************************************************************************** Building x265 *****************************************************************************************"
cd $BUILD_DIR/x265*
cd build/linux
[ $rebuild -eq 1 ] && find . -mindepth 1 ! -name 'make-Makefiles.bash' -and ! -name 'multilib.sh' -exec rm -r {} +
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF ../../source
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc
make -j $jval
make install

echo "************************************************************************************************************ Building fdk-aac *************************************************************************************"
echo "************************************************************************************************************ Building fdk-aac *************************************************************************************"
echo "************************************************************************************************************ Building fdk-aac *************************************************************************************"
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building harfbuzz ***"
cd $BUILD_DIR/harfbuzz-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PKG_CONFIG_PATH=$TARGET_DIR/lib/pkgconfig/ ./configure --prefix=$TARGET_DIR --enable-shared=no --enable-static=yes
make -j $jval
make install

echo "************************************************************************************************************* Building libpng **************************************************************************************"
echo "************************************************************************************************************* Building libpng **************************************************************************************"
echo "************************************************************************************************************* Building libpng **************************************************************************************"
cd $BUILD_DIR/libpng-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PKG_CONFIG_PATH=$TARGET_DIR/lib/pkgconfig/ ./configure --prefix=${TARGET_DIR} CPPFLAGS="-I${TARGET_DIR}/include" LDFLAGS="-L${TARGET_DIR}/lib" --enable-shared=no --enable-static=yes
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "************************************************************************************************************* Building python ****************************************************************************************"
echo "************************************************************************************************************* Building python ****************************************************************************************"
echo "************************************************************************************************************* Building python ****************************************************************************************"
cd $BUILD_DIR/Python-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PKG_CONFIG_PATH=$TARGET_DIR/lib/pkgconfig/ ./configure --prefix=$TARGET_DIR  --disable-shared
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "************************************************************************************************************* Building libxml2 ***************************************************************************************"
echo "************************************************************************************************************* Building libxml2 ***************************************************************************************"
echo "************************************************************************************************************* Building libxml2 ***************************************************************************************"
cd $BUILD_DIR/libxml2-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PKG_CONFIG_PATH=$TARGET_DIR/lib/pkgconfig/ ./configure --prefix=$TARGET_DIR CPPFLAGS="-I${TARGET_DIR}/include/python3.8" LDFLAGS="-L${TARGET_DIR}/lib" --enable-shared=no --enable-static=yes
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "************************************************************************************************************* Building freetype ***************************************************************************************"
echo "************************************************************************************************************* Building freetype ***************************************************************************************"
echo "************************************************************************************************************* Building freetype ***************************************************************************************"
cd $BUILD_DIR/freetype-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PKG_CONFIG_PATH=${TARGET_DIR}/lib/pkgconfig/ ./configure --prefix=$TARGET_DIR --enable-shared=no --enable-static=yes
make -j $jval
make install

echo "************************************************************************************************************** Building fribidi ****************************************************************************************"
echo "************************************************************************************************************** Building fribidi ****************************************************************************************"
echo "************************************************************************************************************** Building fribidi ****************************************************************************************"
cd $BUILD_DIR/fribidi-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs
make -j $jval
make install



echo "*************************************************************************************************************** Building libass ******************************************************************************************"
echo "*************************************************************************************************************** Building libass ******************************************************************************************"
echo "*************************************************************************************************************** Building libass ******************************************************************************************"
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR  --enable-static=yes --enable-shared=no --disable-require-system-font-provider
make -j $jval
make install

echo "*************************************************************************************************************** Building fontconfig **************************************************************************************"
echo "*************************************************************************************************************** Building fontconfig **************************************************************************************"
echo "*************************************************************************************************************** Building fontconfig **************************************************************************************"
cd $BUILD_DIR/fontconfig-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./autogen.sh
PKG_CONFIG_PATH=${TARGET_DIR}/lib/pkgconfig/ ./configure --prefix=$TARGET_DIR --enable-static=yes --enable-shared=no --enable-libxml2 
make -j $jval

echo "**************************************************************************************************************** Building mp3lame *****************************************************************************************"
echo "**************************************************************************************************************** Building mp3lame *****************************************************************************************"
echo "**************************************************************************************************************** Building mp3lame *****************************************************************************************"
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target
make
make install

echo "**************************************************************************************************************** Building opus **********************************************************************************************"
echo "**************************************************************************************************************** Building opus **********************************************************************************************"
echo "**************************************************************************************************************** Building opus **********************************************************************************************"
cd $BUILD_DIR/opus*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "**************************************************************************************************************** Building libvpx *******************************************************************************************"
echo "**************************************************************************************************************** Building libvpx *******************************************************************************************"
echo "**************************************************************************************************************** Building libvpx *******************************************************************************************"
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "**************************************************************************************************************** Building librtmp ********************************************************************************************"
echo "**************************************************************************************************************** Building librtmp ********************************************************************************************"
echo "**************************************************************************************************************** Building librtmp ********************************************************************************************"
cd $BUILD_DIR/rtmpdump-*
cd librtmp
[ $rebuild -eq 1 ] && make distclean || true

# there's no configure, we have to edit Makefile directly
if [ "$platform" = "linux" ]; then
  sed -i "/INC=.*/d" ./Makefile # Remove INC if present from previous run.
  sed -i "s/prefix=.*/prefix=${TARGET_DIR_SED}\nINC=-I\$(prefix)\/include/" ./Makefile
  sed -i "s/SHARED=.*/SHARED=no/" ./Makefile
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/prefix=.*/prefix=${TARGET_DIR_SED}/" ./Makefile
fi
make install_base

#echo "*************************************************************************************************************** Building libsoxr *********************************************************************************************"
#echo "*************************************************************************************************************** Building libsoxr *********************************************************************************************"
#echo "*************************************************************************************************************** Building libsoxr *********************************************************************************************"
#cd $BUILD_DIR/soxr-*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#PATH="$BIN_DIR:${TARGET_DIR}/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off
#make -j $jval
#make install

#echo "*************************************************************************************************************** Building libvidstab *******************************************************************************************"
#echo "*************************************************************************************************************** Building libvidstab *******************************************************************************************"
#echo "*************************************************************************************************************** Building libvidstab *******************************************************************************************"
#cd $BUILD_DIR/vid.stab-release-*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#if [ "$platform" = "linux" ]; then
#  sed -i "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
#elif [ "$platform" = "darwin" ]; then
#  sed -i "" "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
#fi
#PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR"
#make -j $jval
#make install

echo "***************************************************************************************************************** Building openjpeg ********************************************************************************************"
echo "***************************************************************************************************************** Building openjpeg ********************************************************************************************"
echo "***************************************************************************************************************** Building openjpeg ********************************************************************************************"
cd $BUILD_DIR/openjpeg-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off
make -j $jval
make install

#echo "****************************************************************************************************************** Building zimg ***********************************************************************************************"
#echo "****************************************************************************************************************** Building zimg ***********************************************************************************************"
#echo "****************************************************************************************************************** Building zimg ***********************************************************************************************"
#cd $BUILD_DIR/zimg-release-*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./autogen.sh
#./configure --enable-static  --prefix=$TARGET_DIR --disable-shared
#make -j $jval
#make install

echo "******************************************************************************************************************* Building libwebp *********************************************************************************************"
echo "******************************************************************************************************************* Building libwebp *********************************************************************************************"
echo "******************************************************************************************************************* Building libwebp *********************************************************************************************"
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

#echo "****************************************************************************************************************** Building libvorbis *******************************************************************************************"
#echo "****************************************************************************************************************** Building libvorbis *******************************************************************************************"
#echo "****************************************************************************************************************** Building libvorbis *******************************************************************************************"
#cd $BUILD_DIR/vorbis*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./autogen.sh
#./configure --prefix=$TARGET_DIR --disable-shared
#make -j $jval
#make install

#echo "****************************************************************************************************************** Building libogg ***********************************************************************************************"
#echo "****************************************************************************************************************** Building libogg ***********************************************************************************************"
#echo "****************************************************************************************************************** Building libogg ***********************************************************************************************"
#cd $BUILD_DIR/ogg*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./autogen.sh
#./configure --prefix=$TARGET_DIR --disable-shared
#make -j $jval
#make install

#echo "******************************************************************************************************************* Building libspeex ********************************************************************************************"
#echo "******************************************************************************************************************* Building libspeex ********************************************************************************************"
#echo "******************************************************************************************************************* Building libspeex ********************************************************************************************"
#cd $BUILD_DIR/speex*
#[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
#./autogen.sh
#./configure --prefix=$TARGET_DIR --disable-shared
#make -j $jval
#make install

# FFMpeg
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
echo "********************************************************************************************************************* Building FFmpeg *********************************************************************************************"
cd $BUILD_DIR/ffmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig" ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --enable-pthreads \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-gpl \
    --enable-nonfree \
    --enable-version3 \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
hash -r
