{ config, pkgs, inputs, lib, ... }:

{
  options = {
    coding.enable = lib.mkEnableOption "enables coding packages";
  };

  config = lib.mkIf config.coding.enable {
    environment.systemPackages = with pkgs; [
      sassc
      nixfmt
      gcc
      clang

    ];
    # services.ollama = {
    #   enable = true;
    #   package = pkgs.ollama-cuda;
    # };


  };
}
