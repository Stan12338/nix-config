{config, pkgs, inputs, lib,  ...}:

{
  options = {
    media.enable = lib.mkEnableOption "enables media configs and packages";
  };

  config = lib.mkIf config.media.enable {
    home.packages = with pkgs; [
      upscayl
      obs-studio
      vlc
      pavucontrol
    ];
    programs.spicetify =
      let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
      ];
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];

      theme = spicePkgs.themes.text;
  };
  };


}
