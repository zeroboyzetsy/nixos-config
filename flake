# /etc/nixos/flake.nix
{
  description = "NixOS Zenbook S16 UM5606WA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS-ядро и другие bleeding-edge пакеты
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Hardware-специфичные модули NixOS
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, chaotic, nixos-hardware, ... }:
  {
    nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        # Аппаратные модули nixos-hardware для AMD ноутбука
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        # chaotic-nyx overlay (для CachyOS-ядра)
        chaotic.nixosModules.default

        ./configuration.nix

        # Home Manager как NixOS-модуль
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ВАШ_ЛОГИН = import ./home.nix;  # ← замени
        }
      ];

      specialArgs = { inherit nixpkgs; };
    };
  };
}
