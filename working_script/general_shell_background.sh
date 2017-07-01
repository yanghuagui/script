#!/bin/sh

#����˵����
#start   ����
#silent  ����ģʽ�������������
#stop    ֹͣ
#restart ����
#status  �鿴����״̬
#output  �鿴���
#clean   ���out��pid�ļ�

TIME=`date "+%y%m%d"`

PID=0
DIR=`dirname $0`
#��������״̬�µ���ִ�� $ cd `dirname $0` �Ǻ�������ġ���Ϊ�����ص�ǰ·����"."��
#�������д�ڽű��ļ���������ã�����������ű��ļ����õ�Ŀ¼�������Ը������Ŀ¼����λ��Ҫ���г�������λ�ã�����λ�ó��⣩��
PIDFILE=$DIR/nohup.pid
OUTFILE=$DIR/nohup.out
PROGNAME='ycmconf'
 
run() {
	echo "nohup"
    nohup $DIR/ycm_generator_auto.sh ${TIME} >>$OUTFILE 2>&1 & echo $!>$PIDFILE
	echo "nohup --"
}
 
init() {
    if [ -f $PIDFILE ]; then
        PID=`cat $PIDFILE`
    fi
}
 
check() {
    if [ $PID -eq 0 ]; then
        return 1
    else
        kill -0 $PID 2>/dev/null
    fi
}
 
start() {
    init
    check
    if [ $? -eq 0 ]; then
        echo "$PROGNAME is run!" && exit 1
    else
        run
        echo "Start $PROGNAME!" && exit 0
    fi
}
 
silent() {
    init
    check
    if [ $? -eq 0 ]; then
        exit 1
    else
        run
        exit 0
    fi
}
 
restart() {
    init
    check
    if [ $? -eq 0 ]; then
        kill -9 $PID>/dev/null 2>&1
    fi
    run
    echo "Restart $PROGNAME!" && exit 0
}
 
stop() {
    init
    check
    if [ $? ]; then
        kill -9 $PID>/dev/null 2>&1
        echo "$PROGNAME is stop!" && exit 0
    else
        echo "$PROGNAME is not run!" && exit 1
    fi
}
 
status() {
    init
    check
    if [ $? -eq 0 ]; then
        echo "$PROGNAME is run!" && exit 0
    else
        echo "$PROGNAME is not run!" && exit 1
    fi
}
 
output() {
    if [ -f $OUTFILE ]; then
        watch -n 1 tail $OUTFILE
    else
        echo "$OUTFILE is not find!" && exit 1
    fi
}
 
clean() {
    if [ -f $OUTFILE ]; then
        rm -f $OUTFILE
    fi
    if [ -f $PIDFILE ]; then
        rm -f $PIDFILE
    fi
    echo 'Clean success!' && exit 0
}
 
case "$1" in
    start)
        $1
        exit 0
        ;;
    silent)
        $1
        exit 0
        ;;
    restart)
        $1
        exit 0
        ;;
    stop)
        $1
        exit 0
        ;;
    status)
        $1
        exit 0
        ;;
    output)
        $1
        exit 0
        ;;
    clean)
        $1
        exit 0
        ;;
    *)
        echo $DIR
        echo 'Usage: {start|stop|restart|silent|status|output|clean}'
        ;;
esac