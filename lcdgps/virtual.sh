sudo systemd-run --service-type=notify --unit=virtual.service \
    evsieve \
    --input /dev/input/by-path/platform-rotary* \
    --map rel:x:-1 key:down:1 key:down:0 \
    --map rel:x:1 key:up:1 key:up:0 \
    --input /dev/input/by-path/platform-button* \
    --output name=virtual
