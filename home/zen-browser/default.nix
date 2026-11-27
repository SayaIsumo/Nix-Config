{ pkgs, ... }:

# Zen Browser (trial alongside chromium, which stays the default browser).
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
    profiles.default = {
      isDefault = true;
      settings = {
        # load chrome/userChrome.css + userContent.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Mocha only applies in dark mode
        "layout.css.prefers-color-scheme.content-override" = 0;
      };
      userChrome = builtins.readFile "${theme}/userChrome.css";
      userContent = builtins.readFile "${theme}/userContent.css";
    };
  };

  # userContent.css loads the new-tab logo from next to itself
  xdg.configFile."zen/default/chrome/zen-logo-mocha.svg".source = "${theme}/zen-logo-mocha.svg";
}
