{ pkgs, ... }:

{

  imports = [
    ./neovim
    ./starship
    ./tmux
    ./kitty
    ./zsh
    ./git
    ./gpg
  ];

  home.username = "saya";
  home.homeDirectory = "/home/saya";
  home.packages = with pkgs; [
    claude-code
    mangohud
    lazygit
    ungoogled-chromium
    obsidian
    curl
    wget
    sshfs
    nil
    nixfmt
    ripgrep
    bat
    whatsie
    protonup-qt
    ani-cli
    btop
    mpv
    gnome-secrets
    spotify
    libreoffice
    hyfetch
    zip
    rar
    unzip
    helvum
    discord
    gimp
    rawtherapee
  ];

  home.file = {
    ".config/nixpkgs/config.nix".text = ''
      {
          allowUnfree = true;
      }
    '';
  };

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "26.05";
}
