#!/bin/sh

cd "$(dirname "$0")"

SET_STATE=$1

SERVICE_NAME="vs-code-server"

SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

get_state() {
	if [ ! -f "${SERVICE_FILE}" ]; then
		CURRENT_STATE=-1
	else
		CURRENT_STATE=$(systemctl status vs-code-server | grep 'Active:.*\(running\)' >/dev/null 2>&1; echo $?)
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
	RUN_FILE="$(cd $(pwd)/../ && pwd)/run.sh"
	test -f "${RUN_FILE}" || { echo "ERROR: File not found: ${RUN_FILE}"; exit 1; }
	sudo cp ./vs-code-server.service "${SERVICE_FILE}"
	sudo sed -i "s|RUN_SCRIPT|${RUN_FILE}|" "${SERVICE_FILE}"
	sudo sed -i "s|USER_NAME|$(whoami)|" "${SERVICE_FILE}"
	sudo systemctl daemon-reload
	sudo systemctl enable ${SERVICE_NAME}
	start_service
}

uninstall_service() {
	sudo systemctl disable ${SERVICE_NAME}
	stop_service
	sudo rm -rf "${SERVICE_FILE}"
}

start_service() {
	sudo systemctl start ${SERVICE_NAME}
	sleep 1
	get_status
}

stop_service() {
	sudo systemctl stop ${SERVICE_NAME}
	sleep 1
	get_status
}

tail_logs() {
	sudo journalctl -u vs-code-server -f
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

	logs)
		tail_logs
		;;

	*)
		echo "You must pass in a set state (install, uninstall, status, start, stop, restart, logs)"
		exit 1
		;;
esac
