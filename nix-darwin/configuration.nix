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
      "minimal-racket"

    ];
    casks = [
      # "idafree"
      "adobe-acrobat-reader"
      "bitwarden"
      "dbeaver-community"
      # "firefox@developer-edition"
      "waterfox"
      "chromium"
      "mullvad-vpn"
      "spotify"
      "flameshot"
      "openvpn-connect"
      # "datagrip"
      # "clion"
      # "stremio"
      "qbittorrent"

      "balenaetcher"

      "signal"

      # "calibre"
      # "kindle-previewer"
      "vlc"

      "gimp"
      "krita"

      # "dyalog"

      "zoom"

      # "logisim-evolution"

      # "microsoft-office"
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

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
  ];

  programs.nix-index.enable = true;

  # Fonts
  # fonts.packages = with pkgs; [
  #   recursive
  #   (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  # ];
  fonts.packages = with pkgs.nerd-fonts; [
    symbols-only
    fira-code
    jetbrains-mono
    iosevka
  ];

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  system.stateVersion = 4;
}
