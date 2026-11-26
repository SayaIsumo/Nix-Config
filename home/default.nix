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
    ./fastfetch
  ];

  home.username = "saya";
  home.homeDirectory = "/home/saya";
  home.packages = with pkgs; [
    claude-code
    mangohud
    lazygit
    curl
    wget
    sshfs
    nil
    nixfmt
    ripgrep
    bat
    whatsie
    protonplus
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
    libreoffice
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

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  # Declarative default apps. Vesktop (Electron) claimed http/https/text/html
  # in the mutable mimeapps.list, so Steam and every other xdg-open link
  # opened in Discord. force overwrites the old hand-edited file.
  xdg.mimeApps =
    let
      browser = "chromium-browser.desktop";
    in
    {
      enable = true;
      defaultApplications = {
        "text/html" = browser;
        "application/xhtml+xml" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/claude" = "claude.desktop";
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        "x-scheme-handler/mailto" = "userapp-Evolution-EH53X3.desktop";
        "application/vnd.microsoft.portable-executable" = "protontricks-launch.desktop";
      };
    };
  xdg.configFile."mimeapps.list".force = true;

  # Only Vesktop is themed through catppuccin/nix; the rest is set up by hand.
  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "lavender";
    vesktop.enable = true;
  };

  # mutableSettings merges the theme into settings.json, which stays writable
  # for Vencord. Close Vesktop before rebuilding when this changes.
  programs.vesktop = {
    enable = true;
    vencord.mutableSettings = true;
  };

  # Also links KeePassXC's native messaging manifest into
  # ~/.config/chromium/NativeMessagingHosts, so the KeePassXC-Browser
  # extension keeps finding keepassxc-proxy after every update.
  # Untick "Update native messaging manifest files at startup" in
  # KeePassXC's Browser Integration > Advanced, or it will complain that
  # it can't overwrite the read-only link.
  programs.keepassxc.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "26.05";
}
