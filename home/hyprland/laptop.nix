# Laptop-only bits of the Hyprland session: battery/backlight/power-profile in
# waybar, screen dimming + suspend on idle, low-battery notifications.
# Turned on per host with `home-manager.users.saya.laptop.enable = true;`
# (hosts/laptop/default.nix); the system side (power-profiles-daemon, upower,
# thermald) lives there too.
{ config, lib, ... }:

let
  cfg = config.laptop;
in
{
  options.laptop.enable = lib.mkEnableOption "laptop power management in the Hyprland session";

  config = {
    # waybar's main config pulls this in via "include". It carries modules-right
    # so the laptop can add its modules without forking the whole config.
    xdg.configFile."waybar/host.json".text = builtins.toJSON (
      {
        modules-right = [
          "tray"
          "network"
          "bluetooth"
          "pulseaudio"
        ]
        ++ lib.optionals cfg.enable [
          "backlight"
          "power-profiles-daemon"
          "battery"
        ];
      }
      // lib.optionalAttrs cfg.enable {
        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
        # click cycles performance / balanced / power-saver
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          format-icons = {
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰾆";
            default = "󰾅";
          };
        };
        battery = {
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-full = "󰁹 {capacity}%";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format = "{timeTo}\n{power:.1f} W";
        };
      }
    );

    # dim after 5 min idle (restored on input), suspend after 30. hypridle locks
    # before sleep (before_sleep_cmd in default.nix), and apps holding an idle
    # inhibitor (mpv, video in chromium) keep both from firing
    services.hypridle.settings.listener = lib.mkIf cfg.enable [
      {
        timeout = 300;
        on-timeout = "brightnessctl -s set 10%";
        on-resume = "brightnessctl -r";
      }
      {
        timeout = 1800;
        on-timeout = "systemctl suspend";
      }
    ];

    # dunst notifications at 15% (warning) and 5% (critical); upower hybrid-sleeps at its own critical level
    services.batsignal = lib.mkIf cfg.enable {
      enable = true;
      extraArgs = [
        "-w"
        "15"
        "-c"
        "5"
        "-d"
        "0" # upower handles the danger level
      ];
    };
  };
}
