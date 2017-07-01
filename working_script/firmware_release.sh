#!/bin/bash

#TIME=`date "+%y%m%d%H%M"`
TIME=`date "+%y%m%d"`
PATH1="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/system"
PATH2="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M/V20XIPC"

cd ~ && mkdir -p __release_${TIME}__ && cd __release_${TIME}__ && \

#get the version of Hi3518EV20X_8M
SVN_PATH="svn://10.168.1.12/iot/IPC/Hisi/Hi3518EV20X_8M"
svn co --depth empty ${SVN_PATH} $1 && cd ./Hi3518EV20X_8M &&
svninfo=`svn info | cat -n | awk 'FNR == 12 {print $5}'`
#LOCAL_SVN_VER=`echo $svninfo`
echo $svninfo > ../svn_version_Hi3518EV20X_8M.txt
svn info
echo ......
cat ../svn_version_Hi3518EV20X_8M.txt
sleep 3
cd - && rm -rvf ./Hi3518EV20X_8M

echo -e "\n\033[1;35m >>>>> start to checkout 'system'...\033[0m\n" && \
sleep 2 && \
svn co --depth empty ${PATH1} $1 && \
svn update --set-depth infinity ./system/pack_tool $1
svn update --set-depth infinity ./system/rootfs $1
svn update --set-depth infinity ./system/makefirm.sh $1
svn update --set-depth infinity ./system/readme.txt $1
echo -e "\n\033[1;35m checkout 'system' compelete!\033[0m\n" && \
echo -e "\n\033[1;35m there have no kernel&uboot source code! We use the default 'uImage & u-boot.bin@ ./system/pack_tool/input/'!\033[0m\n"
echo -e "\n\033[1;35m IF you want to make new 'uImage & u-boot.bin' --> manual do it!\n"
cd ./system && svn info >> ../system_svn_info.txt && cd - && \
sleep 2 && \
echo -e "\n\033[1;35m >>>>> start to checkout 'V20XIPC'...\033[0m\n" && \
sleep 2 && \
svn co ${PATH2} $1 && \
echo -e "\n\033[1;35m checkout 'V20XIPC' compelete!\033[0m\n" && \
cd ./V20XIPC && svn info >> ../V20XIPC_svn_info.txt && cd -

#cd ~/__release_${TIME}__/system/
#./makefirm.sh && 
#echo -e "\n\033[1;35m compelete! goto /system/pack_tool/output ...\033[0m\n"
#cp -r ./pack_tool/output/* ../
#echo -e "\n\033[1;35m done!\033[0m\n"
#echo -e "\n\033[1;35m Now goto /system && ./makefirm.sh to debug!\033[0m\n"
