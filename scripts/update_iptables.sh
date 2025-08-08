#!/bin/bash
# Create or flush the ipset for GitHub Actions IPs
ipset create gha-ips hash:net -exist
ipset flush gha-ips

# Add each IP/CIDR to the ipset
for ip in "$@"; do
  ipset add gha-ips "$ip"
done

# Ensure iptables rule exists to allow SSH from the ipset
iptables -D INPUT -p tcp --dport 22 -m set --match-set gha-ips src -j ACCEPT 2>/dev/null # remove rule (if it exists) that lets any IP from the gha-ips set access SSH.
iptables -I INPUT -p tcp --dport 22 -m set --match-set gha-ips src -j ACCEPT # add rule to allow SSH from IPs in the gha-ips set

# Save ipset and iptables rules
ipset save gha-ips > /etc/sysconfig/ipset
service iptables save
