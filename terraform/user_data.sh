#!/bin/bash

# Update system packages
yum update -y

# Install required packages
yum install -y amazon-ssm-agent iptables-services ipset

# Enable and start SSM agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Create directory for scripts
mkdir -p ${script_directory}

# Create the update_iptables.sh script
cat > ${script_directory}/${script_name} << 'EOF'
${update_iptables_script}
EOF

# Make the script executable
chmod +x ${script_directory}/${script_name}

# Enable iptables and ipset services to persist rules
systemctl enable iptables
systemctl start iptables
systemctl enable ipset
systemctl start ipset

# Create initial empty ipset for GitHub Actions IPs
ipset create gha-ips hash:net -exist

# Allow established connections and localhost (basic security)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Save iptables and ipset rules
service iptables save
ipset save gha-ips > /etc/sysconfig/ipset

echo "Bastion host setup completed successfully" >> /var/log/user-data.log
