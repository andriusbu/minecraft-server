FROM docker.io/library/busybox:1.36.1 AS builder

ARG VELOCITY_VERSION
ARG VELOCITY_BUILD
ARG VELOCITY_GEYSERMC_VERSION
ARG VELOCITY_GEYSERMC_BUILD
ARG VELOCITY_FLOODGATE_VERSION
ARG VELOCITY_FLOODGATE_BIULD
RUN mkdir -p /app/jars && \
    mkdir -p /app/work && \
    wget https://api.papermc.io/v2/projects/velocity/versions/${VELOCITY_VERSION}/builds/${VELOCITY_BUILD}/downloads/velocity-${VELOCITY_VERSION}-${VELOCITY_BUILD}.jar -O /app/jars/velocity.jar && \
    wget https://download.geysermc.org/v2/projects/geyser/versions/${VELOCITY_GEYSERMC_VERSION}/builds/${VELOCITY_GEYSERMC_BUILD}/downloads/velocity -O /app/jars/Geyser-Velocity.jar && \
    wget https://download.geysermc.org/v2/projects/floodgate/versions/${VELOCITY_FLOODGATE_VERSION}/builds/${VELOCITY_FLOODGATE_BIULD}/downloads/velocity -O /app/jars/floodgate-velocity.jar
COPY files/ /app

RUN chmod -R g=u /app

ARG JDK_VERSION
FROM  docker.io/library/openjdk:${JDK_VERSION}-slim
ENV XMS=512m \
    XMX=512m

COPY --from=builder /app /opt/velocity

WORKDIR /opt/velocity/work
USER 1000

CMD [ "/bin/sh", "-c", "/opt/velocity/bin/start.sh" ]
