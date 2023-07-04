

ln -sfr ../jars/velocity.jar velocity.jar
mkdir plugins
ln -sfr ../jars/Geyser-Velocity.jar plugins/Geyser-Velocity.jar
ln -sfr ../jars/floodgate-velocity.jar plugins/floodgate-velocity.jar

java -Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar velocity*.jar 