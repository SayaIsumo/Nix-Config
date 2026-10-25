{ pkgs, ... }:
{

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 10;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    extraConfig = ''
      set -g prefix C-a
      unbind C-b
      bind-key C-a send-prefix
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      bind -r m resize-pane -Z

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind P paste-buffer
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"


      set-option -g focus-events on
      set-option -sa terminal-features ",xterm-kitty:RGB"
    '';
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      catppuccin
    ];
  };
}
