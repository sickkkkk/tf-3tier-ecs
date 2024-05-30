#!/bin/bash
 
set -x

DEPLOY_ENVIRONMENT="${server_environment}"

case $DEPLOY_ENVIRONMENT in
    develop)
        ENV_PREFIX="dev"
        ;;
    prod)
        ENV_PREFIX="prod"
        ;;
    test)
        ENV_PREFIX="test"
        ;;
    *)
        echo "Unknown environment"
        exit 1
        ;;
esac

apt update -y
apt install -y awscli jq unzip gnupg software-properties-common
snap install amazon-ssm-agent --classic && snap start amazon-ssm-agent && snap services amazon-ssm-agent

# terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y && apt install terraform -y
# Docker
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable"
apt-get update -y
apt install docker-ce -y

# Docker compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Gitlab runner
# Download the binary for your system
curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
gitlab-runner start

usermod -aG docker gitlab-runner

# Get gilab token
URL="git.decartel.co"
SECRET_NAME="dev/gitlab/delivery/apitoken"
AWS_DEFAULT_REGION="${region}"
SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --region $AWS_DEFAULT_REGION --query 'SecretString' --output text)

# Create shared runner
if [ $? -eq 0 ]; then
    echo "[debug] Secret value: $SECRET_VALUE"
    registration_output=$(gitlab-runner register \
        --non-interactive \
        --url "https://$URL/" \
        --registration-token "$SECRET_VALUE" \
        --executor "shell" \
        --description "delivery_$ENV_PREFIX" \
        --tag-list "delivery_$ENV_PREFIX" 2>&1 )
    if echo "$registration_output" | grep -q "Runner registered successfully"; then
        echo "Runner successfully registered"
        
        systemctl restart gitlab-runner.service
    else
        echo "Failed to register runner"
    fi
else
    echo "Failed to retrieve secret value from AWS Secrets Manager"
fi

# Comment all lines in the file .bash_logout
file="/home/gitlab-runner/.bash_logout"
sed -i 's/^/#/' "$file"

# Add gitlab_host to known_hosts
mkdir /home/gitlab-runner/.ssh
touch /home/gitlab-runner/.ssh/known_hosts
ssh-keyscan -t rsa "$URL" >> /home/gitlab-runner/.ssh/known_hosts
chown gitlab-runner:gitlab-runner /home/gitlab-runner/.ssh


