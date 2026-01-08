#!/bin/sh

set -e

# Verify required variables are set
if [ -z "${AUTH_USERNAME}" ]; then
    echo "ERROR: AUTH_USERNAME is not set in .env file"
    exit 1
fi

if [ -z "${AUTH_PASSWORD}" ]; then
    echo "ERROR: AUTH_PASSWORD is not set in .env file"
    exit 1
fi

if [ -z "${VS_CODE_HTTP_PORT}" ]; then
    echo "ERROR: VS_CODE_HTTP_PORT is not set in .env file"
    exit 1
fi

# Set default for AUTH_EXPIRE_SECONDS if not provided
if [ -z "${AUTH_EXPIRE_SECONDS}" ]; then
    export AUTH_EXPIRE_SECONDS=86400
fi

# Generate random cookie secret if not provided
if [ -z "${AUTH_COOKIE_SECRET}" ]; then
    export AUTH_COOKIE_SECRET="$(hexdump -n 32 -e '4/4 "%08x"' /dev/urandom)"
    echo "Generated AUTH_COOKIE_SECRET for this session"
fi

# Call the original nginx entrypoint
exec /docker-entrypoint.sh "$@"

