#!/bin/bash

# Exit immediately if some command returns a non-zero status
set -e

echo "Creating common directories and files in /var/run"

cd /var/run

mkdir -pv -m 755 console
mkdir -pv -m 700 cryptsetup
mkdir -pv -m 755 faillock
mkdir -pv -m 755 lock
mkdir -pv -m 775 lock/lockdev
mkdir -pv -m 755 lock/subsys
mkdir -pv -m 755 log
mkdir -pv -m 755 sepermit
mkdir -pv -m 755 setrans
mkdir -pv -m 755 systemd
mkdir -pv -m 755 systemd/ask-password
mkdir -pv -m 755 systemd/machines
mkdir -pv -m 755 systemd/netif
mkdir -pv -m 755 systemd/netif/leases
mkdir -pv -m 755 systemd/netif/links
mkdir -pv -m 755 systemd/seats
mkdir -pv -m 755 systemd/sessions
mkdir -pv -m 755 systemd/shutdown
mkdir -pv -m 755 systemd/users
mkdir -pv -m 755 user

touch -a utmp
chmod 664 utmp

chown -c root:lock lock/lockdev
chown -cR systemd-network:systemd-network systemd/netif
chown root:utmp utmp

echo "Creating directories and files required by installed packages in /var/run"
 
cd /var/run

mkdir -pv -m 710 httpd
mkdir -pv -m 700 httpd/htcacheclean
mkdir -pv -m 755 postgresql
mkdir -pv -m 711 sudo
mkdir -pv -m 700 sudo/ts
mkdir -pv -m 770 supervisor

chown -c root:apache httpd
chown -c apache:apache httpd/htcacheclean
chown -c postgres:postgres postgresql

# Make the entrypoint a pass through that then runs the docker CMD
exec "$@"