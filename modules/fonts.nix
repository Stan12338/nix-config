{ config, pkgs, inputs, lib, ... }:

{
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
