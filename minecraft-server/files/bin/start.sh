#!/bin/sh

# Set default values for environment variables
if [ -z "${MC_SERVER_NAME}" ]; then
    echo "Setting server name to default 'Minecraft Server'"
    MC_SERVER_NAME="Minecraft Server"
fi

if [ -z "${MC_MAX_PLAYERS}" ]; then
    echo "Setting max players to default 10"
    MC_MAX_PLAYERS=10
fi

if [ -z "${MC_RCON_ENABLE}" ]; then
    echo "Setting RCON enable to default false"
    MC_RCON_ENABLE=false
fi

if [ -z "${MC_RCON_PASS}" ]; then
    echo "Generating RCON password..."
    MC_RCON_PASS=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;)
fi

if [ -z "${MC_ENFORCE_SECURE_PROFILE}" ]; then
    echo "Setting enforce secure profile to default true"
    MC_ENFORCE_SECURE_PROFILE=true
fi

# Generete server UUID if not set
if [ ! -s /opt/minecraft/work/uuid.txt ]; then
    echo "Generating server UUID..."
    cat /proc/sys/kernel/random/uuid > /opt/minecraft/work/uuid.txt
fi
MC_SERVER_UUID=$(cat /opt/minecraft/work/uuid.txt)
echo "Server UUID: ${MC_SERVER_UUID}"

# Prepare Paper arguments
PAPER_ARGS=""
PAPER_ARGS="${PAPER_ARGS} --online-mode true"
PAPER_ARGS="${PAPER_ARGS} --server-name \"${MC_SERVER_NAME}\"" 
PAPER_ARGS="${PAPER_ARGS} --max-players ${MC_MAX_PLAYERS}"
PAPER_ARGS="${PAPER_ARGS} --serverId ${MC_SERVER_UUID}"
PAPER_ARGS="${PAPER_ARGS} --log-append false"
PAPER_ARGS="${PAPER_ARGS} --nogui"
PAPER_ARGS="${PAPER_ARGS} --noconsole"

# Prepare plugin arguments
PLUGIN_ARGS=""
PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/geyser-spigot.jar"
PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/floodgate-spigot.jar"

if [ -z "${MC_VIAVERSION_DISABLE}" ]; then
    echo "Adding ViaVersion plugin..."
    PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/ViaVersion.jar"
fi

if [ -z "${MC_WORLD_EDIT_DISABLE}" ]; then
    echo "Adding WorldEdit plugin..."
    PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/worldedit.jar"
fi

if [ -z "${MC_WORLD_GUARD_DISABLE}" ]; then
    echo "Adding WorldGuard plugin..."
    PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/worldguard.jar"
fi

if [ -z "${MC_LUCKPERMS_DISABLE}" ]; then
    echo "Adding LuckPerms plugin..."
    PLUGIN_ARGS="${PLUGIN_ARGS} --add-plugin /opt/minecraft/jars/luckperms.jar"
fi

# Populate cache
echo "Populating cache..."
mkdir -p /opt/minecraft/work/cache
cp /opt/minecraft/jars/mojang*.jar /opt/minecraft/work/cache/

# Generate and patch config files
if [ ! -s /opt/minecraft/work/eula.txt ]; then
    echo "Generating EULA file..."
    echo "eula=true" > /opt/minecraft/work/eula.txt
fi

if [ ! -s /opt/minecraft/work/server.properties ]; then
    echo "Generating initial config file..."
    java -jar /opt/minecraft/jars/paper.jar ${PAPER_ARGS} ${PLUGIN_ARGS} --initSettings
fi

echo "Applying configuration from env vars..."
sed -i "
    s/white-list=.*/white-list=true/
    s/motd=.*/motd=${MC_SERVER_NAME}/
    s/enable-rcon=.*/enable-rcon=${MC_RCON_ENABLE}/
    s/rcon.password=.*/rcon.password=${MC_RCON_PASS}/
    s/enforce-secure-profile=.*/enforce-secure-profile=${MC_ENFORCE_SECURE_PROFILE}/
" server.properties

sed -i "
    s/%MC_SERVER_UUID%/${MC_SERVER_UUID}/
    s/%MC_SERVER_NAME%/${MC_SERVER_NAME}/
    s/%MC_MAX_PLAYERS%/${MC_MAX_PLAYERS}/" \
    /opt/minecraft/plugins/bStats/config.yml \
    /opt/minecraft/plugins/floodgate/config.yml \
    /opt/minecraft/plugins/Geyser-Spigot/config.yml

echo "Copying plugin configuration files..."
mkdir -p /opt/minecraft/work/plugins
(cd ../plugins/ && find . -type f -exec cp --parents {} /opt/minecraft/work/plugins/ \;)

# Start the server
echo "Starting Minecraft server..."
exec java \
    -Xms${MC_XMS} -Xmx${MC_XMX} \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true \
    -jar /opt/minecraft/jars/paper.jar \
    ${PAPER_ARGS} \
    ${PLUGIN_ARGS}