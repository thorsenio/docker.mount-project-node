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

# Defaults
DEFAULT_CMD='bash'
PORT='8080'

# Constants
IMAGE_BASE_NAME='skypilot/node10-dev'

# Default command
CMD="${@:-${DEFAULT_CMD}}"

# Shortcut arguments
if [[ ${CMD} == 'build' ]]; then
  CMD='npm run build'
fi

if [[ ${CMD} == 'serve' ]]; then
  CMD="http-server -p ${PORT} dist"
fi

# TODO: Make it easier to switch between production and nonproduction builds.
# The code below respects `NODE_ENV`, defaulting to `development` if NODE_ENV isn't set
if [[ ${CMD} == 'test' ]]; then
  CMD='npm run test'
  ENV='development'
else
  ENV=${NODE_ENV:-'development'}
fi

echo "Running container with command: ${CMD}"

# Change to the directory of this script so that relative paths resolve correctly
cd $(dirname "$0")
source ../.env
cd ..

docker container run \
  --interactive \
  --rm \
  --tty \
  --env NODE_ENV=production \
  --expose ${PORT} \
  --mount type=bind,source=${PWD},target=/var/project \
  --publish ${PORT}:${PORT} \
  --workdir /var/project \
  ${IMAGE_BASE_NAME} \
  ${CMD}
