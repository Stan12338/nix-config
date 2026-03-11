{config, pkgs, inputs, lib,  ...}:

{
  imports = [

  ];
  options = {
    misc.enable = lib.mkEnableOption "enables misc packages";
  };

  config = lib.mkIf config.misc.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.kate
      btop
      htop
      gedit
      wl-clipboard
      cliphist
      papirus-icon-theme
      kdePackages.qt5compat
      kdePackages.qtmultimedia
      xwayland-satellite
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      wine
      winetricks
      gsettings-desktop-schemas
      glib
      sops
      age
    ];

  };





}
