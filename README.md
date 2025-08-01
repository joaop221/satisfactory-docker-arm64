# Satisfactory-docker-arm64

Satisfactory Dedicated Server inside Docker ARM64 container.

## Build image locally

To build this image you need an ARM64 System or enable multi-platform support in your container engine. To do so with docker read this: [Multi-platform images](https://docs.docker.com/build/building/multi-platform/).

With this setup done you can proceed to build:

```bash
docker buildx build --pull --platform linux/arm64 -t satisfactory-docker-arm64:local -f debian.Dockerfile . --load
```

> **About buildx:** `--load` will give you an option to load this image at your local images list: [docker builx build reference](https://docs.docker.com/reference/cli/docker/buildx/build/).

## Running image locally

To run this image you do not need to install Satisfactory at your system nor to setup game server externally of docker, but it's recommended to read the doc: [Satisfactory Dedicated Server Instructions](https://satisfactory.wiki.gg/wiki/Dedicated_servers).

See the command (remember to enable multi-platform support or use a ARM64 system):

```bash
docker run -d --platform linux/arm64 \
    -p 7777:7777/tcp \
    -p 8888:8888/tcp \
    -p 7777:7777/udp \
    -v ./volumes/satisfactory/config:/home/steam/.config \
    -v ./volumes/satisfactory/server:/satisfactory \
    ghcr.io/joaop221/satisfactory-docker-arm64:main
```

Keep in mind that you can include additional environment variables and files to pre-configure the behavior of game, as described at Wiki.

## Technical notes

To download the game we need to emulate [steamcmd](https://www.steamcmd.net/) architecture, this is made using [box86](https://github.com/ptitSeb/box86).

And to run Satisfactory Server we need another combination of packages [box64](https://github.com/ptitSeb/box64/blob/main/docs/WINE.md).

## Credits and Links

This image was based on implementation and docs available in:

- [Satisfactory Dedicated Server Instructions](https://satisfactory.wiki.gg/wiki/Dedicated_servers);
- [ptitSeb/box64](https://github.com/ptitSeb/box64);
- [ptitSeb/box86](https://github.com/ptitSeb/box86);
- [wolveix/satisfactory-server](https://github.com/wolveix/satisfactory-server).
