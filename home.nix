{ config, pkgs, inputs, lib, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  nix-editor = builtins.getFlake "github:snowfallorg/nix-editor";
in
{
  home.username = "jp3";
  home.homeDirectory = "/home/jp3";

  # Screensharing
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };


  services.mpris-proxy.enable = true; 


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


  home.pointerCursor = {
	enable = true;
	name = "DMZ-Black";
	package = pkgs.vanilla-dmz;
	size = 32;
	gtk.enable = true;
  };

  services.ssh-agent.enable = true;

  programs.fish = {
      enable = true;
      shellAliases = {
      };
      interactiveShellInit = ''
        set -g fish_greeting
        ssh-add -q ~/.ssh/sshkey

        function rebuild 
          sudo git -C /etc/nixos/ add . 
          git -C /etc/nixos/ commit -m "$(date)" 

          tig -C /etc/nixos/ show
          if read -l -P "Continue with rebuild? [y/N] " confirm; and not test "$confirm" = "n" -o "$confirm" = "N"
            sudo NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1 NIXPKGS_ALLOW_UNFREE='1' nixos-rebuild switch --flake /etc/nixos/ --impure
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
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
  xdg.configFile."hyprland-preview-share-picker/style.css".source = ./hyprland-preview-share-picker/style.css;
  xdg.configFile."hyprland-preview-share-picker/config.yaml".source = ./hyprland-preview-share-picker/config.yaml;
  xdg.configFile."hypr/xdph.conf".source = ./hypr/xdph.conf;

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
    noto-fonts-cjk-sans
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
    aonsoku
    vanilla-dmz
    mangohud
    furmark
    obs-studio
    hyprpaper
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    localsend
    jetbrains.idea
    openjdk25
    devenv
    flatpak
    zoom-us
    unzip
    glib
    protontricks
    playerctl
    kdePackages.dolphin
    dmidecode
    celluloid
    macchanger
    pnpm
    nodejs
    libglvnd
  ];

programs.hyprlock = {
  enable = true;
  settings = {
    general = {
      disable_loading_bar = true;
      hide_cursor = true;
    };

    background = [
      {
        path = "screenshot";
        blur_passes = 2;
        blur_size = 7;
      }
    ];

    label = [
      {
        text = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
        color = "rgba(255, 255, 255, 1)";
        font_size = 90;
        font_family = "JetBrainsMono Nerd Font";
        position = "0, 0";
        halign = "right";
        valign = "top";
      }
      {
        text = "cmd[update:1000] echo \"$(date +'%A, %B %d')\"";
        color = "rgba(255, 255, 255, 0.8)";
        font_size = 24;
        font_family = "JetBrainsMono Nerd Font";
        position = "0, -150";
        halign = "right";
        valign = "top";
      }
    ];

    input-field = [
      {
        size = "1000, 100";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = true;
        font_color = "rgb(255, 255, 255)";
        inner_color = "rgba(91, 96, 120, 0)";
        outer_color = "rgba(24, 25, 38, 0)";
        outline_thickness = 0;
        placeholder_text = "";
        shadow_passes = 2;
      }
    ];
  };
};

services.hypridle = {
  enable = true;
  settings = {
    general = {
      lock_cmd = "pidof hyprlock || hyprlock";
      before_sleep_cmd = "loginctl lock-session";
      after_sleep_cmd = "hyprctl dispatch dpms on";
    };

    listener = [
      {
        timeout = 300;
        on-timeout = "loginctl lock-session";
      }
      {
        timeout = 330;
        on-timeout = "hyprctl dispatch dpms off";
        on-resume = "hyprctl dispatch dpms on";
      }
    ];
  };
};

xdg.mimeApps = {
  enable = true;
  defaultApplications = {
    "inode/directory" = [ "org.kde.dolphin.desktop" ];
  };
};



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
     LD_LIBRARY_PATH = lib.makeLibraryPath [
        pkgs.libglvnd
        pkgs.pulseaudio
    ];
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
