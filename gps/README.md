[modeline]: # ( vim: set ft=markdown sts=4 sw=4 et: )


# ublox config from gpsd

[ubxtools examples](https://gpsd.gitlab.io/gpsd/ubxtool-examples.html)  


```
export UBXOPTS="-P 14"
ubxtool -p RESET
ubxtool -S 115200
ubxtool -e BINARY
ubxtool -d NMEA
ubxtool -p CFG-RATE,100
ubxtool -p MODEL,4
ubxtool -p SAVE
```
