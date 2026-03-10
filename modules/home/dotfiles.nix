{config, pkgs, inputs, lib,  ...}:

{
  imports = [
  ];

  options = {
    dotfiles.enable = lib.mkEnableOption "symlinks dotfiles";
  };

  config = lib.mkIf config.dotfiles.enable {
    xdg.configFile."quickshell/default".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/quickshell/default";
    xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/niri";
    xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/hypr";
    xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/ghostty";
    xdg.configFile."fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/fastfetch";
    xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/matugen";
    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/nvim";
    xdg.configFile."gtk-3.0".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/gtk-3.0";
    xdg.configFile."gtk-4.0".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/gtk-4.0";
    xdg.configFile."vesktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/vesktop";
    xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/rofi";
    xdg.configFile."cava".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/cava";
    xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/kitty";
    xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/zed";


  };



}
