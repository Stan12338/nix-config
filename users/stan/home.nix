{config, pkgs, inputs, lib,  ...}:

{
  imports = [
    ./default.nix
  ];

  dotfiles.fakedows.enable = true;
}
