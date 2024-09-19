{ pkgs, lib, ... }:
{
  # Nix configuration ------------------------------------------------------------------------------
  users.users.bnrwrr = {
    name = "bnrwrr";
    home = "/Users/bnrwrr";
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # remove all homebrew-installed things not listed here 
      cleanup = "zap";
      extraFlags = [ "--verbose" ];
    };
    brews = [
      # "ollama"
    ];
    casks = [
      # "idafree"
      "postman"
      "adobe-acrobat-reader"
      "bitwarden"
      "dbeaver-community"
      "firefox@developer-edition"
      "mullvadvpn"
      "spotify"
      "flameshot"
      "openvpn-connect"
      "datagrip"
      "clion"
      "stremio"

      "nheko" # matrix client

      # "calibre"
      # "kindle-previewer"
      "vlc"

      # "dyalog"

      "zoom"

      "logisim-evolution"

      "microsoft-office"
    ];
    taps = [
      "homebrew/cask-versions"
    ];
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [
      "@admin"
    ];
  };

  nix.configureBuildUsers = true;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = aarch64-darwin x86_64-darwin
  '';

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
  ];

  programs.nix-index.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    recursive
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 30d";
  };
}
