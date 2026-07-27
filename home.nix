{ config, pkgs, inputs, ... }:

let
  nix-editor = builtins.getFlake "github:snowfallorg/nix-editor";
in
{
  home.username = "jp3";
  home.homeDirectory = "/home/jp3";

  #screen sharing
  xdg.portal = {
    enable = true;
    # config.common.default = "wlr";
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      sway = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
      };
    };
  };

  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";

      control-center-width = 500;
      notification-window-width = 400;

      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
    };
  };

  services.ssh-agent.enable = true;

  programs.fish = {
      enable = true;
      shellAliases = {
      };
      interactiveShellInit = ''
        set -g fish_greeting
        ssh-add -q ~/.ssh/id_ed25519.pub

        function rebuild 
          sudo git -C /etc/nixos/ add . 
          git -C /etc/nixos/ commit -m "$(date)" 

          tig -C /etc/nixos/ show
          if read -l -P "Continue with rebuild? [y/N] " confirm; and not test "$confirm" = "n" -o "$confirm" = "N"
            sudo NIXPKGS_ALLOW_UNFREE='1' nixos-rebuild switch --flake /etc/nixos/ --impure
            and git -C /etc/nixos/ push -u origin master > /dev/null 2>&1 &
            disown
          end
        end

        function add
          if test -z "$argv[1]"
            echo "Usage: add <package>"
            return 1
          end

          sudo nix-editor -i -a "$argv[1]" /etc/nixos/home.nix home.packages
        end

        function search
            set pkg (nix-search-tv print | fzf --preview 'nix-search-tv preview {}' | awk '{print $2}')
            if test -z "$pkg"
                return 1
            end

            read -l -P "Install '$pkg'? [y/N] " confirm
            if not test "$confirm" = "n" -o "$confirm" = "N"
                add $pkg
                echo "Installed"
            else
                echo "Cancelled."
            end
        end

      '';
  };

  fonts.fontconfig.enable = true;

  xdg.configFile."sway/config".source = ./sway/config;
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;

  home.packages = with pkgs; [
    alacritty
    cage
    discord
    flameshot
    foot
    fuzzel
    fzf
    git
    grim
    htop
    hyprland
    hyprpicker
    jq
    rofi
    steam
    swayfx
    tela-icon-theme
    tldr
    tmux
    wdisplays
    vim
    firefox
    swayidle
    swayfx
    swaylock-effects
    nerd-fonts.dejavu-sans-mono
    easyeffects
    vscodium
    nix-search-tv
    inputs.nix-editor.packages.${pkgs.system}.default
    waybar
    swaynotificationcenter
    tig

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    
    #  Command line `add`s below, manual above
    ripgrep
    prismlauncher
    pavucontrol
    flameshot
    ksnip
    satty
    libnotify
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jp3/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
     EDITOR = "vim";
     NIXOS_OZONE_WL = "1";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

}
