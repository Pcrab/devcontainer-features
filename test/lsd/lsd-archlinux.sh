#!/bin/bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

echo "lsd version"
LSD_VERSION=$(lsd --version)
check "check ls version" bash -c "ls --version | grep ${LSD_VERSION}"

reportResults
