#!/bin/sh

echo "patching manual-connections"
FILENAME="manual-connections/connect_to_wireguard_with_token.sh"
MATCH='\[Interface\]'
ADD1='PostUp = DROUTE=\\\$(ip route | grep default | cut -d \\\" \\\" -f 3); HOMENET=192.168.0.0/16; HOMENET2=172.16.0.0/12; ip route add \\\$HOMENET2 via \\\$DROUTE; ip route add \\\$HOMENET via \\\$DROUTE; iptables -I OUTPUT -d \\\$HOMENET -j ACCEPT; iptables -A OUTPUT -d \\\$HOMENET2 -j ACCEPT; iptables -A OUTPUT ! -o pia -m mark ! --mark \\\$(wg show pia fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'
ADD2='PreDown = HOMENET=192.168.0.0/16; HOMENET2=172.16.0.0/12; ip route del \\\$HOMENET3 via $DROUTE;ip route del \\\$HOMENET2 via \\\$DROUTE; ip route del \\\$HOMENET via \\\$DROUTE; iptables -D OUTPUT ! -o %i -m mark ! --mark \\\$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; iptables -D OUTPUT -d \\\$HOMENET -j ACCEPT; iptables -D OUTPUT -d \\\$HOMENET2 -j ACCEPT'

sed -i "/^${MATCH}/a ${ADD1}" ${FILENAME}
sed -i "/^${MATCH}/a ${ADD2}" ${FILENAME}