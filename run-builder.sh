#!/bin/bash -xe

# Always delete instance after attempting build
function cleanup {
    ${GCLOUD} compute instances delete ${INSTANCE_NAME} --quiet
}

# Configurable parameters
[ -z "$COMMAND" ] && echo "Need to set COMMAND" && exit 1;

USERNAME=${USERNAME:-ailteds01}
REMOTE_WORKSPACE=${REMOTE_WORKSPACE:-/home/${USERNAME}/workspace/}
INSTANCE_NAME=${INSTANCE_NAME:-instance-$(cat /dev/urandom | tr '1-9' | fold -w 8 | head -n 1)}
ZONE=${ZONE:-us-east1-b}
INSTANCE_ARGS=${INSTANCE_ARGS:-PREMIUM}
SUBNET=${SUBNET:-rede-gce}
GCLOUD=${GCLOUD:-gcloud}
BOOT=${REBOOT:-sudo reboot}

${GCLOUD} config set compute/zone ${ZONE}

KEYNAME=builder-key
# TODO Need to be able to detect whether a ssh key was already created
ssh-keygen -t rsa -N "" -f ${KEYNAME} -C ${USERNAME} || true
chmod 400 ${KEYNAME}*

cat > ssh-keys <<EOF
${USERNAME}:$(cat ${KEYNAME}.pub)
EOF

${GCLOUD} compute instances create \
       --zone=${ZONE} --subnet=${SUBNET} --network-tier=${INSTANCE_ARGS} ${INSTANCE_NAME} \
       --metadata block-project-ssh-keys=TRUE \
       --metadata-from-file ssh-keys=ssh-keys \
       ${INSTANCE_NAME}

trap cleanup EXIT


