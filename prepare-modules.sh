#!/bin/bash

# exit on errors
#set -e

WORKDIR=`dirname $0`
cd $WORKDIR
# make it an absolute path
WORKDIR=`pwd`

MYARCH=`uname -m`
MYUNAME=`uname`

if [ "$MYUNAME" = "Darwin" ]; then
  MYARCH="macos"
else
  MYOS=`uname -o`
  if [ "$MYOS" = "Msys" ]; then
    if [ "$MSYSTEM_CARCH" = "x86_64" ]; then
      MYARCH="win64"
    else
      MYARCH="win32"
    fi
  fi
fi

cd compile
cp ../build-modules.sh-proto build-modules.sh

# if we have a source archive in the source dir use that ...
if [ -f ../source/library-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd .. ; tar xzf source/library-source.tar.gz )
  cd library
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/VCVRack/library.git
  cd library
  git checkout v2
  # this is the version i used this script last with
  #git checkout 440553f3371eab4a84e2b6dcbd3b44ca027871d7

  # looks like the the-xor plugin is no longer available via github
  cd repos
  git submodule deinit -f -- TheXOR
  git rm -f TheXOR
  cd ..

  # and the rjmodules repo seems to make trouble as well, so get rid of it too
  cd repos
  git submodule deinit -f -- RJModules
  git rm -f RJModules
  cd ..

  git submodule update --init --recursive
  ( cd ../.. ; mkdir -p source ; tar czf source/library-source.tar.gz compile/library )
fi

cd repos

# arch specific patching if needed

for i in * ; do
  # SurgeRack is handled separately below
  if [ "$i" != "SurgeRack" ]; then
    if [ -f ${i}/plugin.json ]; then
      # we only want v2 plugins
      grep -q '"version": "2' ${i}/plugin.json
      if [ "$?" = "0" ]; then
        echo ""
        echo "===> $i"
        echo ""
        cd $i
        # arch independent patches
        if [ -f ../../../../patches/${i}.patch ]; then
          patch -p1 < ../../../../patches/${i}.patch
        fi
        # arch specific patches
        if [ -f ../../../../patches/${i}.$MYARCH.patch ]; then
          patch -p1 < ../../../../patches/${i}.$MYARCH.patch
        fi
        cd ..
      fi
    fi
  fi
done

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# some special handling:

# AudibleInstruments
echo ""
echo "===> AudibleInstruments extra steps"
echo ""
cd AudibleInstruments
find * -type f -exec ../../../../simde-ify.sh {} \;
# this file gets accidently simde-ified :)
git checkout -- design/Warps.ai
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# Bark
echo ""
echo "===> Bark extra steps"
echo ""
cd Bark
find * -type f -exec ../../../../simde-ify.sh {} \;
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# ChowDSP
echo ""
echo "===> ChowDSP extra steps"
echo ""
cd ChowDSP
find * -type f -exec ../../../../simde-ify.sh {} \;
# this file gets accidently simde-ified :)
git checkout -- lib/Eigen/src/Core/IO.h
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# FreeSurface
echo ""
echo "===> FreeSurface extra steps"
echo ""
cd FreeSurface
find * -type f -exec ../../../../simde-ify.sh {} \;
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# squinkylabs-plug1
echo ""
echo "===> squinkylabs-plug1 extra steps"
echo ""
cd squinkylabs-plug1
find * -type f -exec ../../../../simde-ify.sh {} \;
# this file gets accidently simde-ified :)
git checkout -- gfx/Cheby.ai
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# Valley
echo ""
echo "===> Valley extra steps"
echo ""
cd Valley
find * -type f -exec ../../../../simde-ify.sh {} \;
# those files get accidently simde-ified :)
git checkout -- TopographImg.png
git checkout -- ValleyImg.png
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# ML_modules
echo ""
echo "===> ML_modules extra steps"
echo ""
cd ML_modules
find * -type f -exec ../../../../simde-ify.sh {} \;
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# SubmarineFree
echo ""
echo "===> SubmarineFree extra steps"
echo ""
cd SubmarineFree
find * -type f -exec ../../../../simde-ify.sh {} \;
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# Comfortzone
echo ""
echo "===> Comfortzone extra steps"
echo ""
cd Comfortzone
find * -type f -exec ../../../../simde-ify.sh {} \;
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/library/repos

# some extra plugins

cd ${WORKDIR}
mkdir -p compile/plugins
cd compile/plugins

# Fundamental
echo ""
echo "===> Fundamental extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/Fundamental-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/Fundamental-source.tar.gz )
  cd Fundamental
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/VCVRack/Fundamental.git
  cd Fundamental
  git checkout v2
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/Fundamental-source.tar.gz compile/plugins/Fundamental )
fi
if [ -f ../../../patches/Fundamental.patch ]; then
  patch -p1 < ../../../patches/Fundamental.patch
fi
if [ -f ../../../patches/Fundamental.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/Fundamental.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# VCV-Recorder
echo ""
echo "===> VCV-Recorder extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/VCV-Recorder-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/VCV-Recorder-source.tar.gz )
  cd VCV-Recorder
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/VCVRack/VCV-Recorder
  cd VCV-Recorder
  git checkout v2
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/VCV-Recorder-source.tar.gz compile/plugins/VCV-Recorder )
fi
if [ -f ../../../patches/VCV-Recorder.patch ]; then
  patch -p1 < ../../../patches/VCV-Recorder.patch
fi
if [ -f ../../../patches/VCV-Recorder.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/VCV-Recorder.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# vcvrack-packone
echo ""
echo "===> vcvrack-packone extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/vcvrack-packone-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/vcvrack-packone-source.tar.gz )
  cd vcvrack-packone
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/stoermelder/vcvrack-packone
  cd vcvrack-packone
  git checkout v2-dev
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/vcvrack-packone-source.tar.gz compile/plugins/vcvrack-packone )
fi
if [ -f ../../../patches/vcvrack-packone.patch ]; then
  patch -p1 < ../../../patches/vcvrack-packone.patch
fi
if [ -f ../../../patches/vcvrack-packone.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/vcvrack-packone.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# vcv-link
echo ""
echo "===> vcv-link extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/vcv-link-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/vcv-link-source.tar.gz )
  cd vcv-link
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/stellare-modular/vcv-link
  cd vcv-link
  git checkout 2.0.0
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/vcv-link-source.tar.gz compile/plugins/vcv-link )
fi
if [ -f ../../../patches/vcv-link.patch ]; then
  patch -p1 < ../../../patches/vcv-link.patch
fi
if [ -f ../../../patches/vcv-link.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/vcv-link.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# vcvrack-packtau
echo ""
echo "===> vcvrack-packtau extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/vcvrack-packtau-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/vcvrack-packtau-source.tar.gz )
  cd vcvrack-packtau
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/stoermelder/vcvrack-packtau.git
  cd vcvrack-packtau
  git checkout v2
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/vcvrack-packtau-source.tar.gz compile/plugins/vcvrack-packtau )
fi
if [ -f ../../../patches/vcvrack-packtau.patch ]; then
  patch -p1 < ../../../patches/vcvrack-packtau.patch
fi
if [ -f ../../../patches/vcvrack-packtau.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/vcvrack-packtau.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins
 
# surge-rack
echo ""
echo "===> surge-rack extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/surge-rack-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/surge-rack-source.tar.gz )
  cd surge-rack
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/surge-synthesizer/surge-rack
  cd surge-rack
  git checkout v2
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/surge-rack-source.tar.gz compile/plugins/surge-rack )
fi
if [ -f ../../../patches/surge-rack.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/surge-rack.$MYARCH.patch
fi
# special patching for surge-rack in the surge subdir
cd surge
if [ -f ../../../../patches/surge-rack-surge.$MYARCH.patch ]; then
  patch -p1 < ../../../../patches/surge-rack-surge.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# Demo
echo ""
echo "===> Demo extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/Demo-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/Demo-source.tar.gz )
  cd Demo
# ... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/squinkylabs/Demo.git
  cd Demo
  git checkout v2
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/Demo-source.tar.gz compile/plugins/Demo )
fi
if [ -f ../../../patches/Demo.patch ]; then
  patch -p1 < ../../../patches/Demo.patch
fi
if [ -f ../../../patches/Demo.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/Demo.$MYARCH.patch
fi
cd ..

# go back to a defined starting point to be on the safe side
cd ${WORKDIR}/compile/plugins

# 23volts-vcv
echo ""
echo "===> 23volts-vcv extra plugin"
echo ""
# if we have a source archive in the source dir use that ...
if [ -f ../../source/23volts-vcv-source.tar.gz ]; then
  echo "INFO: using sources from the source archive"
  ( cd ../.. ; tar xzf source/23volts-vcv-source.tar.gz )
  cd 23volts-vcv
... otherwise get it from git and create a source archive afterwards
else
  git clone https://github.com/23volts/23volts-vcv.git
  cd 23volts-vcv
  git checkout 2.0
  git submodule update --init --recursive
  ( cd ../../.. ; mkdir -p source ; tar czf source/23volts-vcv-source.tar.gz compile/plugins/23volts-vcv )
fi
if [ -f ../../../patches/23volts-vcv.patch ]; then
  patch -p1 < ../../../patches/23volts-vcv.patch
fi
if [ -f ../../../patches/23volts-vcv.$MYARCH.patch ]; then
  patch -p1 < ../../../patches/23volts-vcv.$MYARCH.patch
fi
cd ..

# # go back to a defined starting point to be on the safe side
# cd ${WORKDIR}/compile/plugins
#
# # Volume1
# echo ""
# echo "===> Volume1 extra plugin"
# echo ""
# # if we have a source archive in the source dir use that ...
# if [ -f ../../source/Volume1-source.tar.gz ]; then
#   echo "INFO: using sources from the source archive"
#   ( cd ../.. ; tar xzf source/Volume1-source.tar.gz )
#   cd Volume1
# # ... otherwise get it from git and create a source archive afterwards
# else
#   git clone https://github.com/Delexander/Volume1
#   cd Volume1
#   git checkout v2
#   git submodule update --init --recursive
#   ( cd ../../.. ; mkdir -p source ; tar czf source/Volume1-source.tar.gz compile/plugins/Volume1 )
# fi
# if [ -f ../../../patches/Volume1.patch ]; then
#   patch -p1 < ../../../patches/Volume1.patch
# fi
# if [ -f ../../../patches/Volume1.$MYARCH.patch ]; then
#   patch -p1 < ../../../patches/Volume1.$MYARCH.patch
# fi
# cd ..

# go back to a defined point
cd ${WORKDIR}
