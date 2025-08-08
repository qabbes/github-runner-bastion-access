#!/bin/bash

# Update system packages
yum update -y

# Install required packages
yum install -y amazon-ssm-agent iptables-services

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

# Enable iptables service to persist rules
systemctl enable iptables
systemctl start iptables

# Allow established connections and localhost (basic security)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Save iptables rules
service iptables save

echo "Bastion host setup completed successfully" >> /var/log/user-data.log
