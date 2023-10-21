{ config, pkgs, lib, ... }:

let
  # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
  flakePkg = uri:
    (builtins.getFlake uri).packages.aarch64-darwin.default;
in
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

    autocd = true;

    shellAliases = {
      ls = "eza";
      l = "ls -la";
      lt = "ls --long --tree";
      ltg = "ls --long --tree --git-ignore";
      ll = "ls -l";
      config = "nvim --cmd ':cd ~/.config'";
      update = "darwin-rebuild switch --flake ~/.config/nix-darwin";
    };

    initExtra = ''
      bdctl() {
        discord_modules="$(find ~/Library/Application\ Support/discord -name 'discord_desktop_core' -exec dirname {} \; | head -n 1)"
        
        NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix run --impure -- nixpkgs#betterdiscordctl --d-modules "$discord_modules" $@
      }

      eval $(thefuck --alias)
      '';

    history = {
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } 
        { name = "zsh-users/zsh-syntax-highlighting"; tags = [ "defer:2" ]; }
        { name = "mafredri/zsh-async"; tags = [ "from:github" ]; }
        { name = "sindresorhus/pure"; tags = [ "use:pure.zsh" "as:theme" "from:github" ]; }
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "KripperOldman";
    userEmail = "binarywarrior76@gmail.com";
    extraConfig = {
      core.pager = "nvim -R";
      color.pager = "no";
    };
  };

  programs.kitty = {
    enable = true;
    darwinLaunchOptions = [ "--start-as=fullscreen" "--single-instance" ];
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
      size = lib.mkForce 16;
    };
  };

  programs.neovim = {
    extraLuaConfig = lib.fileContents ../nvim/init.lua;
    vimAlias = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget

    eza
    ripgrep
    fzf
    fd
    tldr
    thefuck
    
    neovim

    discord

    # Dev stuff
    jq
    nodePackages.typescript
    nodejs
    python3
    jdk21
    mercurial
    cargo
    rustc

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ];

  # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
  home.activation.aliasApplications = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
      lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        last_apps=$(cat "${lastAppsFile}" 2>/dev/null || echo "")
        next_apps=$(readlink -f ${apps}/Applications/* | sort)

        if [ "$last_apps" != "$next_apps" ]; then
          echo "Apps have changed. Updating macOS aliases..."

          apps_path="$HOME/Applications/NixApps"
          $DRY_RUN_CMD mkdir -p "$apps_path"

          $DRY_RUN_CMD ${pkgs.fd}/bin/fd \
            -t l -d 1 . ${apps}/Applications \
            -x $DRY_RUN_CMD "${flakePkg "github:reckenrode/mkAlias/8a5478cdb646f137ebc53cb9d235f8e5892ea00a"}/bin/mkalias" \
            -L {} "$apps_path/{/}"

          [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > "${lastAppsFile}"
        fi
      ''
  );
}
