{config, pkgs, inputs, lib,  ...}:

{

  options = {
    misc.enable = lib.mkEnableOption "enables misc configs and packages";
  };

  config = lib.mkIf config.misc.enable {
    home.packages = with pkgs; [
      grimblast
      slurp
      grim
      proton-vpn
      thunar
      brave
    ];
  };


}
