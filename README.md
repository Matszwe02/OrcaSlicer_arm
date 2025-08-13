# OrcaSlicer for arm64

OrcaSlicer that works in Raspberry Pi and other SBC

I don't recommend running it on any SBC with less than 2GB of ram - the image itself may use around 2GB RAM. For less than 4GB of ram it is very recommended to create a 4GB swapfile, as without it the app may hang up your computer.

How to run:
```yml
services:
  orcaslicer:
    image: matszwe02/orcaslicer-arm:v2.3.0
    platform: linux/arm64 # optional
    ports:
      - 3000:3000
      - 3001:3001
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - ./orca-config:/config/.config/OrcaSlicer
    cap_add:
      - SYS_NICE
```

Repo should run daily nightly builds plus release builds, specifying `latest` tag will pull nightly builds.
