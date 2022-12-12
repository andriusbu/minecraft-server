# Build mcrcon from source
ARG JDK_VERSION
FROM docker.io/library/gcc:11 AS builder

WORKDIR /build

COPY files/ /app

ARG MCRCON_TAG
RUN git clone -c advice.detachedHead=false --depth 1 --branch ${MCRCON_TAG} https://github.com/Tiiffi/mcrcon.git . && \
    make && \
    mv mcrcon /app/bin/mcrcon

ARG PAPERMC_VERSION
ARG PAPERMC_BUILD
ARG GEYSERMC_BUILD
ARG FLOODGATE_BIULD
ARG MULTIVERSE_CORE_BUILD
RUN mkdir -p /app/jars && \
    curl --silent https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}/downloads/paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar --output /app/jars/paper.jar && \
    curl --silent https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/${GEYSERMC_BUILD}/artifact/bootstrap/spigot/build/libs/Geyser-Spigot.jar --output /app/jars/geyser-spigot.jar && \
    curl --silent https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/${FLOODGATE_BIULD}/artifact/spigot/build/libs/floodgate-spigot.jar --output /app/jars/floodgate-spigot.jar && \
    curl --silent https://ci.onarandombox.com/job/Multiverse-Core/${MULTIVERSE_CORE_BUILD}/artifact/target/Multiverse-Core-4.3.2-SNAPSHOT.jar  --output /app/jars/Multiverse-Core.jar
    
RUN chmod -R g=u /app

# Build Minecraft server container
FROM  docker.io/library/openjdk:${JDK_VERSION}-slim

COPY --from=builder /app/ /opt/minecraft

ENV MC_XMS=2g \
    MC_XMX=2g \
    MC_SERVER_NAME="Minecraft Server" \
    MC_MAX_PLAYERS=10 \
    MC_RCON_ENABLE=false \
    MC_RCON_PASS="" \
    MC_ENFORCE_SECURE_PROFILE=true \
    MC_MULTIVERSE_CORE_ENABLE= \
    PATH=/opt/minecraft/bin:${PATH}

WORKDIR /opt/minecraft/work
USER 1000
EXPOSE 25565/tcp 25575/tcp 19132/udp

CMD [ "/bin/sh", "-c", "/opt/minecraft/bin/start.sh" ]
