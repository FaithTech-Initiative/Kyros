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
  devenv.component = "Mobile";

  # The following are automatically configured by IDX.
  # Feel free to move them around but don't delete them.
  # To learn more, visit https://developers.google.com/idx/guides/customize-idx-env
  previews = {
    enable = true;
    previews = [
      {
        id = "web";
        port = 3000;
        manager = "flutter";
      }
    ];
  };
  idx.previews = {
    enable = true;
    previews = [{
      id = "web";
      port = 3000;
      manager = "flutter";
    }];
  };
}
