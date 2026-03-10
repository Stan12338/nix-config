{ config, pkgs, inputs, lib, ... }:

{
  imports = [

  ];
  options = {
    ricing.enable = lib.mkEnableOption "enables ricing packages";
  };

  config = lib.mkIf config.ricing.enable {
    environment.systemPackages = with pkgs; [
      cmatrix
      cava
      pfetch
      rofi
      swww
      fastfetch
      tty-clock
      inputs.matugen.packages.${system}.default
      inputs.quickshell.packages.${pkgs.system}.default
      peaclock
    ];
  };


}
