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
    # "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    # ./disko.nix
  ];
  # ./swiv.nix # todo: figure out how to include it
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # grub.enable = true;
    # grub.efiSupport = true;
    # grub.device = "nodev";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # bluetooth pairing thingy
  services.blueman.enable = true;

  # thunar helpers
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # https://nixos.wiki/wiki/Btrfs#Scrubbing
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Enable polkit for sway
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function (action, subject) {
        if (
          subject.isInGroup("users") &&
          [
            "org.freedesktop.login1.reboot",
            "org.freedesktop.login1.reboot-multiple-sessions",
            "org.freedesktop.login1.power-off",
            "org.freedesktop.login1.power-off-multiple-sessions",
          ].indexOf(action.id) !== -1
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];
  systemd = {
    # start gnome authentication agent for thunar
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    # https://github.com/NixOS/nixpkgs/pull/96766
    # Instead of cleaning on boot, by default it cleans up files >10d
    # So, I've set it to 3d
    tmpfiles.rules = [
      "q /tmp 1777 root root 3d"
      "q /var/tmp 1777 root root 30d"
    ];
  };
  # zramSwap = {
  #   enable = true;
  #   memoryPercent = 25;
  # };
  #  swapDevices = [ {
  #   device = "/var/lib/swapfile";
  #   size = 2*1024;
  # } ];
  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable support for bluetooth.
  hardware.bluetooth.enable = true;
  # Powers up the default Bluetooth controller on boot.
  # hardware.bluetooth.powerOnBoot = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "lp" # bluetooth?
      "podman" # for arion/docker-compose
      # "docker" # eqv to root, read more about rootless docker
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      dconf
    ];
    initialHashedPassword = "$y$j9T$AKGO/Q.MSASQc5jXZjKQ31$3NEhUjQ.Q/GGohZFSkKwDjdc.Y.ZEAF.q/LypsvAma/";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ntfs3g
    polkit_gnome
    man-pages
    nixos-rebuild-ng
  ];
  # environment.binsh = ''
  #   ${pkgs.dash}/bin/dash
  # '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # laptop brightness controll, see https://nixos.wiki/wiki/Backlight
  programs.light.enable = true;
  # imperative warning! I've created keys with `ssh-keygen`
  programs.ssh = {
    startAgent = true;
  };
  # Launch fish unless parent is already fish
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      xfce.thunar-volman
    ];
  };

  # programs.steam.enable = true;
  programs.fish.enable = true;
  # programs.sway.enable = true;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable greeter daemon to launch sway
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'systemd-cat -t sway sway'";
        user = "vi";
      };
    };
  };

  # If you are using a wlroots-based compositor, like sway, and want to be able to share your
  # screen, you might want to activate this option:
  xdg.portal.wlr.enable = true;

  # If you simply want to keep the behaviour in < 1.17, which uses the first
  # portal implementation found in lexicographical order, use the following:
  xdg.portal.config.common.default = "*";

  # Thermald proactively prevents overheating on Intel CPUs and works well with other tools.
  services.thermald.enable = true;
  # tlp is used for saving laptop battery power
  services.tlp = {
    enable = true;
  };

  # wheeee FUCK M$
  # virtualisation.docker.enable = true;
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # Sieci komputerowe:
  virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableKvm = true;
  # virtualisation.virtualbox.host.addNetworkInterface = false;
  users.extraGroups.vboxusers.members = [ "vi" ];
  boot.extraModprobeConfig = "blacklist kvm_intel\nblacklist kvm";
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vi" ];
    ensureUsers = [
      {
        name = "vi";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };
  # modify the output of build-vm
  # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
    };
  };
  # see: https://github.com/viktor-grunwaldt/t480-fingerprint-nixos/blob/main/SETUP.md
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "libfprint-tod";
    calib-data-file = ./fprint/calib-data.bin;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
