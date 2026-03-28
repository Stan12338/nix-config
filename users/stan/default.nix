{config, pkgs, inputs, lib,  ...}:

{
  home.username = "stan";
  home.homeDirectory = "/home/stan";
  home.stateVersion = "25.11";
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    ../../modules/home/base.nix
    ../../modules/home/coding.nix
    ../../modules/home/gaming.nix
    ../../modules/home/media.nix
    ../../modules/home/messaging.nix
    ../../modules/home/misc.nix
    ../../modules/home/productivity.nix
    ../../modules/home/ricing.nix
    ../../modules/home/cli.nix
    ../../modules/home/dotfiles.nix
  ];

  coding.enable = true;
  gaming.enable = true;
  media.enable = true;
  messaging.enable = true;
  misc.enable = true;
  productivity.enable = true;
  ricing.enable = true;
  cli.enable = true;
  dotfiles.enable = true;

  programs.home-manager.enable = true;
}
