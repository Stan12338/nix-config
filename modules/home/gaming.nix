{config, pkgs, inputs, lib,  ...}:

{
  options = {
    gaming.enable = lib.mkEnableOption "enables gaming configs and packages";
  };

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      steam
      protonup-qt
      modrinth-app
    ];
  };
}
