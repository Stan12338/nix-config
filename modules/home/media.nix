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
      yt-dlp
    ];
    programs.mpv = {
      enable = true;

      config = {
        vo = "gpu-next";
        gpu-api = "vulkan";
        gpu-context = "waylandvk";

        video-sync = "display-resample";

        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        dscale = "mitchell";

        scale-antiring = 0.7;
        cscale-antiring = 0.7;

        deband = "yes";
        deband-iterations = 4;
        deband-threshold = 35;
        deband-range = 16;

        interpolation = "yes";
        tscale = "oversample";

        tone-mapping = "bt.2446a";
        hdr-compute-peak = "yes";

        dither-depth = "auto";

        hwdec = "auto-safe";

        profile = "high-quality";
        alang = "eng,en";
        slang = "eng,en";
      };

    };
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
