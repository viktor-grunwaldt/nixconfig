{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    t480-fprint-sensor = {
      url = "github:viktor-grunwaldt/t480-fingerprint-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      catppuccin,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      checks.${system}.pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        package = pkgs.prek;
        hooks = {
          nixfmt.enable = true;
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        shellHook = ''
          ${inputs.self.checks.${system}.pre-commit-check.shellHook}
        '';
        nativeBuildinputs = [
          pkgs.nixfmt
        ];
      };
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./t480/configuration.nix
          disko.nixosModules.disko
          ./t480/disko.nix
          {
            _module.args.disks = [ "/dev/nvme0n1" ];
          }

          # catppuccin.nixosModules.catppuccin
          inputs.nix-index-database.nixosModules.default
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
          inputs.t480-fprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"

          # make home-manager as a module of nixos so that home-manager configuration
          # will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.vi.imports = [
              ./t480/home.nix
              catppuccin.homeModules.catppuccin
            ];
          }
        ];
      };
    };
}
