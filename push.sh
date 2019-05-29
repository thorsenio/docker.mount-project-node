#!/usr/bin/env bash

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source variables.sh

docker push ${PACKAGE_IMAGE_BASE_NAME}:${PACKAGE_VERSION}
