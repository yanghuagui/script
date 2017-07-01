#!/bin/bash

#运行该脚本 [参数1] [参数2] [参数3]
#参数1：需要建立的路径名称__debug_$TIME}__中TIME的名称，可任意取名
#参数2：对应参数1决定的目录下system与V20XIPC对应的svn版本，格式为 -rxxx，xxx为版本号
#参数3：
PATH1="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/system"
PATH2="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/V20XIPC"

#TIME=`date "+%y%m%d%H%M"`
if [ -z "$1" ];then
echo "NULL parameter!"
TIME=`date "+%y%m%d"`
else
echo "parameter 1: $1"
TIME=`echo $1`
fi

cd ~
	curpath=`pwd`
	tmppath=`echo $curpath`
	dbgpath="${tmppath}/__debug_${TIME}__/"
cd -
if [ ! -x "$dbgpath" ];then		
			echo -e "\n\033[1;35m >>>>> [no dbgpath] mkdir...\033[0m\n"
			sleep 2
			mkdir -p ~/__debug_${TIME}__
			echo -e "\n\033[1;35m mkdir done!\033[0m\n"
fi

cd __debug_${TIME}__ && \
echo -e "\n\033[1;35m >>>>> start to checkout 'system'...\033[0m\n" && \
sleep 2 && \
svn co --depth empty ${PATH1} $2 && \

#curpath=`pwd`
#tmppath=`echo $curpath`
#rootfspath="${tmppath}/system/rootfs/"
#pack_tool_path="${tmppath}/system/pack_tool/"
#if [ -x "$pack_tool_path" ];then
	rm -rf ./system/pack_tool	
#fi
#if [ -x "$rootfspath" ];then
	rm -rf ./system/rootfs	
#fi
svn update --accept tf --set-depth infinity ./system/pack_tool $2
svn update --accept tf --set-depth infinity ./system/rootfs $2
svn update --set-depth infinity ./system/makefirm.sh $2
svn update --set-depth infinity ./system/readme.txt $2
echo -e "\n\033[1;35m checkout 'system' compelete!\033[0m\n" && \
echo -e "\n\033[1;35m there have no kernel&uboot! pay attention when you execute 'svn up'!!!\033[0m\n" && \
cd ./system && svn info >> ../system_svn_info.txt && cd - && \
sleep 2 && \
echo -e "\n\033[1;35m >>>>> start to checkout 'V20XIPC'...\033[0m\n" && \
sleep 2 && \
svn co ${PATH2} $2 && \
echo -e "\n\033[1;35m checkout 'V20XIPC' compelete!\033[0m\n" && \
cd ./V20XIPC && svn info >> ../V20XIPC_svn_info.txt && cd - && \
sleep 2 && \

cd ~ && ./general_shell_background.sh stop
cd ~/__debug_${TIME}__/system && ./makefirm.sh && \
echo -e "\n\033[1;35m compelete! goto /system/pack_tool/output ...\033[0m\n"

cd ~/__debug_${TIME}__/V20XIPC && \
ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
cscope -Rbq

if [ -z "$3" ];then
	echo "parameter 3 is NULL parameter!"
	cd ~ && ./general_shell_background.sh stop
	./general_shell_background.sh start
else
	echo "parameter 3: $3"
	cd ~ && ./general_shell_background.sh stop
fi


#cp -r ./pack_tool/output/* ../
#echo -e "\n\033[1;35m done!\033[0m\n"
#echo -e "\n\033[1;35m Now goto /system && ./makefirm.sh to debug!\033[0m\n"
