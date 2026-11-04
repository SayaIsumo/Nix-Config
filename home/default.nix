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
    ./claude-desktop
  ];

  home.username = "saya";
  home.homeDirectory = "/home/saya";
  home.packages = with pkgs; [
    vesktop
    claude-code
    mangohud
    lazygit
    ungoogled-chromium
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
    keepassxc
    spotify
    libreoffice
    hyfetch
    zip
    rar
    unzip
    p7zip
    helvum
    gimp
    rawtherapee
    wowup-cf
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
