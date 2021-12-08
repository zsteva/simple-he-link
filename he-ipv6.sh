#!/bin/bash

# MIT License
# 
# Copyright (c) 2021 Zeljko Stevanovic
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
 
# Create tunel: https://www.tunnelbroker.net/new_tunnel.php

# IPv6 Tunnel Endpoints
IPV6DEV=he-ipv6
# CHANGE: Client IPv4 Address:
IPV6MY=XXXXXXXXXXXXX
# CHANGE: Server IPv4 Address:
IPV4REMOTE=XXXXXXXXXXXX
# CHANGE: default gw na racunaru
IPV4DEV=XXXXXXXX

# CHANGE: Tunnel ID   << potrebno za update localne IP.
TUNNEL_ID=XXXXXXXXXX
# CHANGE
TUNNEL_USERNAME=XXXXXXXX
# CHANGE
TUNNEL_PASSWORD=XXXXXXXXXX

down() {
	if ip addr show dev ${IPV6DEV} > /dev/null 2>&1; then
		echo "down ${IPV6DEV}"
		ip route del ::/0 dev ${IPV6DEV}
		ip addr del ${IPV6MY} dev ${IPV6DEV}
		ip link set ${IPV6DEV} down
		ip tunnel del ${IPV6DEV}
	else
		echo "already down"
	fi
}

up() {
	if ip addr show dev ${IPV6DEV} > /dev/null 2>&1; then
		echo "already up"
	else
		echo "up he-ipv6"
		ip tunnel add ${IPV6DEV} mode sit remote ${IPV4REMOTE} local $LOCAL_IP ttl 255
		ip link set ${IPV6DEV} up
		ip addr add ${IPV6MY} dev ${IPV6DEV}
		ip route add ::/0 dev ${IPV6DEV}
	fi
}

update() {
	wget -O- -q "https://ipv4.tunnelbroker.net/nic/update?username=${TUNNEL_USERNAME}&password=${TUNNEL_PASSWORD}&hostname=${TUNNEL_ID}"

	if [ "$LOCAL_IP" != "$TUNEL_LOCAL_IP" ]; then
		if ip addr show dev ${IPV6DEV} > /dev/null 2>&1; then
			down
		fi

		up
	fi
}

if [ "$UID" != 0 ]; then
	echo "must be root"
	exit 2
fi

TUNEL_LOCAL_IP=$(ip addr show dev ${IPV6DEV} 2> /dev/null | grep link/sit | sed -e 's,.*link/sit ,,' -e 's/ peer.*$//')

LOCAL_IP=$(ip addr show dev ${IPV4DEV} | grep -w inet | sed -e 's/.*inet //' -e 's,/.*,,')

echo "TUNEL_LOCAL_IP: $TUNEL_LOCAL_IP"
echo "LOCAL_IP      : $LOCAL_IP"

case "$1" in
down)
	down
	;;
up)
	up
	;;
update)
	update
	;;
*)
	update
	;;
esac

