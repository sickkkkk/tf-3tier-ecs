#!/bin/bash
# initial setup script to setup system service, pull latest version of server artifact and run it
# each environment contains DynamoDB table to track server versions
# dev: dev-server-release (us-east-1)
set -x
BUILD_VERSION="${ue_server_build_version}"
SERVICE_USERNAME="${service_user_name}"
DEPLOY_ENVIRONMENT="${server_environment}"
AWS_EIP_ID="${server_eip_id}"
# we both know it's dirty but due to a inconsistency of naming we need to do it
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

S3_RESOURCE_BUCKET="s3://metacity-server-scripts/$ENV_PREFIX"
S3_SERVER_ARTIFACT_BUCKET="s3://metacity-$ENV_PREFIX-builds/release/linux-server"
TABLE_NAME="$ENV_PREFIX-server-release"
region="${region}"

# update default SSH ports
echo "Port 22666" >> /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
systemctl restart sshd
# associate EIP
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id $AWS_EIP_ID --allow-reassociation --region $region

# create user if not exists
if [[ -d "/home/$SERVICE_USERNAME" ]]; then
    echo "User $SERVICE_USERNAME already exists"
else
    useradd -m -s /bin/bash "$SERVICE_USERNAME"
fi
echo "[debug] Latest Version in $ENV_PREFIX environment: $BUILD_VERSION"
# pull artifact
aws s3 cp "$S3_SERVER_ARTIFACT_BUCKET/metacity.$BUILD_VERSION.zip" /tmp
if [[ -d "/home/$SERVICE_USERNAME/LinuxServer" ]]; then
    rm -r "/home/$SERVICE_USERNAME/LinuxServer/*"
else
    cd /home/$SERVICE_USERNAME
    mkdir LinuxServer
fi
unzip -o /tmp/metacity.$BUILD_VERSION.zip -d /home/$SERVICE_USERNAME/LinuxServer/
# copy unit file and scripts
aws s3 cp $S3_RESOURCE_BUCKET/setup_chat.sh /home/$SERVICE_USERNAME/setup_chat.sh
aws s3 cp $S3_RESOURCE_BUCKET/status_chat.sh /home/$SERVICE_USERNAME/status_chat.sh
aws s3 cp $S3_RESOURCE_BUCKET/metacity_chat_server.service /etc/systemd/system/
chown $SERVICE_USERNAME:$SERVICE_USERNAME /etc/systemd/system/metacity_chat_server.service
chown -R $SERVICE_USERNAME:$SERVICE_USERNAME /home/$SERVICE_USERNAME
chmod +x /home/$SERVICE_USERNAME/setup_chat.sh
chmod +x /home/$SERVICE_USERNAME/status_chat.sh
# start backend server systemd unit
systemctl daemon-reload
systemctl enable metacity_chat_server.service
systemctl start metacity_chat_server.service
# check service and update status table
bash -c "/home/$SERVICE_USERNAME/status_chat.sh $latest_version $table_name"