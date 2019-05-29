#!/usr/bin/env bash

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

# -- Helper functions
# Given a relative path to a file, echo its absolute path.
# macOS doesn't have `realpath`, so we do it the hard way here.
# Source: https://stackoverflow.com/questions/4175264/
absolutePath () {
  local thePath
  if [[ ! "$1" =~ ^/ ]]; then
    thePath="$PWD/$1"
  else
    thePath="$1"
  fi

  echo "$thePath"|(
    IFS=/
    read -a parr
    declare -a outp
    for i in "${parr[@]}";do
      case "$i" in
      ''|.) continue ;;
      ..)
        len=${#outp[@]}
        if ((len == 0));then
          continue
        else
          unset outp[$((len-1))]
        fi
        ;;
      *)
        len=${#outp[@]}
        outp[$len]="$i"
        ;;
      esac
    done
    echo /"${outp[*]}"
  )
}


# Given the name of a Docker network, return 0 if the network exists, else 1
dockerNetworkExists () {
  local DOCKER_NETWORK=$1

  if [[ -n $(docker network ls --quiet --filter name=${DOCKER_NETWORK}) ]]; then
    return 0
  else
    return 1
  fi
}

# Generate a random ID to append to the container name
randomString () {
  local LENGTH=${1:4}
  echo $(perl -pe 'binmode(STDIN, ":bytes"); tr/a-zA-Z0-9//dc;' < /dev/urandom | head -c 4)
}


getProjectRoot () {
  # TODO: Use a more certain method of finding the project root. This method fails if the current
  #  project is not in a Git repo or if the project has submodules.
  echo $(git rev-parse --show-toplevel)
}


showHelp () {
  echo "Usage: $0 [NODE_ENV]" 1>&2
  echo "(NODE_ENV defaults to 'development')"
}
# -- End of helper functions


# -- Read package variables
# Store the project's root dir so that the project's `.env` file can be loaded
MOUNTED_PROJECT_ROOT=$(getProjectRoot)

# Find the real location of the current script
SCRIPT_RELATIVE_PATH="$0"
if [[ -h "${SCRIPT_RELATIVE_PATH}" ]]; then
  # The file is a symlink, so find its target. Change to the script's directory so that the
  # relative path is correctly resolved
  cd $(dirname "$0")
  SCRIPT_RELATIVE_PATH=$(readlink "$0")
fi

SCRIPT_ABSOLUTE_PATH=$(absolutePath ${SCRIPT_RELATIVE_PATH})
SCRIPT_ABSOLUTE_DIR=$(dirname ${SCRIPT_ABSOLUTE_PATH})
cd "${SCRIPT_ABSOLUTE_DIR}"

# Read this module's environment variables from file
source variables.sh
if [[ $? -ne 0 ]]; then
  echo -e "The variables file could not be found. Aborting."
  exit 1
fi

# Validate variables
if [[ -z ${DOCKER_ACCOUNT_NAME} || -z ${PACKAGE_NAME} || -z ${PACKAGE_VERSION} ]]
then
  echo "variables.sh must define ACCOUNT_NAME, PACKAGE_NAME, and VERSION" 1>&2
  exit 1
fi


# Include helper functions.
source include/functions.sh
if [[ $? -ne 0 ]]; then
  echo -e "The functions file could not be found. Aborting."
  exit 1
fi


# Read environment variables from the project's `.env` file, if any
cd ${MOUNTED_PROJECT_ROOT}
if [[ -f '.env' ]]
then
  source .env
fi

# Read project's environment variables from file
# TODO: REFACTOR: Maybe add a flexible env var handler
if [[ -f .env ]]; then
  source .env
fi


# Defaults. Override by setting these values in environment variables or `.env`
DOCKER_NETWORK=${DOCKER_NETWORK:='default'}
PACKAGE_DEFAULT_CMD=${PACKAGE_DEFAULT_CMD:='bash'}
PROJECT_ID=${PROJECT_ID:='node10-app'}
WEB_SERVER_PORT=${WEB_SERVER_PORT:='8080'}


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
  CMD=${PACKAGE_DEFAULT_CMD}
fi


# The code below respects `NODE_ENV`, defaulting to `development` if NODE_ENV isn't set
if [[ ${CMD} == 'test' ]]; then
  CMD='npm run test'
  NODE_ENV='development'
else
  NODE_ENV=${NODE_ENV:='development'}
fi

if [[ ${DOCKER_NETWORK} != 'default' ]]; then
  if ! dockerNetworkExists ${DOCKER_NETWORK}; then
    echo "WARNING: No Docker network with the name '${DOCKER_NETWORK}' was found. The 'default' network will be used" 1>&2
    DOCKER_NETWORK='default'
  fi
fi

echo -e "Mounting the project into a container:"
echo "|  command:     ${CMD}"
echo "|  environment: ${NODE_ENV}"
echo "|  network:     ${DOCKER_NETWORK}"


docker container run \
  --interactive \
  --rm \
  --tty \
  --env NODE_ENV=${NODE_ENV} \
  --expose ${WEB_SERVER_PORT} \
  --mount type=bind,source=${PWD},target=/var/project \
  --name ${PROJECT_ID}-$(randomString 4) \
  --network ${DOCKER_NETWORK} \
  --publish ${WEB_SERVER_PORT}:${WEB_SERVER_PORT} \
  --workdir /var/project \
  ${PACKAGE_IMAGE_BASE_NAME}:${PACKAGE_VERSION} \
  ${CMD}
