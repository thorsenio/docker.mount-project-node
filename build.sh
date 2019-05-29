#!/usr/bin/env bash

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source variables.sh

PACKAGE_VERSION_LABEL=${PACKAGE_VERSION}

docker build \
  --build-arg PACKAGE_NAME=${PACKAGE_NAME} \
  --build-arg PACKAGE_VERSION=${PACKAGE_VERSION} \
  --build-arg PACKAGE_VERSION_LABEL=${PACKAGE_VERSION_LABEL} \
  --file Dockerfile \
  --tag ${PACKAGE_IMAGE_BASE_NAME}:${PACKAGE_VERSION} \
  .

if [[ $? -ne 0 ]]
then
  exit 1
fi
