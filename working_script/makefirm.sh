#!/bin/bash

hisi="h01"
uboot="01"
kernel="03"
rootfs="0012"
FLASH_SIZE="8m"

################################################## 以下无需修改 #########################################################
MODIFY_VER="${hisi}.${uboot}.${kernel}.${rootfs}"
TIME=`date "+%y%m%d"`

#svninfo=`svn info | cat -n | awk 'FNR == 7 {print $3}'`
#LOCAL_SVN_VER=`echo $svninfo`

### get current svn version +++
cd ../ &&
curpath=`pwd`
tmppath=`echo $curpath`
version_file_path="${tmppath}/"	
version_file="${version_file_path}/svn_version_Hi3518EV20X_8M.txt"

if [ -f "$version_file" ]; then		
	echo -e "\n\033[1;35m check version file\033[0m\n"	
	while read temp_val
	do
		LOCAL_SVN_VER=`echo $temp_val`
	done < $version_file
	echo get version = $LOCAL_SVN_VER
	sleep 3
	cd -
else
	cd -
	echo -e "\n\033[1;35m no version file! goto check curpath!!!\033[0m\n"
	sleep 5
	svninfo=`svn info | cat -n | awk 'FNR == 7 {print $3}'`
	LOCAL_SVN_VER=`echo $svninfo`
	echo get version = $LOCAL_SVN_VER
	sleep 3
	echo LOCAL_SVN_VER > tmp.txt
	if [ ! -s "tmp.txt" ];then
		echo -e "\n\033[1;35m can not get version from current path!>>>>>exit ...\033[0m\n"			
		exit
	fi
fi
### get current svn version ---

#auto set 8m:16m ?
if [ "$FLASH_SIZE"x = "8m"x ]; then
	LOCAL_SVN_VER=`echo ${LOCAL_SVN_VER}a`
else
	LOCAL_SVN_VER=`echo ${LOCAL_SVN_VER}b`
fi
#echo $LOCAL_SVN_VER
#exit 0
cd ../V20XIPC/sdkv200 && \
echo -e "\n\033[1;35m >>>>> start to compile V20XIPC/sdkv200 ...\033[0m\n"
sleep 2s && \
make clean && \
./mk.sh && \
echo -e "\n\033[1;35m compile V20XIPC/sdkv200 ok!\033[0m\n" && \
cp -r libsdk.so ../project/lib/arm_Hi3518ev200 && \
cp -r libsdk.so ../../system/rootfs/opt/kh/lib && \
echo -e "\n\033[1;35m cp target 'libsdk.so' to path: ../../system/rootfs/opt/kh/lib success!\033[0m\n" && \
sleep 1s && \
make clean && \
echo -e "\n\033[1;35m /V20XIPC/sdkv200 make clean success!\033[0m\n" && \
sleep 2s && \
cd ../project && \
echo -e "\n\033[1;35m >>>>> start to compile V20XIPC/project ...\033[0m\n" && \
sleep 2s && \
make clean && \
./mk.sh && \
echo -e "\n\033[1;35m compile V20XIPC/project ok!\033[0m\n" && \
rm -rf ../../system/rootfs/opt/kh/bin/IOTKH
rm -rf ../../system/rootfs/opt/kh/bin/upgrade
rm -rf ../../system/rootfs/opt/kh/bin/reset
cp -r IOTKH ../../system/rootfs/opt/kh/bin && \
cp -r upgrade ../../system/rootfs/opt/kh/bin && \
#cp -r reset ../../system/rootfs/opt/kh/bin
echo -e "\n\033[1;35m cp target 'IOTKH & upgrade & reset' to path: ../../system/rootfs/opt/kh/bin success!\033[0m\n" && \
sleep 1s && \
make clean && \
echo -e "\n\033[1;35m /V20XIPC/project make clean success!\033[0m\n" && \
sleep 2s && \

cd ../../system/pack_tool && \
echo -e "\n\033[1;35m >>>>> start do pack ...\033[0m\n" && \
sleep 1s && \
rm -rvf ./output/*

# build debug firmware
echo -e "\n\033[1;35m >>>>> Building DEBUG firmware ...\033[0m\n"
VERSION="${MODIFY_VER}.${LOCAL_SVN_VER}.${TIME}T"
FIRMWARE="./output/firmware_${VERSION}.bin"
FLASH_IMG="./output/flash_${VERSION}.bin"
ROOTFS_TMP="/tmp/rootfs_${USER}_$(date +%s)"
rm -fr ./input/rootfs_squashfs.img $ROOTFS_TMP
cp -rdf ../rootfs $ROOTFS_TMP
mv $ROOTFS_TMP/opt/kh/bin/start_debug.sh $ROOTFS_TMP/opt/kh/bin/start.sh
echo $VERSION > $ROOTFS_TMP/etc_ro/version
./mksquashfs $ROOTFS_TMP ./input/rootfs_squashfs.img -comp xz  && \
sed -i "s/^version=[A-Za-z0-9_\.\-]*/version=${VERSION}/g" fw_general.ini  && \
./fw_build fw_general.ini ${FIRMWARE} ${FLASH_IMG} && \
rm -fr $ROOTFS_TMP

# build release firmware
echo -e "\n\033[1;35m >>>>> Building RELEASE firmware ...\033[0m\n"
VERSION="${MODIFY_VER}.${LOCAL_SVN_VER}.${TIME}"
FIRMWARE="./output/firmware_${VERSION}.bin"
FLASH_IMG="./output/flash_${VERSION}.bin"
ROOTFS_TMP="/tmp/rootfs_${USER}_$(date +%s)"
STRIP="arm-hisiv300-linux-strip"
rm -fr ./input/rootfs_squashfs.img $ROOTFS_TMP
cp -rdf ../rootfs $ROOTFS_TMP
rm -fr $ROOTFS_TMP/opt/kh/bin/start_debug.sh
echo $VERSION > $ROOTFS_TMP/etc_ro/version
#$STRIP $ROOTFS_TMP/bin/* $ROOTFS_TMP/sbin/* $ROOTFS_TMP/lib/*
#$STRIP $ROOTFS_TMP/usr/bin/* $ROOTFS_TMP/usr/sbin/* $ROOTFS_TMP/usr/lib/*
$STRIP $ROOTFS_TMP/opt/kh/bin/* $ROOTFS_TMP/opt/kh/lib/*
./mksquashfs $ROOTFS_TMP ./input/rootfs_squashfs.img -comp xz  && \
sed -i "s/^version=[A-Za-z0-9_\.\-]*/version=${VERSION}/g" fw_general.ini  && \
./fw_build fw_general.ini ${FIRMWARE} ${FLASH_IMG} && \
rm -fr $ROOTFS_TMP

cd ./output && 
zip -r release_firmware.zip ./* &&
#tar -czvf firmware.tar.gz ./*
rm -rvf ./*.bin ./*.img &&

echo -e "\n\033[1;35m pack end!\033[0m\n"  && \
echo -e "\n\033[1;35m target path:"pack_tool/output/*"\033[0m\n"  && \
cd ../

