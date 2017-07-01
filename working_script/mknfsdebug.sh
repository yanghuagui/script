#########################################################################
# File Name:  	mknfsdebug.sh
# Author: 		yanghg
# Function: 	编译脚本
# Created Time: 2017.05.20
#########################################################################

#!/bin/bash
svnpath="svn://192.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/system/rootfs"

get_svn_rootfs_rev(){
	cd ~
	curpath=`pwd`
	tmppath=`echo $curpath`
	rootfspath="${tmppath}/nfsdir/rootfs/"
	cd -
	
	linuxrc_file="${rootfspath}/linuxrc"
	#init_file="${rootfspath}/init"
	#opt_kh_path="${rootfspath}opt/kh/"
	
	if [ ! -x "$rootfspath" ];then		
			echo -e "\n\033[1;35m >>>>> [no path]start to checkout 'rootfs'...\033[0m\n"
			sleep 2
			cd ~/nfsdir
			svn co ${svnpath} 
			echo -e "\n\033[1;35m done!\033[0m\n" && cd -
	else
		if [ ! -f "$linuxrc_file" ]; then		
			echo -e "\n\033[1;35m >>>>> [have path&no file]start to checkout 'rootfs'...\033[0m\n"
			sleep 2
			cd ~/nfsdir
			svn co ${svnpath} 
			echo -e "\n\033[1;35m done!\033[0m\n" && cd -
		else
			echo -e "\n\033[1;35m The rootfs path:'$rootfspath' exist! Are you sure is correct?\033[0m\n"
			echo -e "\n\033[1;35m if the exsit rootfs is not you want!!! plz delete it manually and execute this sh again!\033[0m\n"
			echo -e "\n\033[1;35m 用户根目录已经存在rootfs，请确认是否正确，若不是，请自行删除它，并重新执行本脚本下载最新rootfs...\033[0m\n"
			sleep 5
		fi
	fi
		return
}
 
build_sdk(){
	cd ../sdkv200 && \
	echo -e "\n\033[1;35m ####make sdk start####\033[0m\n"
	make && cp -r ./source/libsdk.so ./ && \
#	arm-hisiv300-linux-strip libsdk.so && \
	cp -r ./include/common/sdk_func.h ../project/include/mainctrl&& \
	cp -r ./libsdk.so ../project/lib/arm_Hi3518ev200 && \
	echo -e "\n\033[1;35m ####make sdk success####!\033[0m\n" && \
	cd - && \
	return
}

build(){
	echo -e "\n\033[1;35m ####make start####\033[0m\n"
	make CXX=arm-hisiv300-linux-g++ VERSION=nfsdebug PLATFORM=arm_Hi3518ev200 &&
#	arm-hisiv300-linux-strip IOTKH upgrade reset &&
	echo -e "\n\033[1;35m ####make success####!\033[0m\n" && \
	return
}

copy_exec_file2rootfs(){
	libsdk_path="./lib/arm_Hi3518ev200/libsdk.so"
	echo -e "\n\033[1;35m >>>>> start to copy exec files to 'rootfs'...\033[0m\n"
	cp -r IOTKH 			${rootfspath}opt/kh/bin/
	cp -r upgrade 			${rootfspath}opt/kh/bin/
	cp -r reset 			${rootfspath}opt/kh/bin/
	cp -r ${libsdk_path} 		${rootfspath}opt/kh/lib/
	echo -e "\n\033[1;35m copy done!\033[0m\n"
}

get_svn_rootfs_rev
build_sdk
ret=$?
#echo ${ret}
if [ ${ret} -ne 0 ];then
	exit
fi
build
ret=$?
#echo ${ret}
if [ ${ret} -ne 0 ];then
	exit
fi
copy_exec_file2rootfs



