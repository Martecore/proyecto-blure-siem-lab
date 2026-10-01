#!/bin/bash
ALLOWED_PORTS="22,80,443,8000"

iptables -F TARPIT_CHAIN 2>/dev/null
iptables -X TARPIT_CHAIN 2>/dev/null

iptables -N TARPIT_CHAIN
iptables -A TARPIT_CHAIN -m limit --limit 5/min -j LOG --log-prefix "TARPIT_DETECTION: " --log-level 4
iptables -A TARPIT_CHAIN -j TARPIT 2>/dev/null || iptables -A TARPIT_CHAIN -j DROP

iptables -A INPUT -p tcp -m multiport ! --dports $ALLOWED_PORTS --syn -j TARPIT_CHAIN
echo "[+] Mecanismo Tarpit/Bloqueo activado correctamente para puertos no autorizados."
