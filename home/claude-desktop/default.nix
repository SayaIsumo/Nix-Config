{ pkgs, claude-desktop, ... }:

let
  # Upstream still uses nodePackages.asar, which nixpkgs removed
  claude-desktop-unwrapped = pkgs.callPackage "${claude-desktop}/pkgs/claude-desktop.nix" {
    patchy-cnb = claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.patchy-cnb;
    nodePackages = { inherit (pkgs) asar; };
  };

  # Mirrors upstream's claude-desktop-with-fhs so MCP servers can use npx/uvx/docker
  claude-desktop-with-fhs = pkgs.buildFHSEnv {
    name = "claude-desktop";
    targetPkgs =
      pkgs: with pkgs; [
        docker
        glibc
        openssl
        nodejs
        uv
      ];
    runScript = "${claude-desktop-unwrapped}/bin/claude-desktop";
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${claude-desktop-unwrapped}/share/applications/claude.desktop $out/share/applications/

      mkdir -p $out/share/icons
      cp -r ${claude-desktop-unwrapped}/share/icons/* $out/share/icons/
    '';
  };
in
{
  home.packages = [ claude-desktop-with-fhs ];
}
