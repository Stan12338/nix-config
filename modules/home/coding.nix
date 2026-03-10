{config, pkgs, inputs, lib,  ...}:

{
  imports = [
  ];

  options = {
    coding.enable = lib.mkEnableOption "enables coding packages and configs";
  };

  config = lib.mkIf config.coding.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = false;
    };

    home.packages = with pkgs; [
      vscode
      rustc
      cargo
      rustfmt
      zed-editor
      gnumake
      gcc
      tree-sitter
      nodejs
      python3
      python3Packages.pynvim
      lua-language-server
      claude-code
    ];
    programs.git = {
      enable = true;
      settings.user.name = "Stanley Morrish";
      settings.user.email = "notstanssecondacc@gmail.com";
    };


  };



}
