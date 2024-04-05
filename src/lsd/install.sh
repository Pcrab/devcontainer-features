#!/bin/sh
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# shellcheck source=/dev/null
. /etc/os-release

# alpine do not have bash installed by default
if [ "${ID}" = "alpine" ]; then
    apk add --no-cache bash
fi

exec /bin/bash "$(dirname "$0")/main.sh" "$@"
exit $?
