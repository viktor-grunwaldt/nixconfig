{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          inputs.disko.nixosModules.disko
          ./disko.nix
          { _module.args.disks = [ "/dev/nvme0n1" ]; }
        ];
      };
    };
}
