#!/bin/sh

# Generate rcon password if not set
if [ -z "${MC_RCON_PASS}" ]; then
    MC_RCON_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;)
fi

PLUGIN_ARGS=""

if [ -n "${MC_MULTIVERSE_CORE_ENABLE}" ]; then
    PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/Multiverse-Core.jar"
    if [ ! -d "/opt/minecraft/work/Multiverse-Core" ]; then
        mkdir "/opt/minecraft/work/Multiverse-Core"
        chmod g=u "/opt/minecraft/work/Multiverse-Core"
    fi
    ln -s /opt/minecraft/work/Multiverse-Core /opt/minecraft/plugins/Multiverse-Core
fi

# Update configuraion files
echo "eula=true" > /opt/minecraft/work/eula.txt
sed -i "
    s/%MC_SERVER_NAME%/${MC_SERVER_NAME}/
    s/%MC_MAX_PLAYERS%/${MC_MAX_PLAYERS}/
    s/%MC_RCON_ENABLE%/${MC_RCON_ENABLE}/
    s/%MC_RCON_PASS%/${MC_RCON_PASS}/
    s/%MC_ENFORCE_SECURE_PROFILE%/${MC_ENFORCE_SECURE_PROFILE}/" \
    /opt/minecraft/conf/server.properties \
    /opt/minecraft/conf/paper/paper-global.yml \
    /opt/minecraft/plugins/Geyser-Spigot/config.yml \
    /opt/minecraft/plugins/floodgate/config.yml
    
exec java \
    -Xms${MC_XMS} -Xmx${MC_XMX} \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
    -jar /opt/minecraft/jars/paper.jar \
    -C /opt/minecraft/conf/commands.yml \
    -S /opt/minecraft/conf/spigot.yml \
    -b /opt/minecraft/conf/bukkit.yml \
    -c /opt/minecraft/conf/server.properties \
    --paper-settings-directory /opt/minecraft/conf/paper \
    --add-plugin /opt/minecraft/jars/geyser-spigot.jar \
    --add-plugin /opt/minecraft/jars/floodgate-spigot.jar \
    -P /opt/minecraft/plugins \
    --log-append false \
    --nogui \
    --noconsole ${PLUGIN_ARGS}
