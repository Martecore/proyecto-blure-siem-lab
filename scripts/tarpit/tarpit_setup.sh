#!/bin/bash
# Puertos autorizados (SSH, HTTP, HTTPS, Syslog, Splunk Web)
ALLOWED_PORTS="22,80,443,514,8000"

# Crear cadena personalizada para el Tarpit
iptables -N TARPIT_CHAIN 2>/dev/null || iptables -F TARPIT_CHAIN

# Registrar la IP atacante en Syslog antes de aplicar el retardo
iptables -A TARPIT_CHAIN -m limit --limit 5/min -j LOG --log-prefix "TARPIT_DETECTION: " --log-level 4

# Aplicar el mecanismo TARPIT (o descarte si el modulo no esta en kernel)
iptables -A TARPIT_CHAIN -j TARPIT 2>/dev/null || iptables -A TARPIT_CHAIN -j DROP

# Redirigir intentos de conexion TCP entrantes en puertos no autorizados al Tarpit
iptables -A INPUT -p tcp -m multiport ! --dports $ALLOWED_PORTS --syn -j TARPIT_CHAIN

echo "[+] Mecanismo Tarpit/Bloqueo activado correctamente para puertos no autorizados."
