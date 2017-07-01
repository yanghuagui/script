#!/bin/bash
export PATH=$PATH:/opt/hisi-linux/x86-arm/arm-hisiv500-linux/target/bin
export PATH=$PATH:/opt/hisi-linux/x86-arm/arm-hisiv300-linux/target/bin
export PATH=$PATH:/opt/hisi-linux-nptl/arm-hisiv100-linux/target/bin
echo $PATH

resultpath="/home/public/Daily_build"
srcpath="/home/public/Daily_build/V20XIPC"
sys_srcpath="/home/public/Daily_build/system"
svnpath="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/V20XIPC"
sys_svnpath="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/system"
pack_release_svnpath="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M"

date=$(date +%Y%m%d)
mkdir -p $resultpath/$date

get_svn_rev(){
	tmprev=`svn info | cat -n | awk 'FNR == 11 {print $5}'`
	echo $tmprev > tmprev.txt
	return
}

build_rev(){
	cd ${srcpath}/sdkv200 && \
	make clean && \
	./mk.sh && \
	cd ${srcpath}/project && \
	make clean && \
	./mk.sh

	if [ $? -ne 0 ];then
		mkdir -p $resultpath/$date/r$1_COMPILE_ERR
	else
		mkdir -p $resultpath/$date/r$1_OK
		cp -rf ${srcpath}/project/IOTKH ${srcpath}/project/lib/arm_Hi3518ev200/libsdk.so $resultpath/$date/r$1_OK
		
		# if ok-> pack
		
		#get the version of Hi3518EV20X_8M for pack result
		cd $resultpath
		svn co --depth empty ${pack_release_svnpath} -r$1 && cd ./Hi3518EV20X_8M &&
		svninfo=`svn info | cat -n | awk 'FNR == 12 {print $5}'`
		#LOCAL_SVN_VER=`echo $svninfo`
		echo $svninfo > ../svn_version_Hi3518EV20X_8M.txt
		svn info
		echo ......
		cat ../svn_version_Hi3518EV20X_8M.txt
		sleep 3
		cd -
		
		cd ${sys_srcpath}		
		#svn up --force -r $1
		svn update --set-depth infinity ./system/pack_tool --force -r $1
		svn update --set-depth infinity ./system/rootfs --force -r $1
		svn update --set-depth infinity ./system/makefirm.sh --force -r $1
		svn update --set-depth infinity ./system/readme.txt --force -r $1
		echo -e "\n\033[1;35m update 'system' compelete!\033[0m\n"
		./makefirm.sh &&
		echo -e "\n\033[1;35m pack compelete!\033[0m\n"
		cp -r ./pack_tool/output/* $resultpath/$date/r$1_OK
		rm -rf ./rootfs/* && rm -rf ./pack_tool/output/*
		svn info >> $resultpath/$date/r$1_OK/system_svn_info.txt && \
		cd $resultpath/$date/r$1_OK && unzip release_firmware.zip && \
		rm -rf release_firmware.zip && chmod -R 777 *
		rm -rvf $resultpath/Hi3518EV20X_8M
		rm -rvf $resultpath/svn_version_Hi3518EV20X_8M.txt
		echo -e "\n\033[1;35m done!\033[0m\n"		
		cd -
		#
	fi	
	cd ${srcpath}
}


get_src_version(){
	#cd ~
	cd /home/public/Daily_build
	curpath=`pwd`
	tmppath=`echo $curpath`
	path_exit="${tmppath}/V20XIPC/"
	sys_path_exit="${tmppath}/system/"
	#cd -
	
	if [ ! -x "$path_exit" ];then		
		echo -e "\n\033[1;35m >>>>> [no path]start to checkout 'V20XIPC'...\033[0m\n"
		sleep 2	
		svn co ${svnpath} 
		echo -e "\n\033[1;35m done!\033[0m\n" && cd -
	else	
		cd ${srcpath}
		svn up	
		echo -e "\n\033[1;35m [have V20XIPC path] svn up...\033[0m\n" && cd -
		sleep 2
		
	fi
	
	#add system path chk for pack
	if [ ! -x "$sys_path_exit" ];then		
		echo -e "\n\033[1;35m >>>>> [no path]start to checkout 'system'...\033[0m\n"
		sleep 2	
		#svn co ${sys_svnpath}
		svn co --depth empty ${sys_svnpath} $1 && \
		svn update --set-depth infinity ./system/pack_tool $1
		svn update --set-depth infinity ./system/rootfs $1
		svn update --set-depth infinity ./system/makefirm.sh $1
		svn update --set-depth infinity ./system/readme.txt $1
		echo -e "\n\033[1;35m done!\033[0m\n" && cd -
	else	
		cd ${sys_srcpath}
		rm -rf ./rootfs/* && rm -rf ./pack_tool/output/*
		svn up	
		echo -e "\n\033[1;35m [have system path] svn up...\033[0m\n" && cd -
		sleep 2
		
	fi
	
	cd ${srcpath}
	svn up --force -r {"$date"}
	get_svn_rev
	startrev=${tmprev}
	echo "The start rev of $date is ${startrev}" >> ../${date}/${date}_startrev.txt

	svn up --force
	get_svn_rev
	latest=${tmprev}
	currev=${latest}
	echo "The latest version is ${latest}" >> ../${date}/${date}_latestrev.txt
	
	return
}

get_src_version
cd ${srcpath}
while [ $startrev -lt $currev ]
do
	svn up --force -r $currev
	get_svn_rev
	currev=${tmprev}
	#echo "1_${currev} ">>1.txt
	build_rev ${currev}
	svn up --force -r PREV
	get_svn_rev
	currev=${tmprev}
	#echo "2_${currev} ">>1.txt
done
