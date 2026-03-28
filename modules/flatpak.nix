{ config, pkgs, inputs, lib, ... }:

{
  options = {
    flatpakPackages.enable = lib.mkEnableOption "enables flatpak packages";
  };

  config = lib.mkIf config.flatpakPackages.enable {
    services.flatpak.enable = true;
    services.flatpak.update.onActivation = true;
    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    services.flatpak.packages = [
      "org.vinegarhq.Sober"
      "com.github.tchx84.Flatseal"
    ];
  };
}
