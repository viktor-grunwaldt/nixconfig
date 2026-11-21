# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  #   jq '
  #   del(.smbios, .swap)
  #   | .hardware |= with_entries(
  #       if (.value | type) == "array" then
  #         .value |= map(
  #           del(
  #             .serial,
  #             .sysfs_id,
  #             .sysfs_bus_id,
  #             .sysfs_device_link,
  #             .udi,
  #             .parent_udi,
  #             .usb_guid,
  #             .resources
  #           )
  #           | if has("unix_device_names") then
  #               .unix_device_names |= map(
  #                 select(
  #                   (contains("/by-id/") or contains("/by-uuid/")) | not
  #                 )
  #               )
  #             else .
  #             end
  #         )
  #       else .
  #       end
  #     )
  # ' blackbox/facter.json > blackbox/facter-public.json
  hardware.facter.reportPath = ./facter.json;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];
  nix.settings.auto-optimise-store = true;
  # pin nix registry to flake's nixpkgs version (nix shell doesn't have to pull every time)
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
  };
  security.sudo.enable = false;
  security.sudo-rs.enable = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # grub.enable = true;
    # grub.efiSupport = true;
    # grub.device = "nodev";
  };

  networking.hostName = "blackbox"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };
  fonts.packages = [ pkgs.nerd-fonts.hack ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # https://discourse.nixos.org/t/how-to-remove-speech-dispatcher
  services.speechd.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "video"
      "networkmanager"
      "audio"
      "lp" # bluetooth?
      "podman" # for arion/docker-compose
    ];
    packages = with pkgs; [
      git
      curl
      helix
      ripgrep
      fzf
    ];
    initialHashedPassword = "$y$j9T$AKGO/Q.MSASQc5jXZjKQ31$3NEhUjQ.Q/GGohZFSkKwDjdc.Y.ZEAF.q/LypsvAma/";
  };

  programs.steam.enable = true;

  programs.niri.enable = true;
  # select niri from nixpkgs instead of the flake
  programs.niri.package = pkgs.niri;
  niri-flake.cache.enable = false;
  systemd.user.services.niri-flake-polkit.enable = false; # see polkit note below

  services.displayManager.ly.enable = true; # or skip it and run `niri-session` from a TTY
  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    curl
    inetutils
    man-pages
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # modify the output of build-vm
  # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 6;
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?

}
