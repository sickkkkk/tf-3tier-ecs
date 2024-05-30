#!/bin/bash
# TBD - make it templated similar to TaskDef JSON
set -x
export MESSAGE="${message}"
# 1) Start SSM-Agent
snap install amazon-ssm-agent --classic && sudo snap start amazon-ssm-agent && snap services amazon-ssm-agent
# 2) unzip
sudo apt install unzip -y
# 3) jq
sudo apt install jq -y
# 4) aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# 5) bleh
echo $MESSAGE