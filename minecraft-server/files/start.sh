#!/bin/sh

# Generate rcon password if not set
if [ -z "${MC_RCON_PASS}" ]; then
    MC_RCON_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;)
fi

# Update configuraion files
echo "eula=true" > /opt/minecraft/work/eula.txt
sed -i "
    s/%MC_SERVER_NAME%/${MC_SERVER_NAME}/
    s/%MC_MAX_PLAYERS%/${MC_MAX_PLAYERS}/
    s/%MC_RCON_PASS%/${MC_RCON_PASS}/" \
    ../conf/server.properties \
    ../conf/paper.yml \
    ../plugins/Geyser-Spigot/config.yml \
    ../plugins/floodgate/config.yml

exec java \
    -Xms${MC_XMS} -Xmx${MC_XMX} \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
    -jar /opt/minecraft/paper.jar \
    -C /opt/minecraft/conf/commands.yml \
    -S /opt/minecraft/conf/spigot.yml \
    -b /opt/minecraft/conf/bukkit.yml \
    -c /opt/minecraft/conf/server.properties \
    --paper /opt/minecraft/conf/paper.yml \
    -P /opt/minecraft/plugins \
    --log-append false \
    --nogui \
    --noconsole
