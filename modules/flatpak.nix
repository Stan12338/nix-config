{ config, pkgs, inputs, lib, ... }:

{
  options = {
    flatpak.enable = lib.mkEnableOption "enables flatpak packages";
    gaming.enable = lib.mkEnableOption "enable gaming flatpaks";
  };

  config = lib.mkMerge [
      (lib.mkIf config.flatpak.enable {
        services.flatpak.enable = true;
      })

      (lib.mkIf config.flatpak.gaming.enable {
        services.flatpak.packages = [
          "org.vinegarhq.Sober"
        ];
      })
    ];
}
