#!/bin/sh

cd "$( cd "$(dirname "$( readlink "$0" || ls -1 "$0" )")" && pwd -P )"

PATH="${PATH}:/usr/local/bin"

touch .connection-token
if [ "$(cat .connection-token)" = "" ]; then
	echo "You need to set the password in the file: .connection-token"
	exit 1
fi

docker-compose down
docker-compose up -d

SERVICE_STATUS="$(./service-macos.sh status)"
if [ -t 1 ] && [[ "${SERVICE_STATUS}" != *"not installed"* ]]; then
	./service-macos.sh restart
else
	while true; do
		code-server serve-local --connection-token-file .connection-token || true
		sleep 1
	done
fi
