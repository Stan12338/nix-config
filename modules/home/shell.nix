{config, pkgs, inputs, lib,  ...}:

{

  options = {
    shell.enable = lib.mkEnableOption "enables shell/terminal configs and packages";
  };

  config = lib.mkIf config.shell.enable {
    programs.starship = {
        enable = true;

        settings = {
            format = "[ ](bold blue)$all";
            add_newline = false;
            aws.disabled = true;
            gcloud.disabled = true;
            line_break.disabled = true;
            character = {
              success_symbol = "[](bold blue) ";
              error_symbol = "[✗](bold red) ";
            };
            directory = {
              home_symbol = " ~ ";
              style = "blue";
              truncation_length = 3;
              truncate_to_repo = false;
            };
        };
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        nrs = "sudo nixos-rebuild switch --flake ~/nixos#stan-pc --show-trace";

        editconfig = "sudo nvim /etc/nixos/configuration.nix";
        edithome = "sudo nvim /etc/nixos/home.nix";
        editflake = "sudo nvim /etc/nixos/flake.nix";
        search = "nix search nixpkgs";
        cmatrix = "cmatrix -C blue";
  ff = "fastfetch";
      };
      history.size = 10000;
      history.ignoreAllDups = true;
      history.path = "$HOME/.zsh_history";
      history.ignorePatterns = ["rm *" "pkill *" "cp *"];
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };
    };
    home.packages = with pkgs; [
      ani-cli
      inxi
      ripgrep
      fd
      unzip
    ];
  };


}
