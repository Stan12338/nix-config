{config, pkgs, inputs, lib,  ...}:

{

  options = {
    ricing.enable = lib.mkEnableOption "enables ricing configs and packages";
  };

  config = lib.mkIf config.ricing.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = false;
    };

    home.packages = with pkgs; [
      gnome-themes-extra
      adwaita-icon-theme
      nwg-look
      nwg-displays
      nitch
      cloc
      cowsay
    ];
  };



}
