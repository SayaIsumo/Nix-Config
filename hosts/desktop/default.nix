# AMD desktop: Ryzen with iGPU + RX 7900
{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "desktop";

  # Render the Steam client on the RX 7900 (which drives the monitor).
  # Otherwise steamwebhelper picks the Ryzen iGPU, and its bursty redraws
  # cause audible static on the onboard audio's front headphone jack.
  programs.steam.package = pkgs.steam.override {
    extraEnv.DRI_PRIME = "pci-0000_03_00_0";
  };
}
