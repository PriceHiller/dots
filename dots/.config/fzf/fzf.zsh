# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/pricehiller/.local/share/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/pricehiller/.local/share/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/pricehiller/.local/share/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/pricehiller/.local/share/fzf/shell/key-bindings.zsh"
