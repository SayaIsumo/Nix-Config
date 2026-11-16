{ pkgs, claude-desktop, ... }:

let
  # Upstream still uses nodePackages.asar, which nixpkgs removed
  claude-desktop-unwrapped =
    (pkgs.callPackage "${claude-desktop}/pkgs/claude-desktop.nix" {
      patchy-cnb = claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.patchy-cnb;
      nodePackages = { inherit (pkgs) asar; };
    }).overrideAttrs
      (old: {
        # The app only trusts its own file:// renderer pages when
        # app.isPackaged is true. Launched as `electron app.asar` it never is,
        # so the main window's first IPC call is rejected ("did not pass
        # origin validation") and the window is never shown.
        postBuild = (old.postBuild or "") + ''
          index=app.asar.contents/.vite/build/index.js
          perl -i -pe 's{(\w+\.protocol==="file:")&&\w+\.app\.isPackaged===!0}{$1}g' "$index"
          if grep -qE 'protocol==="file:"&&\w+\.app\.isPackaged' "$index"; then
            echo "claude-desktop: file:// origin patch did not apply" >&2
            exit 1
          fi
          asar pack app.asar.contents app.asar
        '';
      });

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
