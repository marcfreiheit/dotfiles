# dotfiles

My dotfiles for vim, tmux and zsh. Including plugins

## Pre-Reqs

You must have installed:

- python (brew install python3)
- cmake (brew install cmake)
- typescript
- [powerline fonts](https://github.com/powerline/fonts)

## Installation

Run the following commands to install this vim setup:

```
pushd ~/github
git clone --recurse-submodules -j8 git@github.com:marcfreiheit/dotfiles.git
pushd dotfiles/vim/bundle/YouCompleteMe
python install.py
popd
# Install dependency of tsuquyomi
pushd dotfiles/vim/bundle/vimproc.vim
make
popd
./apply.sh
popd
```

