# Intel Tiger Lake laptop (Iris Xe)
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "laptop";

  # power: switchable profiles (waybar click / powerprofilesctl), battery info
  # for waybar + critical-battery action, Intel thermal management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.thermald.enable = true;

  # waybar battery/backlight/power-profile modules, idle dim + suspend,
  # low-battery notifications (home/hyprland/laptop.nix)
  home-manager.users.saya.laptop.enable = true;
}
