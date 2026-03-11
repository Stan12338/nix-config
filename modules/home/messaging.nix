{config, pkgs, inputs, lib,  ...}:

{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  options = {
    messaging.enable = lib.mkEnableOption "enables messaging configs and packages";
  };

  config = lib.mkIf config.messaging.enable {
    home.packages = with pkgs; [
      zapzap
      kdePackages.kdeconnect-kde
      localsend
    ];
    programs.nixcord = {
      enable = true;
      vesktop.enable = true;

      config = {
        frameless = true;

        plugins = {
          # hideAttachments.enable = true;
        };
      };
    };
  };




}
