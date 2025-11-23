# OrcaSlicer for arm64

OrcaSlicer that works in Raspberry Pi and other SBC

I don't recommend running it on any SBC with less than 2GB of ram - the container itself may use around 2GB RAM. For less than 4GB of ram it is very recommended to create a 4GB swapfile, as without it the app may hang up your computer.

```sh
if ! swapon --show | grep /swapfile &> /dev/null # Remove old swapfile, systems may init with small (500MB) swapfile
then
    sudo swapoff /swapfile
    sudo rm /swapfile
    sudo sed -i '/^\/swapfile/d' /etc/fstab
fi
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "
/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
swapon --show
```

How to run:
```yml
services:
  orcaslicer:
    image: matszwe02/orcaslicer-arm:v2.3.0
    platform: linux/arm64 # optional
    ports:
      - 3000:3000
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - ./config:/config/.config/OrcaSlicer
    cap_add:
      - SYS_NICE
```

Repo should run nightly builds every 2 days plus release builds, specifying `latest` tag will pull nightly builds.
