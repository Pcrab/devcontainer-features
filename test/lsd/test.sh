#!/bin/bash

set -e

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "execute command" bash -c "lsd --version | grep 'lsd 1.1.2'"

reportResults
