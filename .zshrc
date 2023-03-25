# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval $(/opt/homebrew/bin/brew shellenv)
source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

# Correctly save history in zsh https://unix.stackexchange.com/a/575102
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=500000
setopt histignorespace
setopt appendhistory
setopt SHARE_HISTORY # Share history between all sessions
setopt INC_APPEND_HISTORY # Write to file immediately, not when shell exits

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source my personal aliases
source $HOME/.aliases

# Pass bad matches onto commands
# e.g. git show head^ now actually works without escaping
unsetopt nomatch

# docker and idea are installed here
export PATH=/usr/local/bin:$PATH

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  #what about /opt/homebrew/share/zsh/site-functions

  setopt COMPLETE_IN_WORD  # Complete from both ends of a word.
  setopt ALWAYS_TO_END     # Move cursor to the end of a completed word.
  setopt AUTO_MENU         # Show completion menu on a successive tab press.
  setopt AUTO_LIST         # Automatically list choices on ambiguous completion.
  setopt AUTO_PARAM_SLASH  # If completed parameter is a directory, add a trailing slash.
  setopt EXTENDED_GLOB     # Needed for file modification glob modifiers with compinit
  unsetopt MENU_COMPLETE   # Do not autoselect the first completion entry.
  unsetopt FLOW_CONTROL    # Disable start/stop characters in shell editor.
  unsetopt completealiases # https://unix.stackexchange.com/a/250489

  autoload -Uz compinit
  compinit
fi
