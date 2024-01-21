{ overlays, nvim-config, stylix ? null }: { config, pkgs, lib, ... }:
let
  cfg = config.jhome;
  devcfg = cfg.dev;
in
{
  imports = [
    # Apply overlays
    { nixpkgs = { inherit overlays; }; }
    nvim-config.nixosModules.default
    ./options.nix
    ./gui
    ./users.nix
  ] ++ lib.optionals (stylix != null) [
    stylix.homeManagerModules.stylix
    {
      stylix.image = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/lunik1/nixos-logo-gruvbox-wallpaper/d4937c424fad79c1136a904599ba689fcf8d0fad/png/gruvbox-dark-rainbow.png";
        sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
      };
    }
  ];

  config = lib.mkIf cfg.enable {
    # Direnv
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    # ls replacement
    programs.eza.enable = true;
    programs.eza.enableAliases = true;
    programs.eza.git = true;
    programs.eza.icons = true;
    # GnuPG
    programs.gpg.enable = true;
    programs.gpg.homedir = "${config.xdg.dataHome}/gnupg";
    # Git
    programs.git.enable = true;
    programs.git.difftastic.enable = true;
    programs.git.difftastic.background = "dark";
    programs.git.lfs.enable = true;
    programs.git.extraConfig.init.defaultBranch = "main";
    programs.git.extraConfig.merge.conflictStyle = "zdiff3";
    programs.lazygit.enable = true;
    # Mail client
    programs.himalaya.enable = true;
    # Another shell
    programs.nushell.enable = true;
    # Password manager
    programs.password-store.enable = true;
    programs.password-store.package = pkgs.pass-nodmenu;
    programs.password-store.settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
    # SSH
    programs.ssh.enable = true;
    # cd replacement
    programs.zoxide.enable = true;
    # Shell
    programs.zsh.enable = true;
    programs.zsh.enableAutosuggestions = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.autocd = true;
    programs.zsh.dotDir = ".config/zsh";
    programs.zsh.history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    programs.zsh.syntaxHighlighting.enable = true;

    # GPG Agent
    services.gpg-agent.enable = true;
    services.gpg-agent.maxCacheTtl = 86400;
    services.gpg-agent.pinentryFlavor = if config.jhome.gui.enable then "qt" else "curses";
    services.gpg-agent.extraConfig = "allow-preset-passphrase";
    # Spotifyd
    services.spotifyd.enable = true;
    services.spotifyd.settings.global.device_name = config.jhome.hostName;
    services.spotifyd.settings.global.device_type = "computer";
    services.spotifyd.settings.global.backend = "pulseaudio";
    services.spotifyd.settings.global.zeroconf_port = 2020;

    home.stateVersion = "22.11";

    # Extra packages
    home.packages = [
      pkgs.gopass
      pkgs.sshfs
      pkgs.gitoxide
      pkgs.xplr
    ] ++ lib.optional devcfg.rust.enable pkgs.rustup;

    # Extra variables
    home.sessionVariables.CARGO_HOME = "${config.xdg.dataHome}/cargo";
    home.sessionVariables.RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    home.sessionVariables.GOPATH = "${config.xdg.dataHome}/go";

    # Verbose Commands
    home.shellAliases.cp = "cp --verbose";
    home.shellAliases.ln = "ln --verbose";
    home.shellAliases.mv = "mv --verbose";
    home.shellAliases.mkdir = "mkdir --verbose";
    home.shellAliases.rename = "rename --verbose";
    # Add Color
    home.shellAliases.grep = "grep --color=auto";
    home.shellAliases.ip = "ip --color=auto";
    # Use exa/eza
    home.shellAliases.tree = "eza --tree";

    # XDG directories
    xdg.enable = true;
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;
  };
}
