#!/bin/bash

set -ex
NATS_VERSION="${nats_version}" # latest as per December 2023
AWS_EIP_ID="${server_eip_id}"
region="${region}"

# unzip
sudo apt install unzip -y

# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# update default SSH ports
echo "Port 22666" >> /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
systemctl restart sshd
# associate EIP
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id $AWS_EIP_ID --allow-reassociation --region $region

adduser --system --no-create-home --group nats
apt-get update -y && apt-get install -y wget tar
wget https://github.com/nats-io/nats-server/releases/download/$NATS_VERSION/nats-server-$NATS_VERSION-linux-amd64.tar.gz

tar -xzf nats-server-$NATS_VERSION-linux-amd64.tar.gz
cd nats-server-$NATS_VERSION-linux-amd64

# Move the NATS server binary to a directory in the PATH
mv nats-server /usr/local/bin/

# Clean up downloaded and extracted files
cd ..
rm -rf nats-server-$NATS_VERSION-linux-amd64
rm nats-server-$NATS_VERSION-linux-amd64.tar.gz

# create systemd unit
cat <<EOF | sudo tee /etc/systemd/system/nats.service
[Unit]
Description=NATS Server
After=network-online.target

[Service]
PrivateTmp=true
Type=simple
ExecStart=/usr/local/bin/nats-server -c /etc/nats-server.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s SIGINT $MAINPID
User=nats
Group=nats
# The nats-server uses SIGUSR2 to trigger using Lame Duck Mode (LDM) shutdown
KillSignal=SIGUSR2
# You might want to adjust TimeoutStopSec too.

[Install]
WantedBy=multi-user.target
EOF
chown nats:nats /etc/systemd/system/nats.service

# create sample config
cat <<EOF | sudo tee /etc/nats-server.conf
listen: 0.0.0.0:4222  # Listen on all interfaces on the default NATS port
monitor_port: 8222
# Logging
log_file: "/var/log/nats.log"  # Path to the NATS log file
logtime: true  # Timestamp log entries
debug: true  # Enable detailed debug logging
trace: true  # Trace the processing of each protocol message
EOF
chown nats:nats /etc/nats-server.conf
touch /var/log/nats.log
chown nats:nats /var/log/nats.log

systemctl daemon-reload
systemctl start nats.service
