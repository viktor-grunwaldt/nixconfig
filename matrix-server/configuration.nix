{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./matrix.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-matrix";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  users.users.vi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  services.openssh.enable = true;
  services.nginx.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "v.gruenwaldt@protonmail.com";
  };

  environment.systemPackages = with pkgs; [
    helix
    git
  ];

  system.stateVersion = "25.11";
}
