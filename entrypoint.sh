#!/bin/sh

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
USER=me

# Get standard cali USER_ID variable
#USER_ID=${HOST_USER_ID:-9001}
#GROUP_ID=${HOST_GROUP_ID:-9001}
# Change 'me' uid to host user's uid
#if [ ! -z "$USER_ID" ] && [ "$(id -u me)" != "$USER_ID" ]; then
    # Create the user group if it does not exist
    #addgroup -g "$GROUP_ID" group
    # Set the user's uid and gid
    #adduser -u "$USER_ID" -G "$GROUP_ID" me
#fi

# Setting permissions on /home/me
# Setting permissions on docker.sock
#chown me: /var/run/docker.sock

if [ ! -z "$GIT_USER_NAME" ] && [ ! -z "$GIT_USER_EMAIL" ]; then
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
fi

chmod 777 /var/run/docker.sock
#if [ -S ${DOCKER_SOCKET} ]; then
#    DOCKER_GID=$(stat -c '%g' ${DOCKER_SOCKET})
#
#    addgroup --gid ${DOCKER_GID} ${DOCKER_GROUP}
#    usermod --append --groups ${DOCKER_GROUP} ${USER}
#fi

#/bin/zsh
#exec /sbin/su-exec me tmux -u -2 "$@"

chown -R me: /home/me/.config
#chown -R me: /var/run/docker.sock
chown -R me: /home/me/.kube
chown -R me: /home/me/.ssh
chown -R me: /home/me/zsh
chown -R me: /home/me/.tmux
chown -R me: /home/me/.stack /home/me/.stack-work
#home/me/.tmux/plugins/tpm/bin/install_plugins
exec /sbin/su-exec me /bin/zsh "$@"
#newgrp ${DOCKER_GROUP}
#newgrp $(id -gn)
