# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./../../modules/base.nix
    ./../../modules/fonts.nix
    ./../../modules/coding.nix
    ./../../modules/nvidia.nix
    ./../../modules/ricing.nix
    ./../../modules/misc.nix
    ./../../modules/flatpak.nix
  ];

  networking.hostName = "stan-pc";
  base.enable = true;
  nvidia.enable = true;
  coding.enable = true;
  ricing.enable = true;
  misc.enable = true;
  flatpak = {
    enable = true;
    gaming.enable = true;
  };

  users.users.stan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "25.11";


}
