#!/bin/sh

DIRECTORY=`dirname "$0"`
export $(grep -v '^#' ${DIRECTORY}/versions | xargs)

check_error()
{
    if [ "$?" -ne "0" ]; then
        echo "ERROR: $1"
        exit 1
    fi
}

PAPERMC_LATEST_BUILD=$(curl --silent -fail https://api.papermc.io/v2/projects/paper/versions/${PAPERMC_VERSION} | sed -n 's/.*"builds":\[.*,\([0-9]*\)\].*/\1/p')
check_error "Failed to get PaperMC latest build number"
if [ "${PAPERMC_LATEST_BUILD}" -gt "${PAPERMC_BUILD}" ]; then
    echo "PaperMC is being updated (current build: ${PAPERMC_BUILD}; latest build: ${PAPERMC_LATEST_BUILD})"
    sed -i.bak "s/^\(PAPERMC_BUILD=\).*/\1${PAPERMC_LATEST_BUILD}/" ${DIRECTORY}/versions
fi

GEYSERMC_LATEST_BUILD=$(curl --silent -fail https://download.geysermc.org/v2/projects/geyser/versions/${GEYSERMC_VERSION} | sed -n 's/.*"builds":\[.*,\([0-9]*\)\].*/\1/p')
check_error "Failed to get GeyserMC latest build number"
if [ "${GEYSERMC_LATEST_BUILD}" -gt "${GEYSERMC_BUILD}" ]; then
    echo "GayserMC is being updated (current build: ${GEYSERMC_BUILD}; latest build: ${GEYSERMC_LATEST_BUILD})"
    sed -i.bak "s/^\(GEYSERMC_BUILD=\).*/\1${GEYSERMC_LATEST_BUILD}/" ${DIRECTORY}/versions
fi

FLOODGATE_LATEST_BIULD=$(curl --silent -fail https://download.geysermc.org/v2/projects/floodgate/versions/${FLOODGATE_VERSION} | sed -n 's/.*"builds":\[.*,\([0-9]*\)\].*/\1/p')
check_error "Failed to get Fooldgate latest build number"
if [ "${FLOODGATE_LATEST_BIULD}" -gt "${FLOODGATE_BIULD}" ]; then
    echo "Floodgate is being updated (current build: ${FLOODGATE_BIULD}; latest build: ${FLOODGATE_LATEST_BIULD})"
    sed -i.bak "s/^\(FLOODGATE_BIULD=\).*/\1${FLOODGATE_LATEST_BIULD}/" ${DIRECTORY}/versions
fi

# MULTIVERSE_CORE_LATEST_BUILD=$(curl --silent https://ci.onarandombox.com/job/Multiverse-Core/lastSuccessfulBuild/buildNumber)
# check_error "Failed to get Multiverse latest build number"
# if [ "${MULTIVERSE_CORE_LATEST_BUILD}" -gt "${MULTIVERSE_CORE_BUILD}" ]; then
#     echo "Multiverse core is being updated (current build: ${MULTIVERSE_CORE_BUILD}; latest build: ${MULTIVERSE_CORE_LATEST_BUILD})"
#     sed -i.bak "s/^\(MULTIVERSE_CORE_BUILD=\).*/\1${MULTIVERSE_CORE_LATEST_BUILD}/" ${DIRECTORY}/versions
# fi

MCRCON_LATEST_TAG=$(curl --silent -fail https://api.github.com/repos/Tiiffi/mcrcon/releases/latest | sed -n 's/.*"tag_name":[[:space:]]*"\(.*\)".*/\1/p')
check_error "Failed to get MCRcon latest build number"
if [ "${MCRCON_LATEST_TAG}" != "${MCRCON_TAG}" ]; then
    echo "MCRcon is being updated (current tag: ${MCRCON_TAG}; latest tag: ${MCRCON_LATEST_TAG})"
    sed -i.bak "s/^\(MCRCON_TAG=\).*/\1${MCRCON_LATEST_TAG}/" ${DIRECTORY}/versions
fi

VIAVERSION_LATEST_VERSION=$(curl --silent -fail https://api.github.com/repos/ViaVersion/ViaVersion/releases/latest | sed -n 's/.*"tag_name":[[:space:]]*"\(.*\)".*/\1/p')
check_error "Failed to get ViaVersion latest version"
if [ "${VIAVERSION_LATEST_VERSION}" != "${VIAVERSION_VERSION}" ]; then
    echo "ViaVersion is being updated (current version: ${VIAVERSION_VERSION}; latest version: ${VIAVERSION_LATEST_VERSION})"
    sed -i.bak "s/^\(VIAVERSION_VERSION=\).*/\1${VIAVERSION_LATEST_VERSION}/" ${DIRECTORY}/versions
fi