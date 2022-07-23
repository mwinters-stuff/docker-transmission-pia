#!/bin/sh

echo "patching manual-connections"
FILENAME="manual-connections/connect_to_wireguard_with_token.sh"
MATCH='\[Interface\]'
ADD1='PostUp = DROUTE=\\\$(ip route | grep default | cut -d \\\" \\\" -f 3); KUBENET2=10.43.0.0/16; KUBENET1=10.42.0.0/16; ip route add \\\$KUBENET2 via \\\$DROUTE; iptables -I OUTPUT -d \\\$KUBENET1 -j ACCEPT; iptables -A OUTPUT -d \\\$KUBENET2 -j ACCEPT; iptables -A OUTPUT ! -o pia -m mark ! --mark \\\$(wg show pia fwmark) -m addrtype ! --dst-type LOCAL -j REJECT'
ADD2='PreDown = KUBENET2=10.43.0.0/16; KUBENET1=10.42.0.0/16; ip route del \\\$KUBENET2 via \\\$DROUTE; iptables -D OUTPUT ! -o %i -m mark ! --mark \\\$(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; iptables -D OUTPUT -d \\\$KUBENET1 -j ACCEPT; iptables -D OUTPUT -d \\\$KUBENET2 -j ACCEPT'

sed -i "/^${MATCH}/a ${ADD1}" ${FILENAME}
sed -i "/^${MATCH}/a ${ADD2}" ${FILENAME}