ARG debian_version=bookworm

FROM debian:${debian_version}-slim

ENV DEBIAN_FRONTEND="noninteractive"

LABEL maintainer="joaop221"

ARG debian_version=bookworm

# Install libraries needed to run box and satisfactory
# reconfigure locales
# Install box64 and box86
RUN set -eux; \
 dpkg --add-architecture armhf && dpkg --add-architecture i386; \
    apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    wget curl ca-certificates locales procps gpg libc6:armhf libc6:arm64 libc6:i386 libxi6:arm64; \
 locale-gen en_US.UTF-8 && dpkg-reconfigure locales; \
 wget -qO- "https://pi-apps-coders.github.io/box64-debs/KEY.gpg" | gpg --dearmor -o /usr/share/keyrings/box64-archive-keyring.gpg; \
 wget -qO- "https://pi-apps-coders.github.io/box86-debs/KEY.gpg" | gpg --dearmor -o /usr/share/keyrings/box86-archive-keyring.gpg; \
 echo "deb [signed-by=/usr/share/keyrings/box64-archive-keyring.gpg] https://Pi-Apps-Coders.github.io/box64-debs/debian ./" | tee /etc/apt/sources.list.d/box64.list; \
 echo "deb [signed-by=/usr/share/keyrings/box86-archive-keyring.gpg] https://Pi-Apps-Coders.github.io/box86-debs/debian ./" | tee /etc/apt/sources.list.d/box86.list; \
 apt-get update && apt-get install -y --install-recommends --no-install-suggests box64-rpi4arm64 box86-rpi4arm64:armhf; \
 apt-get -y autoremove; \
 apt-get clean autoclean; \
 rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US:en'

ARG UID=1001
ARG GID=1001
 
# Setup steam user
RUN set -eux; \
 groupadd -g ${GID} steam && useradd -u ${UID} -m steam -g steam; \
 wget -qO - "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C /home/steam; \
 chown -R steam:steam /home/steam

VOLUME ["/satisfactory", "/config"]

USER steam
WORKDIR /home/steam

# Define the health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=10m \
    CMD /home/steam/healthz.sh

# Run steamcmd to update the server
RUN set -ux; \
    status_steamcmd=1; \
    while [ $status_steamcmd -ne 0 ]; do \
        /home/steam/steamcmd.sh +quit; \
	    status_steamcmd=$?; \
    done

ADD --chown=steam:steam scripts /home/steam/

RUN set -eux; \
    chmod +x /home/steam/init-server.sh /home/steam/healthz.sh

# Run it
CMD ["/home/steam/init-server.sh"] 