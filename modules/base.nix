{config, pkgs, inputs, lib, ...}:

{
  imports = [

  ];
  options = {
    base.enable = lib.mkEnableOption "enables base packages";
  };

  config = lib.mkIf config.base.enable {
    nix.settings.experimental-features = ["nix-command" "flakes" ];
    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      ghostty
      firefox
      fontconfig
      killall
      ntfs3g
      pkg-config
      brightnessctl
      ddcutil
      gtk3
      gtk4
      gnome-settings-daemon
      playerctl
      gvfs
      vulkan-tools
      vulkan-loader
      gnome-keyring
      xwayland
      inputs.zen-browser.packages.${pkgs.system}.default
      nemo-with-extensions
      xclip
      wtype
      libnotify

    ];
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    };
    programs.niri = { enable = true; }; xdg.menus.enable = true; xdg.portal = { enable = true; }; hardware.graphics = { enable = true; enable32Bit = true; }; programs.zsh.enable = true; users.defaultUserShell = pkgs.zsh; time.timeZone = "Australia/Brisbane"; networking.networkmanager.enable = true; boot.kernelPackages = pkgs.linuxPackages_latest; environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu"; security.polkit.enable = true; services.dbus.enable = true; boot.loader.systemd-boot.enable = true; boot.loader.efi.canTouchEfiVariables = true; nixpkgs.config.allowUnfree = true; hardware.bluetooth.enable = true;
    zramSwap.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";

    };

    services.xserver.xkb.layout = "us";
    services.xserver.xkb.options = "eurosign:e,caps:escape";

    programs.dconf.enable = true;

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.openssh.enable = true;

    networking.firewall.allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];

    networking.firewall.allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];


  };




}
