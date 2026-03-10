{config, pkgs, inputs, lib,  ...}:

{
  options = {
    productivity.enable = lib.mkEnableOption "enables productivity configs and packages";
  };

  config = lib.mkIf config.productivity.enable {
    home.packages = with pkgs; [
      blender
    ];
  };


}
