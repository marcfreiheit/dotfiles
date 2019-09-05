# For additonal programs and scripts
export PATH=$PATH:/usr/local/bin

export EDITOR='vim'
export VISUAL='vim'

CONFIG_LOCATION=~

source ${CONFIG_LOCATION}/zsh/antigen.zsh
#antigen use oh-my-zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# Functions
# list content of directory after cd
c() {
  cd $1;
  ls -A;
}
alias cd="c"

source ${CONFIG_LOCATION}/zsh/keybindings.sh  
source ${CONFIG_LOCATION}/zsh/prompt.sh
#source ${CONFIG_LOCATION}/zsh/zsh-highlighting.sh
#source ${CONFIG_LOCATION}/zsh/apps.sh

export HOMEBREW_GITHUB_API_TOKEN=2f94bb55e7e1745a73a9c6a3cd5aff0a00b2412d
export GIT_PROMPT_EXECUTABLE="haskell"
