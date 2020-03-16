#!/bin/sh

DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
USER=marcfreiheit

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

chown -R marcfreiheit: /home/marcfreiheit/.config
#chown -R marcfreiheit: /var/run/docker.sock
chown -R marcfreiheit: /home/marcfreiheit/.kube
chown -R marcfreiheit: /home/marcfreiheit/.ssh
chown -R marcfreiheit: /home/marcfreiheit/zsh
chown -R marcfreiheit: /home/marcfreiheit/.tmux
#chown -R marcfreiheit: /home/marcfreiheit/.stack /home/me/.stack-work
exec /sbin/su-exec marcfreiheit /bin/zsh "$@"
#newgrp ${DOCKER_GROUP}
#newgrp $(id -gn)
