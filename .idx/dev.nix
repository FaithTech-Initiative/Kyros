{ pkgs, ... }:
{
  # Which nixpkgs channel to use.
  channel = "stable-23.11"; # Or "unstable"
  # Use https://search.nixos.org/packages to find packages.
  packages = [
    pkgs.flutter
    pkgs.dart
    pkgs.cmake
  ];
  # Sets environment variables in the workspace.
  env = {};
  # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id" for the name.
  extensions = [
    "dart-code.dart-code"
    "dart-code.flutter"
  ];
  # Designer events that trigger IDE actions.
  # Read more at https://www.jetpack.io/devbox/docs/ide-integration/updated-config-files/
  devcontainer = {
    # The name of the container. Does not affect functionality.
    "name" = "devbox";
    # The path to a Dockerfile. It can be a relative path to the devcontainer.json.
    "dockerfile" = "Dockerfile.devbox";
    # An array of port numbers or "host:port" values that should be forwarded from the container.
    # "ports" = [ 3000, 8080 ];
    # A list of features to add to the container.
    # "features" = {
    #   "ghcr.io/devcontainers/features/go:1": {
    #     "version": "1.20"
    #   }
    # };
    # An object of settings that will be written to the VS Code settings file.
    "settings" = {
      "workbench.colorTheme" = "Default Dark Modern";
    };
    # An array of VS Code extensions that should be installed.
    "extensions" = [
      "dart-code.dart-code",
      "dart-code.flutter"
    ];
    # A command to run when the container is created.
    # "postCreateCommand" = "npm install";
    # A command to run when the container is started.
    # "postStartCommand" = "npm start";
  };
  # Enable this to use private packages from a private Nix registry.
  # registry = "https://user:password@registry.com/my-org/my-repo/nix";
}
