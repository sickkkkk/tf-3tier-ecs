#!/bin/bash
# TBD - make it templated similar to TaskDef JSON
set -x
export AUTH_DB_ID="${auth_db_id}"
export AWS_REGION="${region}"
export SECRET_PATH="${secret_path}"
# 1) psql cli
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update -y
sudo apt install postgresql-client-15 -y
psql --version
# 2) unzip
sudo apt install unzip -y
# 3) jq
sudo apt install jq -y
# 4) aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip > /dev/null 2>&1
sudo ./aws/install > /dev/null 2>&1
# 6) install UUID extension for auth_service database
region=$AWS_REGION
default_port="5432"
db_id=$AUTH_DB_ID
secret=$SECRET_PATH
db_name="auth_db"
db_endpoint=$(aws rds describe-db-instances --db-instance-identifier $db_id --query 'DBInstances[*].Endpoint.Address' --output text)
db_user=$(aws secretsmanager get-secret-value --region $region --secret-id $secret --query SecretString --output text | jq -r '.POSTGRES_USER')
db_password=$(aws secretsmanager get-secret-value --region $region --secret-id $secret --query SecretString --output text | jq -r '.POSTGRES_PASSWORD')
PGPASSWORD=$db_password psql -h $db_endpoint -p $default_port -U $db_user -d $db_name -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
# 7) install UUID extension for db_interface database
#region="us-east-1"
#default_port="5432"
#db_id=$GDB_DB_ID
#secret="dev/backend/gdb_interface/db_credentials"
#db_name="user_db_game_dev"

#db_endpoint=$(aws rds describe-db-instances --db-instance-identifier $db_id --query 'DBInstances[*].Endpoint.Address' --output text)
#db_user=$(aws secretsmanager get-secret-value --region $region --secret-id $secret --query SecretString --output text | jq -r '.POSTGRES_USER')
#db_password=$(aws secretsmanager get-secret-value --region $region --secret-id $secret --query SecretString --output text | jq -r '.POSTGRES_PASSWORD')
#PGPASSWORD=$db_password psql -h $db_endpoint -p $default_port -U $db_user -d $db_name -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
# 8) Change default SSH Port
echo "Port 22666" >> /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
systemctl restart sshd
# 9) Start SSM-Agent
snap install amazon-ssm-agent --classic && snap start amazon-ssm-agent && snap services amazon-ssm-agent