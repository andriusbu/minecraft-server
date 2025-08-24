#!/bin/sh

RED='\033[0;31m' # Turn on red color
BOLD='\033[1m'   # Turn on bold
NC='\033[0m'     # No Color

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Default values for command line arguments
CONTAINER_REPO="minecraft-server"
CONTAINER_TAG="latest"
CONTAINER_ARCH=""

show_help() {
    echo ""
    echo "Usage:"
    echo ""
    echo "  build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo " -r repo   container repository (default: minecraft-server)"
    echo " -t tag    container tag (default: latest)"
    echo " -a arch   container architecture (default: system architecture)"
    echo " -h -?     show help"
    echo ""
}

while getopts "h?r:t:a:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    r)  CONTAINER_REPO=$OPTARG
      ;;
    t)  CONTAINER_TAG=$OPTARG
      ;;
    a)  CONTAINER_ARCH=$OPTARG
      ;;
  esac
done

PODMAN_ARG="--tag ${CONTAINER_REPO}:${CONTAINER_TAG}"

if [ -n "${CONTAINER_ARCH}" ]; then
    PODMAN_ARG="${PODMAN_ARG} --arch ${CONTAINER_ARCH}"
fi

if ! [ -x "$(command -v podman)" ]; then
    echo "${RED}ERROR:${NC} ${BOLD}podman${NC} could not be found"
    exit 1
fi

DIRECTORY=`dirname "$0"`

export $(grep -v '^#' ${DIRECTORY}/versions | xargs)

podman build ${PODMAN_ARG}\
    --build-arg JDK_VERSION=${JDK_VERSION} \
    --build-arg PAPERMC_VERSION=${PAPERMC_VERSION} \
    --build-arg PAPERMC_BUILD=${PAPERMC_BUILD} \
    --build-arg GEYSERMC_VERSION=${GEYSERMC_VERSION} \
    --build-arg GEYSERMC_BUILD=${GEYSERMC_BUILD} \
    --build-arg FLOODGATE_VERSION=${FLOODGATE_VERSION} \
    --build-arg FLOODGATE_BIULD=${FLOODGATE_BIULD} \
    --build-arg VIAVERSION_VERSION=${VIAVERSION_VERSION} \
    --build-arg MCRCON_TAG=${MCRCON_TAG} \
    --build-arg WORLDEDIT_URL=${WORLDEDIT_URL} \
    --build-arg WORLDGUARD_URL=${WORLDGUARD_URL} \
    --build-arg LUCKPERMS_URL=${LUCKPERMS_URL} \
    ${DIRECTORY}/minecraft-server/