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
    ./hyprland
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
    # 5.1 hands mpv the video-only HLS variant, so hianime streams with
    # separate audio renditions play silent. Fixed upstream in #1967, not
    # yet released; drop this override once nixpkgs ships > 5.1.
    (ani-cli.overrideAttrs (old: {
      version = "5.1-unstable-2026-10-22";
      src = fetchFromGitHub {
        owner = "pystardust";
        repo = "ani-cli";
        rev = "0301d67d5768d332b049821a30082ad43d9a215a";
        hash = "sha256-NfC6dUwleAu0VX314EetbsxmjOFjWF9823zbwOcyw5s=";
      };
    }))
    btop
    mpv
    keepassxc
    libreoffice
    fastfetch
    zip
    rar
    unzip
    p7zip
    helvum
    gimp
    rawtherapee
    wowup-cf
    faugus-launcher
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
