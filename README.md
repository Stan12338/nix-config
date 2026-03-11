# My nix configs
i finally got around to actually modularising my nix config, i was just using the basic flake.nix configuration.nix and home.nix for so long and yeah pretty much that's it

## reproducing
first, clone the repo into your home directory
```
cd ~/
git clone https://github.com/Stan12338/nix-config.git nixos
```
then in your terminal run:

```
sudo nixos-rebuild switch --flake ~/nixos#your-hostname --show-trace
```

if you're not me you'll have to add your hostname to the flake and create your own folder inside hosts, the modules make this pretty easy to set up though.
Otherwise future me you can just reproduce with
```
sudo nixos-rebuild switch --flake ~/nixos#stan-pc --show-trace
```
or
```
sudo nixos-rebuild switch --flake ~/nixos#stan-laptop --show-trace
```
ofcourse this entire process only works on nixos
