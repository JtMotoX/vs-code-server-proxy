#!/bin/sh

cd "$(dirname "$0")"

touch .connection-token
if [ "$(cat .connection-token)" = "" ]; then
	echo "You need to set the password in the file: .connection-token"
	exit 1
fi

docker-compose down
docker-compose up -d

/usr/local/bin/code-server serve-local --connection-token-file .connection-token
