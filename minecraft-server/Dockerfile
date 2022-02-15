ARG JDK_VERSION

#Alpine image version does not support arm64
FROM docker.io/library/openjdk:${JDK_VERSION}

RUN mkdir -p \
    /opt/minecraft/plugins/Geyser-Spigot \
    /opt/minecraft/plugins/floodgate \
    /opt/minecraft/conf \
    /opt/minecraft/work

COPY files/ /opt/minecraft

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

WORKDIR /opt/minecraft/work
USER 1000
EXPOSE 25565/tcp 25575/tcp 19132/udp

CMD [ "/bin/sh", "-c", "/opt/minecraft/start.sh" ]
