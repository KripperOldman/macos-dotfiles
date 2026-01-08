{ config, pkgs, lib, ... }:

# let
#   # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
#   flakePkg = uri:
#     (builtins.getFlake uri).packages.aarch64-darwin.default;
# in
{
  home.stateVersion = "24.05";

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
      py = "python3";
      ls = "eza";
      l = "ls -la";
      lt = "ls --long --tree";
      ltg = "ls --long --tree --git-ignore";
      ll = "ls -l";
      cd = "z";
      cdi = "zi";
      config = "nvim --cmd ':cd ~/.config'";
      update = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin";
      init-shell = "nix flake init -t github:nix-community/nix-direnv";
      mknote = "nvim \"$(date -u +%Y-%m-%dT%H%M%SZ).md\"";
    };

    initContent = ''
      PATH="$PATH:/opt/homebrew/bin:$HOME/.cargo/bin:$HOME/.local/bin"

      # opam
      # [[ ! -r /Users/bnrwrr/.opam/opam-init/init.zsh ]] || source /Users/bnrwrr/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

      # TMUX
      [[ "$TERM" == "xterm-kitty" ]] && tmux new -A -s main

      # function racketi
      #     if test (count $argv) -eq 0
      #         echo "Usage: racketi filename"
      #         return 1
      #     end
      #     racket -i -e "(enter! \"$argv[1]\")"
      # end
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

  programs.zoxide = {
    enable = true;
  };

  programs.git = {
    enable = true;
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
      {
        path = "~/Workspace/school/.gitconfig_include";
        condition = "gitdir:~/Workspace/school/";
      }
    ];
    settings = {
      core.pager = "nvim -R";
      color.pager = "no";
      init.defaultBranch = "main";
      credential.helper = "osxkeychain";
      alias = {
        ignore = "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      };
    };
  };

  programs.ghostty = {
    package = pkgs.ghostty-bin;
    enable = false;
    settings = {
      font-family = "Hack Nerd Font Mono";
      font-size = 9;

      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;

      window-decoration = "none";
      window-show-tab-bar = "never";

      clipboard-read = "allow";
      clipboard-write = "allow";

      initial-command = "tmux new-session";

      # keybind = [
      #   "ctrl+equal=increase_font_size:1"
      #   "ctrl+minus=decrease_font_size:1"
      #   "ctrl+shift+r=reload_config"
      # ];
    };
    # clearDefaultKeybinds = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      macos_traditional_fullscreen = true;
      macos_quit_when_last_window_closed = true;
      macos_option_as_alt = true;
      enable_audio_bell = false;
      update_check_interval = 0;
    };
    themeFile = "Catppuccin-Macchiato";
    font = {
      name = "Iosevka Nerd Font Mono";
      size = lib.mkForce 14;
    };
    extraConfig = ''
      # clear_all_shortcuts yes
      # map ctrl+shift+equal change_font_size current +1.0
      # map ctrl+shift+minus change_font_size current -1.0
      window_padding_width 0
    '';
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

      # For [image.nvim](https://github.com/3rd/image.nvim#tmux)
      set -gq allow-passthrough on
      
      # Neovim asked for this
      set-option -sg escape-time 10
    '';
  };

  programs.neovim = {
    extraLuaConfig = lib.fileContents ../nvim/init.lua;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = true;
  };

  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
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

    # ollama

    direnv
    eza
    ripgrep
    fzf
    fd
    tldr

    vim
    # neovim
    unstable.neovim
    page
    tree-sitter
    luajit
    luajitPackages.luarocks
    viu
    chafa

    vesktop # vencord
    discord

    mpv

    # Dev stuff
    jq
    rlwrap
    nodePackages.typescript
    nodejs
    python3
    jdk21
    maven
    mercurial
    cargo
    rustc
    prettierd
    clojure
    leiningen
    babashka
    gcc
    zig

    aria2

    # opam

    postgresql

    kitty
    ueberzugpp

    pass

    texlive.combined.scheme-full
    pngpaste

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    niv # easy dependency management for nix projects
  ] ++ lib.optionals
    stdenv.isDarwin
    [
      cocoapods
      m-cli # useful macOS CLI commands
    ];

  # # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
  # home.activation.aliasApplications = lib.mkIf
  #   pkgs.stdenv.hostPlatform.isDarwin
  #   (
  #     let
  #       apps = pkgs.buildEnv {
  #         name = "home-manager-applications";
  #         paths = config.home.packages;
  #         pathsToLink = "/Applications";
  #       };
  #       lastAppsFile = "${config.xdg.stateHome}/nix/.apps";
  #     in
  #     lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #       last_apps=$(cat "${lastAppsFile}" 2>/dev/null || echo "")
  #       next_apps=$(readlink -f ${apps}/Applications/* | sort)
  #
  #       if [ "$last_apps" != "$next_apps" ]; then
  #         echo "Apps have changed. Updating macOS aliases..."
  #
  #         apps_path="$HOME/Applications/NixApps"
  #         $DRY_RUN_CMD mkdir -p "$apps_path"
  #
  #         $DRY_RUN_CMD ${pkgs.fd}/bin/fd \
  #           -t l -d 1 . ${apps}/Applications \
  #           -x $DRY_RUN_CMD "${flakePkg "github:reckenrode/mkAlias/8a5478cdb646f137ebc53cb9d235f8e5892ea00a"}/bin/mkalias" \
  #           -L {} "$apps_path/{/}"
  #
  #         [ -z "$DRY_RUN_CMD" ] && echo "$next_apps" > "${lastAppsFile}"
  #       fi
  #     ''
  #   );
}
