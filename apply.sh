#!/bin/sh

# zsh configuration file
ln -sf `pwd`/zsh/.zshrc ~/.zshrc

# tmux configuration including plugins
ln -sf `pwd`/tmux/.tmux.conf ~/.tmux.conf
ln -sf `pwd`/tmux ~/.tmux

# Vim configuration file including plugins
ln -sf `pwd`/vim/.vimrc ~/.vimrc
ln -sf `pwd`/vim ~/.vim

# Custom scripts
# Mostly small programs run inside a Docker container
ln -sf `pwd`/zsh/scripts/* /usr/local/bin

