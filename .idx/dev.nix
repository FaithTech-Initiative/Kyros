{ pkgs, ... }:

{
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # Or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.chromium
    pkgs.jdk17
  ];

  # Search for nix options here: https://search.nixos.org/options
  # Or commands here: https://search.nixos.org/cmds
  idx = {
    extensions = [
      "dart-code.dart-code"
      "dart-code.flutter"
    ];

    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "flutter"
            "run"
            "-d"
            "linux"
            "--web-port"
            "$PORT"
          ];
          manager = "flutter";
        };
      };
    };
    
    workspace = {
      onStart = {
        # Check flutter setup
        doctor = "flutter doctor";
      };
    };
  };
}
