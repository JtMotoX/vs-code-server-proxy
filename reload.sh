#!/bin/bash

docker-compose exec nginx bash -c "nginx -T >/dev/null && /etc/init.d/nginx reload"
if [[ "$?" != "0" ]]; then
	echo "ERROR reloading"
	exit 1
else
	echo 'Successfully reloaded'
fi
