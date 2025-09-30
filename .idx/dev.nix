{ pkgs, ... }:
{
  channel = "stable-23.11";

  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.google-chrome
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
            "chrome"
            "--web-port"
            "$PORT"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
