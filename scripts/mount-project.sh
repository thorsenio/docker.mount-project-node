#!/usr/bin/env bash

# Version 1.0.0

# This script mounts the project into a container that provides Node 10.14, Bash, and Git.
# By default the container starts with Bash. Pass a different command to the script
# to run that command instead in the container.
# Examples:
#   scripts/mount-project.sh npm ci
#   scripts/mount-project.sh npm run build
#
# For convenience, shortcuts are defined for common commands. E.g.,
#   scripts/mount-project.sh build
#   scripts/mount-project.sh serve
#   scripts/mount-project.sh test

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")

# Read environment variables from file
# TODO: REFACTOR: Maybe add a flexible env var handler
if [[ -f ../.env ]]; then
  source ../.env
fi

cd ..


# -- Helper functions
# Generate a random ID to append to the container name
randomString () {
  local LENGTH=${1:4}
  echo $(perl -pe 'binmode(STDIN, ":bytes"); tr/a-zA-Z0-9//dc;' < /dev/urandom | head -c 4)
}


# Defaults. Override by setting these values in environment variables or `.env`
MPNODE_DEFAULT_CMD=${MPNODE_DEFAULT_CMD:='bash'}
WEB_SERVER_PORT=${WEB_SERVER_PORT:='8080'}
PROJECT_ID=${PROJECT_ID:='node10-app'}

# Constants
IMAGE_BASE_NAME='skypilot/node10-dev'

# Process command-line arguments, if any
if [[ -n $@ ]]; then
  CMD="$@"

  # Shortcut arguments
  if [[ ${CMD} == 'build' ]]; then
    CMD='npm run build'
  fi

  if [[ ${CMD} == 'serve' ]]; then
    CMD="http-server -p ${WEB_SERVER_PORT} dist"
  fi
else
  CMD=${MPNODE_DEFAULT_CMD}
fi


# The code below respects `NODE_ENV`, defaulting to `development` if NODE_ENV isn't set
if [[ ${CMD} == 'test' ]]; then
  CMD='npm run test'
  NODE_ENV='development'
else
  NODE_ENV=${NODE_ENV:='development'}
fi


echo "Running container in '${NODE_ENV}' environment with command: ${CMD}"

docker container run \
  --interactive \
  --rm \
  --tty \
  --env NODE_ENV=${NODE_ENV} \
  --expose ${WEB_SERVER_PORT} \
  --mount type=bind,source=${PWD},target=/var/project \
  --name ${PROJECT_ID}-$(randomString 4) \
  --publish ${WEB_SERVER_PORT}:${WEB_SERVER_PORT} \
  --workdir /var/project \
  ${IMAGE_BASE_NAME} \
  ${CMD}
