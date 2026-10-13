if status is-interactive
    # Commands to run in interactive sessions can go here
    # Install Fisher if not installed
    if not functions -q fisher
        curl -sL https://git.io/fisher | source
        fisher install jorgebucaran/fisher
    end

end

# Detect Termux
set -l IS_TERMUX 0
if test -n "$TERMUX_VERSION"; or test -d /data/data/com.termux
    set IS_TERMUX 1
end

if test $IS_TERMUX -eq 1
    # Termux - use PREFIX for binaries
    fish_add_path -g $PREFIX/bin $HOME/.local/bin $HOME/.cargo/bin
else if test (uname) = Darwin
    # macOS - check for Apple Silicon vs Intel
    if test -f /opt/homebrew/bin/brew
        # Apple Silicon (M1/M2/M3)
        set BREW_BIN /opt/homebrew/bin/brew
    else if test -f /usr/local/bin/brew
        # Intel Mac
        set BREW_BIN /usr/local/bin/brew
    end
    fish_add_path -g $HOME/.local/bin $HOME/.opencode/bin $HOME/.volta/bin $HOME/.bun/bin $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin /usr/local/bin $HOME/.config $HOME/.cargo/bin /usr/local/lib/*
else
    # Linux
    set BREW_BIN /home/linuxbrew/.linuxbrew/bin/brew
    fish_add_path -g $HOME/.local/bin $HOME/.opencode/bin $HOME/.volta/bin $HOME/.bun/bin $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin /usr/local/bin $HOME/.config $HOME/.cargo/bin /usr/local/lib/*
end

# Only eval brew shellenv if brew is installed (not on Termux)
if test $IS_TERMUX -eq 0; and set -q BREW_BIN; and test -f $BREW_BIN
    eval ($BREW_BIN shellenv)
end

# Start tmux/zellij (tmux first, zellij as fallback)
# if not set -q TMUX
#     if type -q tmux
#         tmux new-session -A -s main
#     else if type -q zellij
#         zellij attach -c main
#     end
# end

# Initialize tools (no starship, no Gentleman keybindings)
set -gx FZF_DISABLE_KEYBINDINGS 1
zoxide init fish | source
atuin init fish --disable-up-arrow --disable-ctrl-r | source
fzf --fish | source
# Only Ctrl+R → fzf history (the one shortcut actually used; the rest disabled)
bind -M insert \cr fzf-history-widget
bind -e -M insert \ct
bind -e -M insert \ec
bind -e -M insert shift-tab

# Carapace completions
set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'

if not test -d ~/.config/fish/completions
    mkdir -p ~/.config/fish/completions
end

if not test -f ~/.config/fish/completions/.initialized
    if not test -d ~/.config/fish/completions
        mkdir -p ~/.config/fish/completions
    end
    carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish
    touch ~/.config/fish/completions/.initialized
end

carapace _carapace | source

set -g fish_greeting ""

# Set nvim as default editor for opencode and other tools
set -gx EDITOR nvim
set -gx VISUAL nvim

## aliases / abbreviations (abbr expands on space — less typing)
if test (uname) = Darwin
    alias ls='ls --color=auto'
else
    alias ls='gls --color=auto -h --group-directories-first'
end

alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim (fzf --preview="bat --theme=gruvbox-dark --color=always {}")'

abbr -a g git
abbr -a gs -- 'git status'
abbr -a gd -- 'git diff'
abbr -a gl -- 'git log --oneline -20'
abbr -a dps -- 'docker ps'
abbr -a ser5 -- 'ssh ser5'
abbr -a mf -- 'ssh minisforum'
abbr -a qb -- 'cd ~/Proyects/Quebracho'
abbr -a .. -- 'cd ..'
abbr -a ... -- 'cd ../..'

set -l foreground F3F6F9 normal
set -l selection 263356 normal
set -l comment 8394A3 brblack
set -l red CB7C94 red
set -l orange DEBA87 orange
set -l yellow FFE066 yellow
set -l green B7CC85 green
set -l purple A3B5D6 purple
set -l cyan 7AA89F cyan
set -l pink FF8DD7 magenta

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment

# Long history, since atuin is not bound to the up arrow
set -g history_size 20000
set -g fish_history 20000

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# Migrated from .profile / .bash_aliases (fish does not read bash files) — 2026-07-17
# (JetBrains Toolbox removed 2026-07-17; llama* aliases dropped: the local
#  binaries were gone — llama.cpp now runs on a separate server)
fish_add_path $HOME/bin $HOME/.local/share/solana/install/active_release/bin

alias cr='ddev drush cr'
alias dcrestart='docker compose down && docker compose up -d'
alias ttmux='tmux attach'
alias vpn='ip link show wg0 >/dev/null 2>&1 && sudo wg-quick down wg0; sudo wg-quick up wg0'

# Node for the pi agent
fish_add_path "$HOME/.nvm/versions/node/v24.3.0/bin"
