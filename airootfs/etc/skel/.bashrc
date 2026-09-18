# ~/.bashrc: Executed by bash for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Shell Options
shopt -s checkwinsize
shopt -s histappend

# History Settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

# Color definitions
GREEN='\[\033[38;2;0;216;180m\]'
CYAN='\[\033[38;2;0;187;249m\]'
WHITE='\[\033[0;37m\]'
RESET='\[\033[0m\]'

# Modern Prompt
PS1="${GREEN}\u${WHITE}@${CYAN}\h ${WHITE}\w ${GREEN}❯${RESET} "

# Useful Aliases
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Auto-run Fastfetch on interactive shell launch
if command -v fastfetch &>/dev/null; then
    fastfetch
fi
