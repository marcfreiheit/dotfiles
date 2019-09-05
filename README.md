# dotfiles

My dotfiles for vim, tmux and zsh. Including plugins

## Pre-Reqs

You must have installed:

- python (brew install python3)
- cmake (brew install cmake)
- typescript
- [powerline fonts](https://github.com/powerline/fonts)

Notice: I'm running `make`, `typescript` and `python` in Docker containers. Therefore, you don't have to install the prereqs if you run the `apply.sh` script in beforehand. 

## Installation

Run the following commands to install this vim setup:

```
pushd ~/github
git clone --recurse-submodules -j8 git@github.com:marcfreiheit/dotfiles.git
popd && pushd ~/github/dotfiles
./apply.sh
pushd vim/bundle/YouCompleteMe
python install.py
popd
# Install dependency of tsuquyomi
pushd vim/bundle/vimproc.vim
make
popd
```

