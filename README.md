# dotfiles

My dotfiles for vim, tmux and zsh. Including plugins

## Running

My setup is running in Docker and was built using [moby/buildkit](https://github.com/moby/buildkit). 

### Minimal

```
docker run --rm -it marcfreiheit/dotfiles:latest
```

### Complete

```
docker run \
  -it \
  -e HOST_USER_ID=$(id -u $USER) \
  -e HOST_GROUP_ID=$(id -g $USER) \
  -e GIT_USER_NAME="Marc Andrè Freiheit" \
  -e GIT_USER_EMAIL="marcandre@freiheit.software" \
  -v ~/github:/home/marcfreiheit/workspace \
  -v ~/.kube:/home/marcfreiheit/.kube \
  -v ~/.config/gcloud:/home/marcfreiheit/.config/gcloud \
  -v ~/.ssh:/home/marcfreiheit/.ssh \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.zsh_history:/home/marcfreiheit/.zsh_history \
  marcfreiheit/dotfiles:latest
