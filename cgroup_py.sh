#!/bin/sh
###################################################################################################
#Init script to start cgroup_py as a service.
###################################################################################################



# /etc/init.d/mysystem
# Subsystem file for "MySystem" server
#
# chkconfig: 2345 95 05	(1)
# description: cgroup resource allocation daemon
#
# processname: cgroup_py
# config: /etc/cgroup_py/cgroup_py.cfg
# pidfile: /var/run/cgrou_py.pid

# source function library
. /etc/rc.d/init.d/functions

# pull in sysconfig settings
#[ -f /etc/sysconfig/mySystem ] && . /etc/sysconfig/mySystem	(2)

RETVAL=0
prog="cgroup_py"
PROG_DIR="/usr/bin"
INTERVAL=5

start() {	
	cgconfstatus=$( /etc/init.d/cgconfig status )
	if [ $cgconfstatus != "Running" ] ; then
		echo "CGConfig not running!"
		exit 1
	fi
	echo -n $"Starting $prog:"
	cd $PROG_DIR
	./cgroup_py &
	RETVAL=$?
	[ "$RETVAL" = 0 ] && touch /var/lock/subsys/$prog
	echo
}

stop() {	
	echo -n $"Stopping $prog:"
	pkill -2 $prog
	RETVAL=$?
	[ "$RETVAL" = 0 ] && rm -f /var/lock/subsys/$prog
	echo
}

reload() {	
	echo -n $"Reloading $prog:"
	pkill $prog -HUP
	RETVAL=$?
	echo
}

case "$1" in	
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	reload)
		reload
		;;
	condrestart)
		if [ -f /var/lock/subsys/$prog ] ; then
			stop
			# avoid race
			sleep 3
			start
		fi
		;;
	status)
		status $prog
		RETVAL=$?
		;;
	*)	
		echo $"Usage: $0 {start|stop|restart|reload|condrestart|status}"
		RETVAL=1
esac
exit $RETVAL
