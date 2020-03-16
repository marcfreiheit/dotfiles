# For additonal programs and scripts
if [[ -z $TMUX ]]; then
  export PATH=$PATH:/usr/local/bin
 
  # For programs installed using Ruby Gems
  if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
  fi
fi

# Editor configuration
export EDITOR='vim'
export VISUAL='vim'

CONFIG_LOCATION=~

# Antigen plugins
source ${CONFIG_LOCATION}/zsh/antigen.zsh
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# Functions
# list content of directory after cd
c() {
  cd $1;
  ls -A;
}
alias cd="c"
hgrep() {
  history | grep $1;
}

# Additional files
source ${CONFIG_LOCATION}/zsh/keybindings.sh  
source ${CONFIG_LOCATION}/zsh/prompt.sh
source ${CONFIG_LOCATION}/zsh/zsh-highlighting.sh
export GIT_PROMPT_EXECUTABLE="haskell"
#source ${CONFIG_LOCATION}/zsh/apps.sh

# Stuff which should not have been comitted
export HOMEBREW_GITHUB_API_TOKEN=2f94bb55e7e1745a73a9c6a3cd5aff0a00b2412d
