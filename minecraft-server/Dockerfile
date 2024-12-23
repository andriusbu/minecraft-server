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
ARG GEYSERMC_VERSION
ARG GEYSERMC_BUILD
ARG FLOODGATE_VERSION
ARG FLOODGATE_BIULD
ARG VIAVERSION_VERSION
# ARG MULTIVERSE_CORE_BUILD
RUN mkdir -p /app/jars && \
    curl --silent https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}/downloads/paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar --output /app/jars/paper.jar && \
    curl --silent https://download.geysermc.org/v2/projects/geyser/versions/${GEYSERMC_VERSION}/builds/${GEYSERMC_BUILD}/downloads/spigot --output /app/jars/geyser-spigot.jar && \
    curl --silent https://download.geysermc.org/v2/projects/floodgate/versions/${FLOODGATE_VERSION}/builds/${FLOODGATE_BIULD}/downloads/spigot --output /app/jars/floodgate-spigot.jar && \
    curl --silent --location https://github.com/ViaVersion/ViaVersion/releases/download/${VIAVERSION_VERSION}/ViaVersion-${VIAVERSION_VERSION}.jar --output /app/jars/ViaVersion.jar

    # curl --silent https://ci.onarandombox.com/job/Multiverse-Core/${MULTIVERSE_CORE_BUILD}/artifact/target/Multiverse-Core-4.3.2-SNAPSHOT.jar  --output /app/jars/Multiverse-Core.jar && \
    
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
    MC_VIAVERSION_ENABLE= \
    PATH=/opt/minecraft/bin:${PATH}
    
    # MC_MULTIVERSE_CORE_ENABLE= \

WORKDIR /opt/minecraft/work
USER 1000
EXPOSE 25565/tcp 25575/tcp 19132/udp

CMD [ "/bin/sh", "-c", "/opt/minecraft/bin/start.sh" ]
