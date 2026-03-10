{ config, pkgs, inputs, lib, ... }:

{
  options = {
    nvidia.enable = lib.mkEnableOption "enables nvidia drives and tweaks";
  };

  config = lib.mkIf config.nvidia.enable {
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    hardware.graphics = {
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];

      extraPackages32 = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
    services.xserver.videoDrivers = ["nvidia"];
    environment.sessionVariables = {

      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
}
