{ config, pkgs, user, inputs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  imports = [
    inputs.omp.homeManagerModules.default
  ];

  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    # Add treehouse package from its flake input
    inputs.treehouse.packages.${pkgs.system}.default

    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    rustup
    # the font everything renders in
    nerd-fonts.hack
    bat
    zoxide
    nodejs
    python3Packages.huggingface-hub  # added for huggingface models
    ollama
    ghostty-bin
    tuios
  ];
  
  home.activation = {
    # Automatically sets rustup to stable after home-manager switch
    rustupStable = ''
      export PATH="$PATH:${pkgs.rustup}/bin"
      $DRY_RUN_CMD rustup default stable || true
    '';
  };


  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "Yang Li";
        email = "yangli0507@gmail.com";
      };
      core.editor = "nvim";
      color.ui = true;
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.updateRefs = true;
    };
  };

  programs.omp = {
    enable = true;
    settings = {
      setupVersion = 2;
      startup = {
        quiet = true;
      };
      theme = {
        dark = "dark-gruvbox";
      };
      symbolPreset = "nerd";
      composer = {
        shape = "claude";
        tokenRate = false;
      };
      statusLine = {
        preset = "defaut";
        transparent = true;
        compactThinkingLevel = true;
      };
      memory = {
        backend = "local";
      };

      providers = {
        omlx = {
          baseUrl = "http://localhost:8000/v1";
          apiKey = "mlx_decidedlyso";
        };
      };

      models = [
        {
          id = "Qwen3.8-27B-4bit";
          provider = "omlx";
          tokenizer = "qwen3";
          # Enabled thinking level configuration
          thinking = {
            type = "enabled";
          };
        }
        {
          id = "Qwen2.5-Coder-7B-Instruct-4bit";
          provider = "omlx";
          contextWindow = 131072;
          tokenizer = "qwen3";
          # Enabled thinking level configuration
          thinking = {
            type = "enabled";
          };
        }
      ];

      modelRoles = {
        default = "omlx-local/Qwen3.8-27B-4bit";
        advisor = "omlx-local/Qwen3.8-27B-4bit";
        judge   = "omlx-local/Qwen3.8-27B-4bit";
        plan    = "omlx-local/Qwen3.8-27B-4bit";
        task    = "omlx-local/Qwen2.5-Coder-7B-Instruct-4bit";
        vision  = "omlx-local/Qwen3.8-27B-4bit";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      mst = "git switch master";
      pushf = "git push --force";
      amend = "git commit --amend";
      reset = "git reset --soft HEAD^";
      rebasem = "git rebase -i main";
      rebasemst = "git rebase -i master";
      rebuild = "/run/current-system/sw/bin/darwin-rebuild switch --flake ~/github/dotfiles-mac-nix#mac";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      vi = "nvim";
      vim = "nvim";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  #home.file.".pi/agent/themes".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  #home.file.".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  #home.file.".pi/agent/models.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  #home.file.".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".omp/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";


  home.file.".editorconfig".text = ''
    root = true

    [*]
    indent_style = space
    indent_size = 2
  '';


}

