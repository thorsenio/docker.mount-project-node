#!/usr/bin/env bash

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

source variables.sh

VERSION_LABEL=${VERSION}

docker build \
  --build-arg PACKAGE_NAME=${PACKAGE_NAME} \
  --build-arg VERSION=${VERSION} \
  --build-arg VERSION_LABEL=${VERSION_LABEL} \
  --file Dockerfile \
  --tag ${IMAGE_BASE_NAME}:${VERSION} \
  .
