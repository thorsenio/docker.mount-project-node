#!/usr/bin/env bash

DOCKER_ACCOUNT_NAME=skypilot
PACKAGE_NAME=$(cat ./package.json | jq '.name' --raw-output)
PACKAGE_VERSION=$(cat ./package.json | jq '.version' --raw-output)
PACKAGE_IMAGE_BASE_NAME=${DOCKER_ACCOUNT_NAME}/${PACKAGE_NAME}
