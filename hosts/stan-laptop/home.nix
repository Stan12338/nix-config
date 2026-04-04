{config, pkgs, inputs, lib,  ...}:

{
  imports = [
    ./../../users/stan/default.nix
  ];

  dotfiles.laptop.enable = true;
}
