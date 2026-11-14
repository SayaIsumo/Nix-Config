{ pkgs, ... }:
{

  home.packages = with pkgs; [
    wlogout
    satty # screenshot annotation (SUPER+ALT+P)
    hyprshot # screenshots (SUPER+P, SUPER+SHIFT+P, SUPER+CTRL+P)
    xdg-utils
    nomacs
    brightnessctl
    pamixer
    pavucontrol
    wl-clipboard
    cliphist
    # replacements for the GNOME apps
    xarchiver # archive manager (File Roller), used by Thunar's archive plugin
    qalculate-gtk # calculator (Calculator)
    gparted # partitioning (Disks)
    networkmanagerapplet # network tray + connection editor (Settings > Network)
    nwg-look # GTK theme/font/icon settings (Settings > Appearance)
  ];

  # the screenshot keybinds in hyprland.lua save here
  systemd.user.tmpfiles.rules = [ "d %h/Pictures/Screenshots 0755 - - -" ];

  # keep blueman-applet's pairing agent but drop its tray icon (waybar's bluetooth module replaces it).
  # ShowConnected depends on StatusIcon and would load it back in, so disable both
  dconf.settings."org/blueman/general".plugin-list = [ "!StatusIcon" "!ShowConnected" ];

  # polkit authentication agent (GNOME Shell used to provide one)
  services.hyprpolkitagent.enable = true;

  # idle: monitor off after 10 min, lock after 15, lock before suspend. Also makes
  # `loginctl lock-session` (wlogout's Lock button) run hyprlock.
  # Hyprland 0.57 needs the Lua dispatcher form for dpms
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
        {
          timeout = 900;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  # lock screen (SUPER+L), same rose-pine look the swaylock-effects config had.
  # PAM service is security.pam.services.hyprlock in configuration.nix
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };
      background = [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 7;
        brightness = 0.6;
      }];
      label = [{
        text = "$TIME";
        font_family = "Inter";
        font_size = 72;
        color = "rgb(e0def4)";
        position = "0, 120";
        halign = "center";
        valign = "center";
      }];
      input-field = [{
        size = "300, 50";
        position = "0, -40";
        halign = "center";
        valign = "center";
        outline_thickness = 4;
        outer_color = "rgb(191724)";
        inner_color = "rgb(1f1d2e)";
        font_color = "rgb(e0def4)";
        font_family = "Inter";
        check_color = "rgb(eb6f92)"; # verifying
        fail_color = "rgb(31748f)";
        fail_text = "$FAIL ($ATTEMPTS)";
        capslock_color = "rgb(f6c177)";
        placeholder_text = "Password";
        fade_on_empty = false;
      }];
    };
  };

  # hyprland stuff
  programs.waybar = {
    enable = true;
    # package = pkgs.waybar;
    style = ''
              * {
        /* `otf-font-awesome` is required to be installed for icons */
        font-family: JetBrainsMono Nerd Font;
        font-size: 11px;
        font-weight: 900;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        /* background-color: rgba(26, 27, 38, 0.5); */
        background-color: transparent;
        color: #ffffff;
        transition-property: background-color;
        transition-duration: 0.5s;
        /* border-top: 8px transparent; */
        border-radius: 0px;
        transition-duration: 0.5s;
        margin: 0px 0px;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #workspaces button {
        padding: 0 0px;
        color: #7984a4;
        background-color: transparent;
        /* Use box-shadow instead of border so the text isn't offset */
        box-shadow: inset 0 -3px transparent;
        /* Avoid rounded borders under each workspace name */
        border: none;
        border-radius: 0;
      }

      #workspaces button.focused {
        background-color: transparent;
      }
      #workspace button.hover {
        background-color: transparent;
      }
      #workspaces button.active {
        color: #fff;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #window {
        /* border-radius: 20px; */
        /* padding-left: 10px; */
        /* padding-right: 10px; */
        color: #64727d;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #mpd,
      #bluetooth,
      #custom-hyprPicker,
      #custom-power-menu,
      #custom-weather,
      #custom-weather.severe,
      #custom-weather.sunnyDay,
      #custom-weather.clearNight,
      #custom-weather.cloudyFoggyDay,
      #custom-weather.cloudyFoggyNight,
      #custom-weather.rainyDay,
      #custom-weather.rainyNight,
      #custom-weather.showyIcyDay,
      #custom-weather.snowyIcyNight,
      #custom-weather.default {
        padding: 0px 15px;
        color: #e5e5e5;
        /* color: #bf616a; */
        border-radius: 20px;
        background-color: #1e1e1e;
      }

      #window,
      #workspaces {
        border-radius: 20px;
        padding: 0px 10px;
        background-color: #1e1e1e;
      }

      #cpu {
        color: #fb958b;
        background-color: #1e1e1e;
      }

      #memory {
        color: #ebcb8b;
        background-color: #1e1e1e;
      }

      #custom-power-menu {
        border-radius: 9.5px;
        background-color: #1b242b;
        border-radius: 7.5px;
        padding: 0 0px;
      }

      #custom-launcher {
        background-color: #1b242b;
        color: #6a92d7;
        border-radius: 7.5px;
        padding: 0 0px;
      }

      #custom-weather.severe {
        color: #eb937d;
      }

      #custom-weather.sunnyDay {
        color: #c2ca76;
      }

      #custom-weather.clearNight {
        color: #cad3f5;
      }

      #custom-weather.cloudyFoggyDay,
      #custom-weather.cloudyFoggyNight {
        color: #c2ddda;
      }

      #custom-weather.rainyDay,
      #custom-weather.rainyNight {
        color: #5aaca5;
      }

      #custom-weather.showyIcyDay,
      #custom-weather.snowyIcyNight {
        color: #d6e7e5;
      }

      #custom-weather.default {
        color: #dbd9d8;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
        margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
        margin-right: 0;
      }

      #pulseaudio {
        color: #7d9bba;
      }

      #backlight {
        /* color: #EBCB8B; */
        color: #8fbcbb;
      }

      #clock {
        color: #c8d2e0;
        /* background-color: #14141e; */
      }

      #battery {
        color: #c0caf5;
        /* background-color: #90b1b1; */
      }

      #battery.charging,
      #battery.full,
      #battery.plugged {
        color: #26a65b;
        /* background-color: #26a65b; */
      }

      @keyframes blink {
        to {
          background-color: rgba(30, 34, 42, 0.5);
          color: #abb2bf;
        }
      }

      #battery.critical:not(.charging) {
        color: #f53c3c;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #000000;
      }

      #disk {
        background-color: #964b00;
      }

      #bluetooth {
        color: #707d9d;
      }

      #bluetooth.disconnected {
        color: #f53c3c;
      }

      #network {
        color: #b48ead;
      }

      #network.disconnected {
        color: #f53c3c;
      }

      #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
      }

      #custom-media.custom-vlc {
        background-color: #ffa000;
      }

      #temperature {
        background-color: #f0932b;
      }

      #temperature.critical {
        background-color: #eb4d4b;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }

      #idle_inhibitor {
        background-color: #2d3436;
      }

      #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
      }

      #language {
        background: #00b093;
        color: #740864;
        padding: 0 0px;
        margin: 0 5px;
        min-width: 16px;
      }

      #keyboard-state {
        background: #97e1ad;
        color: #000000;
        padding: 0 0px;
        margin: 0 5px;
        min-width: 16px;
      }

      #keyboard-state > label {
        padding: 0 0px;
      }

      #keyboard-state > label.locked {
        background: rgba(0, 0, 0, 0.2);
      }
    '';
  };

  programs.lf.enable = true;

  programs.zathura = {
    enable = true;
    extraConfig = ''
      set default-fg                "#CDD6F4"
      set default-bg 			          "#1E1E2E"

      set completion-bg		          "#313244"
      set completion-fg		          "#CDD6F4"
      set completion-highlight-bg	  "#575268"
      set completion-highlight-fg	  "#CDD6F4"
      set completion-group-bg		    "#313244"
      set completion-group-fg		    "#89B4FA"

      set statusbar-fg		          "#CDD6F4"
      set statusbar-bg		          "#313244"

      set notification-bg		        "#313244"
      set notification-fg		        "#CDD6F4"
      set notification-error-bg	    "#313244"
      set notification-error-fg	    "#F38BA8"
      set notification-warning-bg	  "#313244"
      set notification-warning-fg	  "#FAE3B0"

      set inputbar-fg			          "#CDD6F4"
      set inputbar-bg 		          "#313244"

      set recolor-lightcolor		    "#1E1E2E"
      set recolor-darkcolor		      "#CDD6F4"

      set index-fg			            "#CDD6F4"
      set index-bg			            "#1E1E2E"
      set index-active-fg		        "#CDD6F4"
      set index-active-bg		        "#313244"

      set render-loading-bg		      "#1E1E2E"
      set render-loading-fg		      "#CDD6F4"

      set highlight-color		        "#575268"
      set highlight-fg              "#F5C2E7"
      set highlight-active-color	  "#F5C2E7"
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        frame_color = "#89B4FA";
        separator_color = "frame";
      };
      urgency_low = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };
      urgency_normal = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };
      urgency_critical = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#FAB387";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  gtk = {
    enable = true;
    theme = {
      # must match the directory the package installs under share/themes
      name = "catppuccin-mocha-lavender-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "standard";
        variant = "mocha";
      };
    };
    # Papirus icons with Catppuccin-coloured folders (Thunar and other GTK apps)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "lavender";
      };
    };
  };

  # cursor theme for GTK/X11 apps; Hyprland picks it up via XCURSOR_THEME in hyprland.lua
  home.pointerCursor = {
    enable = true;
    package = pkgs.catppuccin-cursors.mochaLavender;
    name = "catppuccin-mocha-lavender-cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # wofi kept as a fallback while trying rofi
  programs.wofi.enable = true;

  # app launcher (SUPER+D). rofi 2.0 runs natively on Wayland
  programs.rofi = {
    enable = true;
    theme = ./configfiles/rofi/mocha.rasi;
    settings = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      terminal = "kitty";
      drun-display-format = "{name}";
      display-drun = "";
    };
  };

  # start Wayland user services (awww) only in Hyprland. The default graphical-session.target
  # is also reached under GNOME, where awww-daemon has no layer-shell and would restart-loop.
  # hyprland-session.target ships with Hyprland and is started by start-hyprland
  wayland.systemd.target = "hyprland-session.target";

  services.awww.enable = true;
  # the daemon restores its cached image on its own; this sets the configured one once its socket is up
  systemd.user.services.awww.Service.ExecStartPost = "${pkgs.writeShellScript "awww-set-wallpaper" ''
    until ${pkgs.awww}/bin/awww query >/dev/null 2>&1; do sleep 0.1; done
    ${pkgs.awww}/bin/awww img "$HOME/Pictures/Wallpapers/wallpaper.jpg"
  ''}";

  home.file = {
    # hyprland stuff
    ".config/hypr/hyprland.lua".source = ./configfiles/hypr/hyprland.lua;
    ".config/hypr/mocha.lua".source = ./configfiles/hypr/mocha.lua;

    # hyprland scripts
    ".config/hypr/scripts/volume.sh".source = ./configfiles/hypr/scripts/volume.sh;
    ".config/hypr/scripts/brightness.sh".source = ./configfiles/hypr/scripts/brightness.sh;

    # waybar config
    ".config/waybar/config".source = ./configfiles/waybar/config;

    # wofi
    ".config/wofi/config".source = ./configfiles/wofi/config;
    ".config/wofi/style.css".source = ./configfiles/wofi/style.css;
  };
}
