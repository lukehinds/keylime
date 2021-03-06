#!/bin/bash

# You can specify the path of the local keylime repository as argument
# of this script or using the KEYLIME_REPO_PATH environment variable.
# The default value is /home/${USER}/keylime
REPO=${KEYLIME_REPO_PATH:-${1:-/home/${USER}/keylime}}

# keylime images
tpm20image="lukehinds/keylime-ci-tpm20"
tpm20tag="v101"

echo -e "Grabbing latest images"

docker pull ${tpm20image}:${tpm20tag}

function tpm2 {
    container_id=$(mktemp)
    docker run --detach --privileged \
        -v $REPO:/root/keylime \
        -v /sys/fs/cgroup:/sys/fs/cgroup \
        --cgroupns=host \
        -it ${tpm20image}:${tpm20tag} >> ${container_id}
    docker exec -u 0 -it --tty "$(cat ${container_id})" \
        /bin/bash /root/keylime/.ci/test_wrapper.sh
    docker stop "$(cat ${container_id})"
    docker rm "$(cat ${container_id})"
}

while true; do
    echo -e ""
    read -p "Do you wish to test against TPM 2.0(a) or q(quit): " abq
    case $abq in
        [a]* ) tpm2;;
        [q]* ) exit;;
        * ) echo "Please answer a or q(quit)";;
    esac
done
