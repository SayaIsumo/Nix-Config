{ ... }:

let
  # Catppuccin Mocha, to match kitty
  c = {
    overlay2 = "#9399b2";
    text = "#cdd6f4";
    lavender = "#b4befe";
    mauve = "#cba6f7";
    yellow = "#f9e2af";
    peach = "#fab387";
    pink = "#f5c2e7";
    red = "#f38ba8";
  };

  # fastfetch format strings take raw SGR codes: {#38;2;r;g;b}
  fg =
    hex:
    let
      h = builtins.substring 1 6 hex;
      byte = i: toString (builtins.fromTOML "v = 0x${builtins.substring i 2 h}").v;
    in
    "{#38;2;${byte 0};${byte 2};${byte 4}}";

  line = format: {
    type = "custom";
    inherit format;
  };
  section = title: line "│ ${title}";
  gap = line "│";
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos";
        color = {
          "1" = c.lavender;
          "2" = c.yellow;
          "3" = c.overlay2;
          "4" = c.lavender;
          "5" = c.yellow;
          "6" = c.overlay2;
        };
        padding = {
          top = 1;
          right = 4;
        };
      };

      display = {
        separator = "  ";
        color.keys = c.pink;
        key = {
          type = "string";
          width = 16;
        };
      };

      modules = [
        {
          type = "title";
          format = "┌──── {#97}User : ${fg c.peach}{user-name}@{host-name}";
        }
        (section "System Information")
        {
          type = "os";
          key = "│  OS";
        }
        {
          type = "kernel";
          key = "│  Kernel";
        }
        {
          type = "uptime";
          key = "│  Uptime";
        }
        {
          type = "packages";
          key = "│ 󰏖 Nix System";
          format = "{nix-system}";
        }
        {
          type = "packages";
          key = "│ 󰏖 Nix User";
          format = "{nix-user}";
        }
        gap
        (section "Desktop Environment")
        {
          type = "wm";
          key = "│  WM";
        }
        {
          type = "shell";
          key = "│  Shell";
        }
        gap
        (section "Hardware Information")
        {
          type = "cpu";
          key = "│  CPU";
        }
        {
          type = "gpu";
          key = "│ 󰢮 GPU";
        }
        {
          type = "memory";
          key = "│  Memory";
        }
        {
          type = "disk";
          key = "│ 󰋊 Disk";
          folders = "/";
        }
        gap
        (line (
          "│  "
          + builtins.concatStringsSep " " (
            map (h: "${fg h}●") [
              c.overlay2
              c.text
              c.lavender
              c.mauve
              c.yellow
              c.peach
              c.pink
              c.red
            ]
          )
        ))
        (line "└──────────────────────────────────────────────┘")
      ];
    };
  };
}
