# Required for Ionic development
export ANDROID_HOME=/Users/marcfreiheit/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# For additonal programs and scripts
export PATH=$PATH:/usr/local/bin

# Choose rbenv from brew, instead of built-in
#eval "$(rbenv init -)"

export EDITOR='vim'
export VISUAL='vim'

CONFIG_LOCATION=~/github/dotfiles
source ${CONFIG_LOCATION}/zsh/antigen.zsh
antigen use oh-my-zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# Functions
  # list content of directory after cd
  c() {
    cd $1;
    ls -Alm;
  }
  alias cd="c"

source ${CONFIG_LOCATION}/zsh/keybindings.sh  
source ${CONFIG_LOCATION}/zsh/prompt.sh


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/marcfreiheit/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/marcfreiheit/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/marcfreiheit/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/marcfreiheit/google-cloud-sdk/completion.zsh.inc'; fi
