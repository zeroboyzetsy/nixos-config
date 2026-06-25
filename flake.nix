# flake.nix — входная точка конфигурации
# Хост: zenbook. Перед установкой замени CHANGEME_USER на свой логин.
{
  description = "NixOS · ASUS Zenbook S16 UM5606WA · Hyprland · CachyOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS-ядро и bleeding-edge пакеты
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, home-manager, chaotic, ... }: {
    nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # overlay chaotic-nyx (даёт pkgs.linuxPackages_cachyos)
        chaotic.nixosModules.default

        ./configuration.nix

        # Home Manager как NixOS-модуль (применяется одной командой с системой)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.CHANGEME_USER = import ./home.nix;
        }
      ];
    };
  };
}
