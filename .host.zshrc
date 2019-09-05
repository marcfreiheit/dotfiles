# Function
abcd() {
  echo "abcd"
}
dide() {
  name="ide-$(basename "$PWD")"
  container_name=$(docker ps -a -f "name=$name" --format '{{ .Names }}')
  if [ "$container_name" = $name ]; then
    docker start "$name"
    docker attach "$name"
  else
    docker run \
      -it \
      -e HOST_USER_ID=$(id -u $USER) \
      -e HOST_GROUP_ID=$(id -g $USER) \
      -e GIT_USER_NAME="Marc André Freiheit" \
      -e GIT_USER_EMAIL="marcandre@freiheit.software" \
      -v ~/github:/home/me/workspace \
      -v ~/.kube:/home/me/.kube \
      -v ~/.config/gcloud:/home/me/.config/gcloud \
      -v ~/.ssh:/home/me/.ssh \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v ~/.zsh_history:/home/me/.zsh_history \
      --name ide-$(basename "$PWD") \
      marcfreiheit/dotfiles:latest  
  fi
}

# vim: set ft=zsh:
