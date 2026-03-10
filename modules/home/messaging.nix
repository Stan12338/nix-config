{config, pkgs, inputs, lib,  ...}:

{

  options = {
    messaging.enable = lib.mkEnableOption "enables messaging configs and packages";
  };

  config = lib.mkIf config.messaging.enable {
    home.packages = with pkgs; [
      zapzap
      kdePackages.kdeconnect-kde
      localsend
      vesktop
    ];
  };


}
