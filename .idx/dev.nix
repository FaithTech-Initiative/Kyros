{ pkgs, ... }:
{
  channel = "stable-23.11";

  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.google-chrome
    pkgs.android-tools
    pkgs.android-sdk
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
        android = {
          command = [
            "flutter"
            "run"
            "-d"
            "android"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
