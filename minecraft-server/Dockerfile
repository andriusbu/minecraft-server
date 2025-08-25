# Build mcrcon from source
ARG JDK_VERSION
FROM docker.io/library/gcc:11 AS builder

WORKDIR /build

ARG MCRCON_TAG
RUN git clone -c advice.detachedHead=false --depth 1 --branch ${MCRCON_TAG} https://github.com/Tiiffi/mcrcon.git . && \
    make && \
    mkdir -p /app/bin && \
    mv mcrcon /app/bin/mcrcon

ARG PAPERMC_VERSION
ARG PAPERMC_BUILD
ARG GEYSERMC_VERSION
ARG GEYSERMC_BUILD
ARG FLOODGATE_VERSION
ARG FLOODGATE_BIULD
ARG VIAVERSION_VERSION
ARG WORLDEDIT_URL
ARG WORLDGUARD_URL
ARG LUCKPERMS_URL
ARG MOJANG_URL

RUN mkdir -p /app/jars
RUN curl --silent https://api.papermc.io/v2/projects/paper/versions/${PAPERMC_VERSION}/builds/${PAPERMC_BUILD}/downloads/paper-${PAPERMC_VERSION}-${PAPERMC_BUILD}.jar --output /app/jars/paper.jar
RUN curl --silent https://download.geysermc.org/v2/projects/geyser/versions/${GEYSERMC_VERSION}/builds/${GEYSERMC_BUILD}/downloads/spigot --output /app/jars/geyser-spigot.jar
RUN curl --silent https://download.geysermc.org/v2/projects/floodgate/versions/${FLOODGATE_VERSION}/builds/${FLOODGATE_BIULD}/downloads/spigot --output /app/jars/floodgate-spigot.jar
RUN curl --silent --location https://github.com/ViaVersion/ViaVersion/releases/download/${VIAVERSION_VERSION}/ViaVersion-${VIAVERSION_VERSION}.jar --output /app/jars/ViaVersion.jar
RUN curl --silent --location ${WORLDEDIT_URL} --output /app/jars/worldedit.jar
RUN curl --silent --location ${WORLDGUARD_URL} --output /app/jars/worldguard.jar 
RUN curl --silent --location ${LUCKPERMS_URL} --output /app/jars/luckperms.jar
RUN curl --silent --location ${MOJANG_URL} --output /app/jars/mojang_${PAPERMC_VERSION}.jar
  
COPY files/ /app

RUN chmod -R g=u /app

# Build Minecraft server container
FROM  docker.io/library/openjdk:${JDK_VERSION}-slim

COPY --from=builder /app /opt/minecraft

ENV MC_XMS=2g \
    MC_XMX=2g \
    PATH=/opt/minecraft/bin:${PATH}

WORKDIR /opt/minecraft/work
USER 1000
EXPOSE 25565/tcp 25575/tcp 19132/udp

CMD [ "/bin/sh", "-c", "/opt/minecraft/bin/start.sh" ]
