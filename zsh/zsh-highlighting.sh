ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
typeset -A ZSH_HIGHLIGHT_PATTERNS

# To have commands starting with `rm -rf` in red:
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')

# To have globbing patterns compatible with my dark-blue background
ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow,bold'
