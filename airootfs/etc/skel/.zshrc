# ~/.zshrc: Executed by zsh for non-login shells.

# Prompt
PROMPT='%F{#00d8b4}%n%f@%F{#00bbf9}%m%f %F{#e0e5ed}%~%f %F{#00d8b4}❯%f '

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias grep='grep --color=auto'

# Syntax highlighting & autosuggestions if installed
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Auto-run Fastfetch on interactive launch
if [[ -o interactive ]] && command -v fastfetch &>/dev/null; then
    fastfetch
fi
