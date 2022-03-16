#!/bin/sh

DIRECTORY=`dirname "$0"`
export $(grep -v '^#' ${DIRECTORY}/versions | xargs)

PAPERMC_LATEST_BUILD=$(curl --silent https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION} | sed -n 's/.*"builds":\[.*,\([0-9]*\)\].*/\1/p')
if [ "${PAPERMC_LATEST_BUILD}" -gt "${PAPERMC_BUILD}" ]; then
    echo "PaperMC is being updated (current build: ${PAPERMC_BUILD}; latest build: ${PAPERMC_LATEST_BUILD})"
    sed -i.bak "s/^\(PAPERMC_BUILD=\).*/\1${PAPERMC_LATEST_BUILD}/" ${DIRECTORY}/versions
fi

GEYSERMC_LATEST_BUILD=$(curl --silent https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/buildNumber)
if [ "${GEYSERMC_LATEST_BUILD}" -gt "${GEYSERMC_BUILD}" ]; then
    echo "GayserMC is being updated (current build: ${GEYSERMC_BUILD}; latest build: ${GEYSERMC_LATEST_BUILD})"
    sed -i.bak "s/^\(GEYSERMC_BUILD=\).*/\1${GEYSERMC_LATEST_BUILD}/" ${DIRECTORY}/versions
fi

FLOODGATE_LATEST_BIULD=$(curl --silent https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/buildNumber)
if [ "${FLOODGATE_LATEST_BIULD}" -gt "${FLOODGATE_BIULD}" ]; then
    echo "Floodgate is being updated (current build: ${FLOODGATE_BIULD}; latest build: ${FLOODGATE_LATEST_BIULD})"
    sed -i.bak "s/^\(FLOODGATE_BIULD=\).*/\1${FLOODGATE_LATEST_BIULD}/" ${DIRECTORY}/versions
fi

MULTIVERSE_CORE_LATEST_BUILD=$(curl --silent https://ci.onarandombox.com/job/Multiverse-Core/lastSuccessfulBuild/buildNumber)
if [ "${MULTIVERSE_CORE_LATEST_BUILD}" -gt "${MULTIVERSE_CORE_BUILD}" ]; then
    echo "Multiverse core is being updated (current build: ${MULTIVERSE_CORE_BUILD}; latest build: ${MULTIVERSE_CORE_LATEST_BUILD})"
    sed -i.bak "s/^\(MULTIVERSE_CORE_BUILD=\).*/\1${MULTIVERSE_CORE_LATEST_BUILD}/" ${DIRECTORY}/versions
fi

MCRCON_LATEST_TAG=$(curl --silent https://api.github.com/repos/Tiiffi/mcrcon/releases/latest | sed -n 's/.*"tag_name":[[:space:]]*"\(.*\)".*/\1/p')
if [ "${MCRCON_LATEST_TAG}" != "${MCRCON_TAG}" ]; then
    echo "MCRcon is being updated (current tag: ${MCRCON_TAG}; latest tag: ${MCRCON_LATEST_TAG})"
    sed -i.bak "s/^\(MCRCON_TAG=\).*/\1${MCRCON_LATEST_TAG}/" ${DIRECTORY}/versions
fi
