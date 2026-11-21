# Shared by every host; per-machine settings (hardware scan, hostname, GPU
# tweaks) live in hosts/<name>/.

{ pkgs, ... }:

{
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
    # run Electron/Chromium apps natively on Wayland
    NIXOS_OZONE_WL = "1";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # dbus and portal
  services.dbus.enable = true;

  # Hyprland session
  programs.hyprland.enable = true;

  # Login screen: greetd with the tuigreet TUI, launching Hyprland
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd start-hyprland";
      user = "greeter";
    };
  };

  # Keyring (secrets for Evolution, Chromium, etc.), unlocked at login via greetd
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  # lets hyprlock (Hyprland lock screen) check the password
  security.pam.services.hyprlock = { };
  programs.seahorse.enable = true;

  # File manager with archive/removable-media plugins; gvfs for trash, mounts
  # and network shares, tumbler for thumbnails, udisks2 for mounting drives
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      # the plugin only looks for archive-manager scripts in its own libexec,
      # so copy in the one xarchiver ships
      (thunar-archive-plugin.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          cp ${xarchiver}/libexec/thunar-archive-plugin/xarchiver.tap \
            $out/libexec/thunar-archive-plugin/
        '';
      }))
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  # flatpaks
  services.flatpak.enable = true;

  # Keymap (Hyprland sets its own in hyprland.lua; this covers XWayland)
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];

  # The driver's PPD hardcodes its Nix store path, so a queue added by hand breaks
  # once that path is garbage collected. Declaring it lets NixOS regenerate the PPD.
  hardware.printers.ensurePrinters = [
    {
      name = "Samsung-CLP-360";
      deviceUri = "socket://192.168.178.8:9100";
      model = "samsung/CLP-360.ppd";
      ppdOptions = {
        PageSize = "A4";
        ColorModel = "Gray";
      };
    }
  ];

  # enable locate
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
  };

  # Bluetooth manager (GUI + tray applet) for non-GNOME sessions
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."99-no-x11-bell" = {
      "context.properties" = {
        "module.x11.bell" = false;
      };
    };
    # RNNoise noise suppression: adds a "Noise Suppressed Mic" virtual source.
    # Replaces WebRTC echo-cancel, which used the output monitor as its echo
    # reference and so ducked/erased the voice whenever game audio was loud
    # (pointless with headphones anyway: there is no acoustic echo).
    # VAD threshold mutes audio below that voice-probability; kept low so quiet
    # speech isn't cut. Raise it (plugin default 50) to gate more aggressively.
    extraConfig.pipewire."60-rnnoise" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Noise Suppressed Mic";
            "media.name" = "Noise Suppressed Mic";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 20.0;
                    "VAD Grace Period (ms)" = 300;
                    "Retroactive VAD Grace (ms)" = 50;
                  };
                }
              ];
            };
            "audio.rate" = 48000;
            "audio.position" = [ "MONO" ];
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              # Always read the real USB mic, never whatever the default is
              # (the default is now this filter's own output).
              "target.object" = "alsa_input.usb-Generic_USB_Audio-00.HiFi__Mic__source";
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              # Outrank the hardware mic (priority 1812) so WirePlumber picks
              # this as the default source.
              "priority.session" = 2000;
            };
          };
        }
      ];
    };
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
    # Home Manager installs KeePassXC, but polkitd only reads actions from
    # the system profile. Without its unlockDatabase policy here, Quick
    # Unlock fails with a polkit error after the session locks.
    pkgs.keepassxc
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-29.4.6" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Virtualization with virt-manager
  programs.dconf.enable = true;

  # Gamemode
  programs.gamemode.enable = true;

  # Evolution mail client
  programs.evolution.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono # kitty, rofi
    inter # hyprlock
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Hyprland's portal handles screencast/screenshots; the GTK one provides file pickers
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.steam-hardware.enable = true;
  hardware.uinput.enable = true;

  hardware.xpadneo.enable = true; # Bluetooth

  programs.steam.protontricks = {
    enable = true;
    # Steam (Nov 2026) replaced appcache/appinfo.vdf with a sharded appinfo/
    # directory (format v42); 1.15.0 crashes with FileNotFoundError.
    # 1.15.1 reads it but imports its vendored _vdf directly, so nixpkgs'
    # revert-vendored-vdf patch and _vdf removal must go. 1.15.1 also assumes
    # fixed 80-byte section records and misparses shards with longer ones
    # (IndexError, Matoking/protontricks#521); the local patch reads each
    # record's trailer length. Drop once nixpkgs ships a release fixing #521.
    # makeOverridable: the steam module calls .override { extraCompatPaths },
    # which overridePythonAttrs alone would drop.
    package = pkgs.lib.makeOverridable (
      args:
      (pkgs.protontricks.override args).overridePythonAttrs (old: rec {
        version = "1.15.1";
        src = pkgs.fetchFromGitHub {
          owner = "Matoking";
          repo = "protontricks";
          tag = version;
          hash = "sha256-3AS/19bhQhQjgt7a5/RDS0lvfRa6Ex8OI93e1v0pmyg=";
        };
        patches = builtins.filter (
          p: !(pkgs.lib.hasSuffix "revert-vendored-vdf.patch" (toString p))
        ) old.patches ++ [ ./patches/protontricks-appinfo-v42-trailer.patch ];
        # Upstream's synthetic v42 fixture leaves the trailer length at 0
        # (real Steam shards fill it in), so it can't pass with the patch.
        disabledTests = (old.disabledTests or [ ]) ++ [ "test_parse_appinfo_v42" ];
        postPatch = "";
      })
    ) { };
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nano.enable = false;

  system.stateVersion = "26.05";
}
