# Required for Ionic development
export ANDROID_HOME=/Users/marcfreiheit/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Choose rbenv from brew, instead of built-in
eval "$(rbenv init -)"

export EDITOR='vim'
export VISUAL='vim'

#CONFIG_LOCATION=$(readlink "$0")
CONFIG_LOCATION=~/github/dotfiles
source ${CONFIG_LOCATION}/zsh/antigen.zsh
antigen use oh-my-zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# Functions
  # list content of directory after cd
  c() {
    cd $1;
    ls -Am;
  }
  alias cd="c"

source ${CONFIG_LOCATION}/zsh/keybindings.sh  
source ${CONFIG_LOCATION}/zsh/prompt.sh

