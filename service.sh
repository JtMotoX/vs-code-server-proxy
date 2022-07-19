#!/bin/sh

cd "$(dirname "$0")"

# GET THE OS TYPE
if echo "$OSTYPE" | grep 'linux' >/dev/null 2>&1; then
	OS_TYPE="linux"
elif echo "$OSTYPE" | grep 'darwin' >/dev/null 2>&1; then
	OS_TYPE="macos"
fi

./services/service-${OS_TYPE}.sh $@