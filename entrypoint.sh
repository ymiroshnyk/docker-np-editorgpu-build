#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No command was given to run, exiting."
	exit 1
else
	# Start Xvfb
	echo "Starting Xvfb."
	Xvfb ${DISPLAY} -ac -screen 0 "$XVFB_WHD" -nolisten tcp &
	Xvfb_pid="$!"

	echo -n "Waiting for Xvfb to be ready... "
	while ! xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; do
  		sleep 0.1
	done
	echo "done."

	"$@"
	returnValue=$?

	echo -n "Stopping Xvfb... "
	while kill -n 0 $Xvfb_pid > /dev/null 2>&1; do
    	wait
	done
	echo "done."

	#echo "Removing Xvfb temporary files."
	rm -rf /tmp/.X*
	
	exit $returnValue
fi
