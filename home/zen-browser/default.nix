{ config, pkgs, ... }:

# Zen Browser, the default browser (see xdg.mimeApps in home/default.nix).
# Themed with catppuccin/zen-browser's userChrome/userContent CSS; the
# catppuccin/nix firefox module only drives Firefox Color, which Zen ignores.
let
  catppuccin-zen = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "c855685442c6040c4dda9c8d3ddc7b708de1cbaa";
    hash = "sha256-5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };
  theme = "${catppuccin-zen}/themes/Mocha/Lavender";
in
{
  programs.zen-browser = {
    enable = true;
    # keepassxc-proxy for KeePassXC-Browser autofill (the keepassxc HM
    # module only wires up chromium/firefox/etc., not Zen)
    nativeMessagingHosts = [ config.programs.keepassxc.package ];
    policies.ExtensionSettings."keepassxc-browser@keepassxc.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
      installation_mode = "normal_installed";
    };
    profiles.default = {
      isDefault = true;
      settings = {
        # load chrome/userChrome.css + userContent.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Mocha only applies in dark mode
        "layout.css.prefers-color-scheme.content-override" = 0;
        # mouse wheel tilt left/right = back/forward (0 none, 1 scroll,
        # 2 history, 3 zoom; -1 = no override). Also applies to touchpad
        # horizontal two-finger scroll.
        "mousewheel.default.action.override_x" = 2;
      };
      userChrome = builtins.readFile "${theme}/userChrome.css";
      userContent = builtins.readFile "${theme}/userContent.css";
    };
  };

  # userContent.css loads the new-tab logo from next to itself
  xdg.configFile."zen/default/chrome/zen-logo-mocha.svg".source = "${theme}/zen-logo-mocha.svg";
}
