{ config, pkgs, inputs, lib, ... }:
{
  imports = [ ];

  options.dotfiles = {
    enable = lib.mkEnableOption "symlinks dotfiles";
    fakedows.enable = lib.mkEnableOption "enable fake windows rice";
  };

  config = lib.mkIf config.dotfiles.enable (lib.mkMerge [
    {
      xdg.configFile."quickshell/default".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/quickshell/default");
      xdg.configFile."niri".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/niri");
      xdg.configFile."hypr".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/hypr");
      xdg.configFile."ghostty".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/ghostty");
      xdg.configFile."fastfetch".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/fastfetch");
      xdg.configFile."matugen".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/matugen");
      xdg.configFile."nvim".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/nvim");
      xdg.configFile."gtk-3.0".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/gtk-3.0");
      xdg.configFile."gtk-4.0".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/gtk-4.0");
      xdg.configFile."rofi".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/rofi");
      xdg.configFile."cava".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/cava");
      xdg.configFile."kitty".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/kitty");
      xdg.configFile."zed".source = lib.mkDefault
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/zed");c
    }
    (lib.mkIf config.dotfiles.fakedows.enable {
      xdg.configFile."niri".source = lib.mkForce
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/fakedows/niri");
      xdg.configFile."hypr".source = lib.mkForce
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/fakedows/hypr");
      xdg.configFile."quickshell/default".source = lib.mkForce
        (config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/dots/fakedows/quickshell/default");
    })
  ]);
}
