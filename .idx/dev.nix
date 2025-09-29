{ pkgs, ... }:
{
  channel = "stable-23.11";

  packages = [
    pkgs.flutter,
    pkgs.dart,
    pkgs.cmake,
    pkgs.google-chrome,
    pkgs.clang,
    pkgs.ninja,
    pkgs.pkg-config
  ];

  env = {};

  idx = {
    extensions = [
      "dart-code.dart-code",
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
            "web-server"
            "--web-port"
            "$PORT"
            "--web-hostname"
            "0.0.0.0"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
