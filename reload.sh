#!/bin/bash

docker exec vs-code-server-proxy bash -c "nginx -T >/dev/null && /etc/init.d/nginx reload"
if [[ "$?" != "0" ]]; then
	echo "ERROR reloading"
	exit 1
else
	echo 'Successfully reloaded'
fi
