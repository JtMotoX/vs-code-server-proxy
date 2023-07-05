#!/bin/sh

docker-compose exec nginx sh -c "nginx -T >/dev/null && nginx -s reload"
if [ "$?" != "0" ]; then
	echo "ERROR reloading"
	exit 1
else
	echo 'Successfully reloaded'
fi
