#!/bin/sh

cd "$(dirname "$0")"

SET_STATE=$1

SERVICE="com.jonathaf.vs-code-server"

SERVICE_FILE="${HOME}/Library/LaunchAgents/${SERVICE}.plist"

get_state() {
	if [ ! -f "${SERVICE_FILE}" ]; then
		CURRENT_STATE=-1
	else
		CURRENT_STATE=$(launchctl list | grep "$SERVICE" | grep '^[0-9]' >/dev/null 2>&1; echo $?)
	fi
}

get_status() {
	get_state
	if [ ${CURRENT_STATE} -eq -1 ]; then
		echo "Service not installed"
	elif [ ${CURRENT_STATE} -eq 0 ]; then
		echo "Running"
	else
		echo "Stopped"
	fi
}

install_service() {
	cp ./${SERVICE}.plist ${SERVICE_FILE}
	if [ $? -ne 0 ]; then
		echo "Error installing service"
		exit 1
	fi
	stop_service
	echo "Successfully Installed Service"
}

uninstall_service() {
	stop_service
	if [ ! -f "${SERVICE_FILE}" ]; then
		echo "Service not installed"
		return
	else
		rm -f ${SERVICE_FILE}
		echo "Successfully removed service"
	fi
}

start_service() {
	get_state
	if [[ $CURRENT_STATE -eq 0 ]]; then echo "Already running"; return; fi
	echo "Starting service . . ."
	launchctl load -w ${SERVICE_FILE}
	sleep 1
	launchctl list | grep "$SERVICE"
	sleep 1
	get_status
}

stop_service() {
	get_state
	launchctl unload ${SERVICE_FILE} >/dev/null 2>&1 || true
	if [[ $CURRENT_STATE -ne 0 ]]; then echo "Not running"; return; fi
	echo "Stopping service . . ."
	launchctl unload ${SERVICE_FILE}
	sleep 1
	launchctl list | grep "$SERVICE"
}

case $SET_STATE in
	install)
		install_service
		;;

	uninstall)
		uninstall_service
		;;

	status)
		get_status
		;;

	start)
		start_service
		;;

	stop)
		stop_service
		;;

	restart)
		stop_service
		start_service
		;;

	*)
		echo "You must pass in a set state (start, stop, restart)"
		exit 1
		;;
esac
