#
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #

# Paths
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM
TOOLCHAIN_DIR="/home/sanyam/abhi/dominator/tc"
MODULES_DIR=/home/sanyam/abhi/dominator/tomato/modules
OUT_DIR=/home/sanyam/abhi/dominator/tomato
RESOURCE_DIR="/home/sanyam/abhi/dominator"
ZIP_MOVE="$RESOURCE_DIR/output"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

toolchain ()
{
clear
echo -e " Select which toolchain you want to build with?$white"
echo -e " 1.UBERTC 4.9 AARCH64$white"
echo -e " 2.SABERMOD 4.9 AARCH64"
echo -e " 3.UBERTC 5.3 AARCH64"
echo -e " 4.SABERMOD 5.3 AARCH64"
echo -n " Enter your choice:"
read choice
case $choice in
1) export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-
   export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/lib/
   STRIP=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-strip
   echo -e " You selected UBERTC"
   TC="UB"
   ;;
2) export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-gnu-4.9/bin/aarch64-
   export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-gnu-4.9/lib/
   STRIP=$TOOLCHAIN_DIR/aarch64-linux-gnu-4.9/bin/aarch64-strip
   echo -e " You selected SABERMOD"
   TC="SM"
   ;;
3) export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-5.3-kernel/bin/aarch64-linux-android-
   export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-android-5.3-kernel/lib/
   STRIP=$TOOLCHAIN_DIR/aarch64-linux-android-5.3-kernel/bin/aarch64-linux-android-strip
   echo -e " You selected UBERTC 5.3"
   TC="UB"
   ;;
4) export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-gnu-5.3/bin/aarch64-
   export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-gnu-5.3/lib/
   STRIP=$TOOLCHAIN_DIR/aarch64-linux-gnu-5.3/bin/aarch64-strip
   echo -e " You selected SABERMOD"
   TC="SM"
   ;;
*) toolchain ;;
esac
}
toolchain

# vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Abhishek"
export KBUILD_BUILD_HOST="DominatingMachine"
export LOCALVERSION="-Dominator™"

#Dominator Kernel Details
BASE_VER="Dominator"
VER="-v1.5-$(date +"%Y-%m-%d"-%H%M)-"
Dominator_VER="$BASE_VER$VER$TC"

compile_kernel ()
{
echo -e "**********************************************************************************************"
echo "                                                                                                 "
echo "                                        Compiling Dominator Kernel                               "
echo "                                                                                                 "
echo -e "**********************************************************************************************"
make cyanogenmod_kenzo_defconfig
make Image -j8
make dtbs -j8
make modules -j8
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
strip_modules
}

strip_modules ()
{
echo "Copying modules"
rm $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$STRIP --strip-unneeded *.ko
cd $KERNEL_DIR
}

case $1 in
clean)
make ARCH=arm64 -j8 clean mrproper
rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
;;
*)
compile_kernel
;;
esac

rm -rf $OUT_DIR/Dominator*.zip
rm -rf $OUT_DIR/Kernel*.zip
rm -rf $MODULES_DIR*.zip
rm -rf $OUT_DIR/zImage
rm -rf $OUT_DIR/dtb
rm -rf $ZIP_MOVE/*
cp $KERNEL_DIR/arch/arm64/boot/Image  $OUT_DIR/zImage
cp $KERNEL_DIR/arch/arm64/boot/dt.img  $OUT_DIR/dtb
cd $OUT_DIR
zip -r `echo $Dominator_VER`.zip *
mv   *.zip $ZIP_MOVE
cd $KERNEL_DIR
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo -e "**********************************************************************************************"
echo "                                                                                                 "
echo "                                        Enjoy Dominator                                          "
echo "                                      $Dominator_VER.zip                                         " 
echo "                                                                                                 "
echo -e "**********************************************************************************************"  
cd
cd $ZIP_MOVE
ls
ftp uploads.androidfilehost.com
