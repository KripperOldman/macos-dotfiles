{ config, pkgs, lib, ... }:

{
  home.stateVersion = "22.05";

  # https://github.com/malob/nixpkgs/blob/master/home/default.nix

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  # programs.htop.enable = true;
  # programs.htop.settings.show_program_path = true;

  programs.zsh = {
    enable = true;

    shellAliases = {
      ls = "eza";
      l = "ls -la";
      lt = "ls --tree";
      ltg = "ls --tree --git-ignore";
      ll = "ls -l";
      config = "$EDITOR ~/.config/nix-darwin";
      update = "darwin-rebuild switch --flake ~/.config/nix-darwin";
    };

    initExtra = ''
      # opam configuration
      [[ ! -r /Users/bnrwrr/.opam/opam-init/init.zsh ]] || source /Users/bnrwrr/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
    '';

    history = {
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "mafredri/zsh-async"; tags = [ from:github ]; }
        { name = "sindresorhus/pure"; tags = [ use:pure.zsh as:theme from:github ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };
  };

  programs.kitty = {
    enable = true;
    darwinLaunchOptions = [ "--start-as=fullscreen" ];
    settings = {
      macos_traditional_fullscreen = true;
      macos_quit_when_last_window_closed = true;
      macos_option_as_alt = true;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
    theme = "Catppuccin-Macchiato";
    font = {
      name = "FiraCode Nerd Font Mono";
      size = lib.mkForce 14;
    };
  };

  programs.neovim = {
    programs.neovim.extraConfig = lib.fileContents ./nvim/init.lua;
    vimAlias = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    PAGER = "nvim -R";
    MANPAGER = "nvim +Man!";
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget

    eza.out
    ripgrep.out
    fzf.out
    
    neovim

    # Dev stuff
    jq
    nodePackages.typescript
    nodejs
    mercurial
    opam

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ];
}
