#!/bin/bash

WORKSPACEPATH=$1

while :
do
	echo "ycm conf start!"
    sleep 20
    ~/.vim/bundle/YCM-Generator/config_gen.py -f ${WORKSPACEPATH}/yourproject_name
	cd ${WORKSPACEPATH}/yourproject_name && make clean && cd -    
	echo "ycm conf end!"
done
