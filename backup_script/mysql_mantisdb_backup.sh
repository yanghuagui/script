#!/bin/bash
#This is a ShellScript For Auto DB Backup
#Setting
DBName=bugtracker
DBUser=root
DBPasswd=Iot@2017
BackupPath=/mnt/databackup/data_mysql_mantisbackup/
LogFile=/mnt/databackup/data_mysql_mantisbackup/bak_log.log
DBPath=/var/lib/mysql/
#BackupMethod=Mysqldump
#Setting End
NewFile="$BackupPath"mantis$(date +%y%m%d).tgz
DumpFile="$BackupPath"mantis$(date +%y%m%d).sql
OldFile="$BackupPath"mantis$(date +%y%m%d --date="5 days ago").tgz
mysqldump -u$DBUser -p$DBPasswd $DBName > $DumpFile
echo "-------------------------------------------" >> $LogFile
echo $(date +"%y-%m-%d %H:%M:%S") >> $LogFile
echo "--------------------------" >> $LogFile
#Delete Old File
if [ -f $OldFile ]
then rm -f $OldFile >> $LogFile 2>&1
echo " [$OldFile] Deleted Old File Success!" >> $LogFile
else 
echo " [$OldFile] No Old Backup File! " >> $LogFile
fi
echo "-------------------------------------------" >> $LogFile
