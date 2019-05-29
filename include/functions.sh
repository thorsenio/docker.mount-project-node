#!/usr/bin/env bash

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


showHelp () {
  echo "Usage: $0 [NODE_ENV]" 1>&2
  echo "(NODE_ENV defaults to 'development')"
}
