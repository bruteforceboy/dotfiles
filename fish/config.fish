if status is-interactive
    # Commands to run in interactive sessions can go here
end


# pyenv init
if command -v pyenv 1>/dev/null 2>&1
  pyenv init - | source
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/wilson/.ghcup/bin $PATH # ghcup-env

# opam configuration
source /home/wilson/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
export PATH="$PATH:$HOME/flutter/bin"
