#!/bin/bash
iptables -F GHA-SSH 2>/dev/null || iptables -N GHA-SSH # Flush or create GHA-SSH chain
iptables -D INPUT -p tcp --dport 22 -j GHA-SSH 2>/dev/null # Remove existing jump if present
iptables -A INPUT -p tcp --dport 22 -j GHA-SSH # Add jump to GHA-SSH

for ip in "$@"; do
  iptables -A GHA-SSH -p tcp -s "$ip" --dport 22 -j ACCEPT
done