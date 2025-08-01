#!/bin/bash

server=/satisfactory
config=/home/steam/.config

# check user
if [ $(id -u) -eq 0 ]; then
	echo "WARNING: Run steamcmd with root user is a security risk. see: https://developer.valvesoftware.com/wiki/SteamCMD" >&2
	echo "TIP: This image provides steam user with uid($(id steam -u)) and gid($(id steam -g)) as default"
fi

# Check if we have proper read/write permissions
if [ ! -r "$server" ] || [ ! -w "$server" ]; then
    echo "ERROR: I do not have read/write permissions to $server! Please run "chown -R $(id -u):$(id -g) $server" on host machine, then try again." >&2
    exit 1
fi

term_handler() {
	echo "Shutting down Server"

	PID=$(pgrep -of "$server/FactoryServer.sh")
	if [[ -z $PID ]]; then
		echo "Could not find FactoryServer.sh pid. Assuming server is dead..."
	else
		kill -n 15 "$PID"
		wait "$PID"
	fi
	sleep 1
	exit
}

trap 'term_handler' SIGTERM SIGINT SIGKILL

echo " "
echo "Updating SteamCMD files..."
echo " "
status_steamcmd=1

while [ $status_steamcmd -ne 0 ]; do
	box86 /home/steam/linux32/steamcmd +quit
	status_steamcmd=$?
done
echo " "
echo "Updating Satisfactory Dedicated Server files..."
echo " "
box86 /home/steam/linux32/steamcmd +force_install_dir "$server" +login anonymous +app_update 1690800 validate +quit
echo " "

mkdir -p "$data/Settings"

echo "Starting Satisfactory Dedicated Server"

chmod +x FactoryServer.sh || true

box64 "$server/FactoryServer.sh" &
# Gets the PID of the last command
ServerPID=$!

wait $ServerPID
