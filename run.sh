#!/bin/sh

cd "$( cd "$(dirname "$( readlink "$0" || ls -1 "$0" )")" && pwd -P )"

# MAKE SURE THE .env FILE EXISTS
if [ ! -f "./.env" ]; then
	if [ -f "./.env-sample" ]; then
		cp .env-sample .env
	else
		echo "Please create a .env file"
		exit 1
	fi
fi

# SOURCE THE .env VARIABLES
. ./.env

if [ "${VS_CODE_INSIDERS}" = "true" ]; then
	CODE_CLI="code-insiders"
	CODE_BUILD="insiders"
	echo "WARNING: Using ${CODE_CLI} since you have set VS_CODE_INSIDERS"
else
	CODE_CLI="code"
	CODE_BUILD="stable"
fi

# GET THE OS TYPE
if uname | grep -i 'linux' >/dev/null 2>&1; then
	OS_TYPE="linux"
elif echo "$OSTYPE" | grep 'linux' >/dev/null 2>&1; then
	OS_TYPE="linux"
elif echo "$OSTYPE" | grep 'darwin' >/dev/null 2>&1; then
	OS_TYPE="macos"
fi

# MAKE SURE THE OS WAS DETECTED
if [ "${OS_TYPE}" = "" ]; then
	echo "Unsupported OS: $OSTYPE"
	exit 1
fi


if [ "${OS_TYPE}" = "linux-disabled" ]; then
	# MAKE SURE KEYRING IS INSTALLED
	if ! command -v gnome-keyring-daemon >/dev/null; then
		echo "Please install gnome-keyring"
		command -v yum >/dev/null && echo "> yum install gnome-keyring"
		command -v apt >/dev/null && echo "> apt update && apt install -y gnome-keyring"
		exit 1
	fi
	# MAKE SURE KEYRING PASSWORD IS SET
	if [ "${KEYRING_PASS}" = "" ]; then
		echo "Please set the 'KEYRING_PASS' in the .env file"
		exit 1
	fi
fi

if ! command -v ${CODE_CLI} >/dev/null; then
	echo "command not found: ${CODE_CLI}"
	echo "You need to install Visual Studio Code cli"
	echo "https://code.visualstudio.com/sha/download?build=${CODE_BUILD}&os=cli-alpine-x64"
	exit 1
fi

# MAKE SURE THE PASSWORD IS SET
if [ "${VS_CODE_PASSWORD}" = "" ]; then
	echo "Please set the 'VS_CODE_PASSWORD' in the .env file"
	exit 1
fi

# SET THE PATH OF THE code BINARY
PATH="/usr/local/bin:${PATH}"

# MAKE SURE THE CERT FILES EXIST
if [ ! -f "./cert/server.crt" ] || [ ! -f "./cert/server.key" ]; then
	echo "You seem to be missing cert files. Please review the README.md."
	exit 1
fi

# START THE DOCKER CONTAINERS
docker-compose down
docker-compose up -d
if [ $? -ne 0 ]; then
	echo "Error starting docker-compose"
	exit 1
fi
sleep 2
CONTAINER_STATUS=$(docker-compose top 2>&1)
if [ $? -ne 0 ]; then
	echo "${CONTAINER_STATUS}"
	echo "Error starting container"
	exit 1
fi

# CHECK IF THE SERVICE IS INSTALLED
SERVICE_STATUS="$(./services/service-${OS_TYPE}.sh status)"
if [ $? -ne 0 ]; then
	echo "Error getting service status"
	exit 1
fi

if [ -t 1 ] && ! echo "${SERVICE_STATUS}" | grep "not installed" >/dev/null 2>&1; then
	# IF INTERACTIVE SHELL, RUN THE SERVICE IF INSTALLED
	./services/service-${OS_TYPE}.sh restart
else
	# RUN THE PROCESS
	while true; do
		COMMAND="${CODE_CLI} serve-web --connection-token "${VS_CODE_PASSWORD}" --accept-server-license-terms --disable-telemetry"
		[ "${VS_CODE_HTTP_PORT}" != "" ] && COMMAND="${COMMAND} --port ${VS_CODE_HTTP_PORT}"
		[ "${VS_CODE_LOGLEVEL}" != "" ] && COMMAND="${COMMAND} --verbose --log ${VS_CODE_LOGLEVEL}"
		echo "${COMMAND}" | sed "s/${VS_CODE_PASSWORD}/***/"
		if [ "${OS_TYPE}" = "linux-disabled" ]; then
			dbus-run-session -- sh -c "(echo '${KEYRING_PASS}' | gnome-keyring-daemon --unlock) && ${COMMAND} --host 0.0.0.0" || true
		else
			${COMMAND} || true
		fi
	done
fi
