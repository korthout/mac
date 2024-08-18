# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Correctly save history in zsh https://unix.stackexchange.com/a/575102
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
setopt histignorespace
setopt appendhistory
setopt SHARE_HISTORY # Share history between all sessions
setopt INC_APPEND_HISTORY # Write to file immediately, not when shell exits

# docker and idea are installed here
export PATH=/usr/local/bin:$PATH

# personal binaries
export PATH=$HOME/bin:$PATH

# Created by `pipx` on 2024-08-06 11:25:58
export PATH="$PATH:/Users/korthout/.local/bin"

# Source my personal aliases
source $HOME/.aliases

# Pass bad matches onto commands
# e.g. git show head^ now actually works without escaping
unsetopt nomatch

# Add GH SSH key to ssh agent
ssh-add -K ~/.ssh/id_ed25519 2>/dev/null
ssh-add -K ~/.ssh/id_rsa 2>/dev/null

eval $(/opt/homebrew/bin/brew shellenv)
if type brew &>/dev/null; then

  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  #what about /opt/homebrew/share/zsh/site-functions

  export HOMEBREW_NO_INSTALL_CLEANUP=true

  setopt COMPLETE_IN_WORD  # Complete from both ends of a word.
  setopt ALWAYS_TO_END     # Move cursor to the end of a completed word.
  setopt AUTO_MENU         # Show completion menu on a successive tab press.
  setopt AUTO_LIST         # Automatically list choices on ambiguous completion.
  setopt AUTO_PARAM_SLASH  # If completed parameter is a directory, add a trailing slash.
  setopt EXTENDED_GLOB     # Needed for file modification glob modifiers with compinit
  unsetopt MENU_COMPLETE   # Do not autoselect the first completion entry.
  unsetopt FLOW_CONTROL    # Disable start/stop characters in shell editor.
  unsetopt completealiases # https://unix.stackexchange.com/a/250489

  zstyle ':completion:*' special-dirs true
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

  autoload -Uz compinit
  compinit
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/korthout/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/korthout/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/korthout/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/korthout/google-cloud-sdk/completion.zsh.inc'; fi
