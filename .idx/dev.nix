{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.dart
  ];
  # Sets environment variables in the workspace
  env = {};
  # Fast way to define dev containers (built using nix)
  # More info: https://devenv.sh/basics/

  # The following are automatically configured by IDX.
  # Feel free to move them around but don't delete them.
  # To learn more, visit https://developers.google.com/idx/guides/customize-idx-env
  idx = {
    previews = {
      enable = true;
      previews = {
        web = {
          manager = "flutter";
        };
      };
    };
    # Workspace settings
    workspace = {
      # VS Code specific settings
      vscode = {
        # Amends VS Code settings.json
        settings = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "Dart-Code.dart-code";
        };
        # Recommended VS Code extensions
        recommendations = [
          "breact.flutter-files",
          "redhat.vscode-yaml"
        ];
      };
    };
    # IDX extensions installed in this workspace
    extensions = [
      "dart-code.flutter",
      "dart-code.dart-code"
    ];
    # Runs commands on workspace startup
    startup = {
      # This command runs in the background
      background = {
        "Flutter" = "flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0";
      };
      # These commands run in the foreground
      foreground = {};
    };
  };
}
