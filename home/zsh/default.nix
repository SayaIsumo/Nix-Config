{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l --color=auto";
      la = "ls -A --color=auto";
      lla = "ls -lA --color=auto";
      webserver-ssh = "ssh ubuntu@144.24.186.232";
      webserver-mount = "sshfs ubuntu@144.24.186.232:/home/ubuntu ~/mnt";
      nix-update = "nix flake update --flake ~/Projects/NixOS-Config/";
      nix-clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      setup-direnv = "echo 'use flake' >> .envrc && direnv allow";
      rebuild-system = "sudo nixos-rebuild switch --flake github:domi2610/Nix-Config"; # nixos-rebuild picks #<hostname>
    };
  };
}
