# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let 
  isUEFI = builtins.pathExists "/sys/firmware/efi/";
  vars = import ./vars.nix;
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.graphics = {
	enable = true;
	enable32Bit = true;
  };

  boot.kernelParams = [
    "pcie_aspm=off"
    "v4l2loopback"
  ];
   # Enable v4l2loopback kernel module
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="Virtual Cam" exclusive_caps=1
  '';

  # Required for OBS or user-space tools to manage the device
  security.polkit.enable = true;
  
  programs.xwayland.enable = true; 

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };


  hardware.nvidia.powerManagement.enable = false;

  programs.steam.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    powerManagement.finegrained = false;
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  }; 

  services.dbus.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader = if isUEFI then {	
  	systemd-boot.enable = true;
  	efi.canTouchEfiVariables = true;
  } else {  
	grub.enable = true;
  	grub.device = "/dev/sdb";
  };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = vars.hostname; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.

  hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/NewYork";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  xdg = {  
    portal = with pkgs;{
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
      config = {
        common.default = "*";
        hyprland = {
          default = [ "gtk" "hyprland" ];
        };
      };
    };
  };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  #   config = {
  #     common.default = [ "hyprland" ];
  #     hyprland.default = [ "hyprland" ];
  #   };
  # };
  # xdg.portal = {
  #   # enable = true;
  #   # config = {common = {default = "wlr";};};
  #   # wlr.enable = true;
  #   wlr.settings.screencast = {
  #     chooser_type = "simple";
  #     chooser_cmd = "slurp -f %o -or";#"${pkgs.slurp}/bin/slurp -f %o -or";
  #   };
  #   # extraPortals = [
  #   #     pkgs.xdg-desktop-portal-gtk # gtk portal needed to make gtk apps happy
  #   # ];


  #   enable = true;
  #   xdgOpenUsePortal = true;
  #   config = {
  #     common.default = ["gtk"];
  #     hyprland.default = ["gtk" "hyprland"];
  #   };
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-hyprland
  #   ];
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.openssh.enable = true;  

  # Enable sound.
  #services.pipewire = {
  #  enable = true;
  #  pulse.enable = true;
  #};
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;  



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jp3 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
        tree
	      home-manager
    ];
  };

  programs.fish.enable = true;

  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim 
    wget
    fish
    cron
    tailscale
    slurp
    waybar
    inputs.hyprland-preview-share-picker.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
#  systemd.services.hid-apple-fnmode = {
#    wantedBy = [ "multi-user.target" ];
#    description = "set hid_apple fnmode";
#    serviceConfig = {
#        Type = "oneshot";
# 	      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 2 > /sys/module/hid_apple/parameters/fnmode'";
#    };
#  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
  nix.settings.experimental-features = [
	"nix-command"
	"flakes"
  ];
  #boot.extraModprobeConfig = ''
  #   options hid_apple fnmde=2
  #'';
}

