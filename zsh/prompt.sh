# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

autoload -U colors && colors

setopt PROMPT_SUBST

export __GIT_PROMPT_DIR=~/zsh/git-prompt
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd chpwd_update_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*|hub*|gh*|stg*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ ! -n "$ZSH_THEME_GIT_PROMPT_CACHE" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    if [[ "$GIT_PROMPT_EXECUTABLE" == "python" ]]; then
        local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
        _GIT_STATUS=`python ${gitstatus} 2>/dev/null`
    fi
    if [[ "$GIT_PROMPT_EXECUTABLE" == "haskell" ]]; then
        _GIT_STATUS=`git status --porcelain --branch &> /dev/null | $__GIT_PROMPT_DIR/src/.bin/gitstatus`
    fi
     __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
	GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
	GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
	GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
	GIT_STAGED=$__CURRENT_GIT_STATUS[4]
	GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
	GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
	GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}

set_prompt() {

	# [
	PS1="%{$fg[white]%}[%{$reset_color%}"

  # add hostname if working on a remote server
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    PS1+="%{$fg_bold[red]%}$HOST%{$reset_color%}"
    PS1+=' | '
  fi

	# Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
	PS1+="%{$fg_bold[cyan]%}%(4~|.../%3~|${PWD/#$HOME/~})%{$reset_color%}"

	# Status Code
	PS1+="%(?.., %{$fg[red]%}%?%{$reset_color%})"

	# Git
	if git rev-parse --is-inside-work-tree 2> /dev/null | grep -q 'true' ; then
		PS1+=', '
		PS1+="%{$fg_bold[magenta]%}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
		if [ $(git status --short | wc -l) -gt 0 ]; then 
			PS1+="%{$fg[yellow]%}+$(git status --short | wc -l | awk '{$1=$1};1')%{$reset_color%}"
		fi
	  if [ "$GIT_BEHIND" -ne "0" ]; then
		  PS1+="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$GIT_BEHIND%{${reset_color}%}"
	  fi
	  if [ "$GIT_AHEAD" -ne "0" ]; then
		  PS1+="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$GIT_AHEAD%{${reset_color}%}"
	  fi
	fi


	# PID
	if [[ $! -ne 0 ]]; then
		PS1+=', '
		PS1+="%{$fg_bold[yellow]%}PID:$!%{$reset_color%}"
	fi

	# Sudo: https://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
	CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
	if [ ${CAN_I_RUN_SUDO} -gt 0 ]
	then
		PS1+=', '
		PS1+="%{$fg_bold[red]%}SUDO%{$reset_color%}"
	fi

	PS1+="%{$fg[white]%}]: %{$reset_color%}% "
}

precmd_functions+=set_prompt

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[green]%}%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[green]%}%{↑%G%}"
