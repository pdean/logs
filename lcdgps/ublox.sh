export UBXOPTS="-P 18"
ubxtool -p RESET
ubxtool -S 115200
ubxtool -e BINARY
ubxtool -d NMEA
ubxtool -p CFG-RATE,100
ubxtool -p MODEL,4
ubxtool -p SAVE
