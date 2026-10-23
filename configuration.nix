# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # enable experimental features
  nix =
    let
      nix-users = [
        "root"
        "saya"
      ];
    in
    {
      # latest Nix package Manager Version
      package = pkgs.nixVersions.latest;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        trusted-users = nix-users;
        allowed-users = nix-users;
      };
    };

  # environment variables
  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # dbus and portal
  services.dbus.enable = true;

  # Enable the GNOME Desktop Environment.

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # flatpaks
  services.flatpak.enable = true;

  # or enable Hyprland
  programs.hyprland.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];

  # enable locate
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # enable zsh for user
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.saya = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Saya Isumo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "audio"
      "uinput"
      "input"
    ];
    packages = with pkgs; [

    ];
  };

  environment.systemPackages = [
    (pkgs.xivlauncher.overrideAttrs (old: {
      runtimeDeps = (old.runtimeDeps or [ ]) ++ [ pkgs.SDL2 ];
    }))
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-29.4.6" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  programs.noisetorch.enable = true;

  # Virtualization with virt-manager
  programs.dconf.enable = true;

  # Gamemode
  programs.gamemode.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  xdg.portal.enable = true;

  hardware.steam-hardware.enable = true;
  hardware.uinput.enable = true;

  hardware.xpadneo.enable = true; # Bluetooth

  programs.steam.protontricks.enable = true;

  system.stateVersion = "26.05";
}
