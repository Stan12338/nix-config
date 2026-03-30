{config, pkgs, inputs, lib,  ...}:

{
  imports = [
    ./../../users/stan/default.nix
  ];
  dotfiles.fakedows.enable = true;

}
