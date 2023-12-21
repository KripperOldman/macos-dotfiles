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
      init-shell = "nix flake init -t github:nix-community/nix-direnv";
    };

    initExtra = ''
      PATH="$PATH:/opt/homebrew/bin:$HOME/.cargo/bin"

      # betterdiscordctl
      bdctl() {
        discord_modules="$(find ~/Library/Application\ Support/discord -name 'discord_desktop_core' -exec dirname {} \; | head -n 1)"
        NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix run --impure -- nixpkgs#betterdiscordctl --d-modules "$discord_modules" $@
      }

      # thefuck
      eval $(thefuck --alias)

      # opam
      # [[ ! -r /Users/bnrwrr/.opam/opam-init/init.zsh ]] || source /Users/bnrwrr/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

      # TMUX
      [[ "$TERM" == "xterm-kitty" ]] && tmux new -A -s main
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
    aliases = {
      ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
    };
    includes = [
      {
        path = "~/Workspace/personal/.gitconfig_include";
        condition = "gitdir:~/Workspace/personal/";
      }
      {
        path = "~/Workspace/kripper/.gitconfig_include";
        condition = "gitdir:~/Workspace/kripper/";
      }
      {
        path = "~/Workspace/work/.gitconfig_include";
        condition = "gitdir:~/Workspace/work/";
      }
    ];
    extraConfig = {
      core.pager = "nvim -R";
      color.pager = "no";
      init.defaultBranch = "main";
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

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "screen-256color";
    baseIndex = 1;
    mouse = true;
    historyLimit = 10000;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin-flavour 'machhiato'
          set -g @catppuccin-powerline-icons-theme-enabled 'on'
          set -g @catppuccin-l-left-separator ''
          set -g @catppuccin-l-right-separator ''
          set -g @catppuccin-r-left-separator ''
          set -g @catppuccin-r-right-separator ''
        '';
      }
      pkgs.tmuxPlugins.pain-control
      pkgs.tmuxPlugins.yank
    ];
    extraConfig = ''
      # Better Vi Copy Mode Bindings

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
    '';
  };

  programs.neovim = {
    extraLuaConfig = lib.fileContents ../nvim/init.lua;
    vimAlias = true;
    defaultEditor = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
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
    gawk
    csvquote
    parallel
    gnupg

    eza
    ripgrep
    fzf
    fd
    tldr
    thefuck

    vim
    neovim
    page
    tree-sitter

    discord

    gimp

    # Dev stuff
    jq
    nodePackages.typescript
    nodejs
    python3
    jdk21
    maven
    mercurial
    cargo
    rustc
    prettierd
    go
    clojure
    babashka

    # opam

    postgresql

    kitty

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
  ] ++ lib.optionals
    stdenv.isDarwin
    [
      cocoapods
      m-cli # useful macOS CLI commands
    ];

  # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
  home.activation.aliasApplications = lib.mkIf
    pkgs.stdenv.hostPlatform.isDarwin
    (
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
        lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
