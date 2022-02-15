ARG JDK_VERSION
# Build mcrcon
FROM docker.io/library/gcc:11 AS builder

WORKDIR /build
RUN git clone -c advice.detachedHead=false --depth 1 --branch v0.7.2 https://github.com/Tiiffi/mcrcon.git . && \
    make

#Alpine image version does not support arm64
FROM docker.io/library/openjdk:${JDK_VERSION}

RUN mkdir -p \
    /opt/minecraft/plugins/Geyser-Spigot \
    /opt/minecraft/plugins/floodgate \
    /opt/minecraft/conf \
    /opt/minecraft/work \
    /opt/minecraft/bin

COPY files/ /opt/minecraft
COPY --from=builder /build/mcrcon /opt/minecraft/bin/

ARG PAPERMC_VERSION
ARG PAPERMC_BUILD
ARG GEYSERMC_BUILD
ARG FLOODGATE_BIULD
ADD https://papermc.io/api/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}/downloads/paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar /opt/minecraft/paper.jar
ADD https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/${GEYSERMC_BUILD}/artifact/bootstrap/spigot/target/Geyser-Spigot.jar /opt/minecraft/plugins/geyser-spigot.jar
ADD https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/63/artifact/spigot/target/floodgate-spigot.jar /opt/minecraft/plugins/floodgate-spigot.jar

RUN chmod -R g=u /opt/minecraft

ENV MC_XMS=2g
ENV MC_XMX=2g
ENV MC_SERVER_NAME="Minecraft Server"
ENV MC_MAX_PLAYERS=10
ENV MC_RCON_ENABLE=false
ENV MC_RCON_PASS=""

ENV PATH=/opt/minecraft/bin:${PATH}
WORKDIR /opt/minecraft/work
USER 1000
EXPOSE 25565/tcp 25575/tcp 19132/udp

CMD [ "/bin/sh", "-c", "/opt/minecraft/start.sh" ]
