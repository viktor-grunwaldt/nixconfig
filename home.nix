{
  lib,
  pkgs,
  ...
}:

let
  username = "vi";
  inputConf = builtins.readFile ./dotfiles/mpv/input.conf;
  waybarCSS = ./dotfiles/waybar/style.css;
  zathurarc = builtins.readFile ./dotfiles/zathura/zathurarc;
  wallpaper = {
    external = ./assets/cat.svg;
    default = ./assets/aleksey-lopatin-manga-FHD.png;
  };
  fastfetchConf =
    with builtins;
    lib.pipe ./dotfiles/fastfetch/config.jsonc [
      readFile
      # strips end-of-line "//" comments from multiline strings
      (split "\/\/[^\"\n]*\n")
      (filter isString)
      (concatStringsSep "")
      fromJSON
    ];
  my-projector-script-file = builtins.readFile ./assets/projector-toggle.sh;
  my-projector-script = pkgs.writeShellScriptBin "projector-toggle" my-projector-script-file;
  fish-functions =
    with builtins;
    with lib.fileset;
    foldl' (
      acc: path:
      acc
      // {
        "fish/functions/${baseNameOf path}".text = readFile path;
      }
    ) { } (toList (fileFilter (file: file.hasExt "fish") ./dotfiles/fish/functions));
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # Allow unfree for vscode ( in flake )
  # Allow unfree from commandline
  # nixpkgs.config = {
  #   allowUnfreePredicate = _: true;
  #   allowUnfree = true;
  # };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # required for sway
    wlroots
    wl-clipboard
    # autotiling-rs
    sway-contrib.grimshot
    wl-mirror

    keepassxc
    syncthing
    firefox
    vesktop
    transmission_4-gtk
    thunderbird
    swayimg
    imv
    pavucontrol

    tokei
    fd
    ripgrep
    python313Full
    unzip
    bashmount
    file
    xarchiver
    jq
    distrobox

    my-projector-script
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerd-fonts.override { fonts = [ "Hack" ]; })
    #
    # # XXX: Since 2024-11-09 this is no longer the way.The `nerdfonts` package has
    # # been split up into `nerd-fonts.<font>` packages
    # https://github.com/NixOS/nixpkgs/commit/de4dbc58fdeb84694d47d6c3f7b9f04a57cc4231
    #
    # # I'll try to fix it by 1. referencting relevant font package and 2. forcing font
    # # cache rebuild through `fc-cache -rv`
    # # UPDATE: cache rebuild wasn't necessary
    nerd-fonts.hack

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # ".ssh/allowed_signers".text = "* ${builtins.readFile "/home/vi/.ssh/id_ed25519.pub}"}";

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # fancy GHCI (haskell REPL) prompt
    ".ghci".text = ''
      :set prompt "\ESC[1;34m%s\n\ESC[0;35mλ> \ESC[m"
    '';
  };

  home.sessionVariables = {
    # EDITOR = "hx";
    NIXOS_OZONE_WL = "1";
    # suggests electron apps to use the default (wayland) backend
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/vi/etc/profile.d/hm-session-vars.sh
  #
  fonts.fontconfig.enable = true;

  programs = {
    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 14.0;
          normal.family = "Hack Nerd Font Mono";
          bold.family = "Hack Nerd Font Mono";
          italic.family = "Hack Nerd Font Mono";
          bold_italic.family = "Hack Nerd Font Mono";
        };
        window = {
          dynamic_title = true;
          opacity = 0.95;
          title = "Alacritty";
        };
      };
    };
    zathura = {
      enable = true;
      extraConfig = zathurarc;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    fastfetch = {
      enable = true;
      settings = fastfetchConf;
    };
    tmux = {
      enable = true;
    };
    eza = {
      enable = true;
    };
    btop = {
      enable = true;
    };
    bat = {
      enable = true;
      config = {
        plain = true;
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true; # enabled by default???
      config = {
        global.warn_timeout = "0";
      };
    };
    mpv = import ./dotfiles/mpv.nix pkgs inputConf;
    helix = import ./dotfiles/helix.nix pkgs;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    git = {
      enable = true;
      userName = "Viktor Grunwaldt";
      userEmail = "v.gruenwaldt@protonmail.com";
      extraConfig = {
        # Sign all commits using ssh key
        # for now, gpg is not set up, this will be uncommented once it works
        # commit.gpgsign = true;
        # gpg.format = "ssh";

        # user.signingkey = "/home/vi/.ssh/id_ed25519.pub}";
        merge.conflictstyle = "zdiff3";
        pull.ff = "only";
        init.defaultBranch = "master";
      };
    };
    fish = {
      enable = true;
      # interactiveShellInit = ''
      #   set fish_greeting # Disable greeting
      # '';
      functions = {
        fish_greeting = "${pkgs.fortune}/bin/fortune";
        mvn-init = "set name $argv; mvn archetype:generate -DgroupId=pl.wroc.uni.$name -DartifactId=$name -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.5 -DinteractiveMode=false";
        backup-file = "cp -i $argv $argv.bak";
      };
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        # { name = "grc"; src = pkgs.fishPlugins.grc.src; }
        {
          name = "hydro";
          src = pkgs.fishPlugins.hydro.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        # Manually packaging and enable a plugin
        # {
        #   name = "z";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "jethrokuan";
        #     repo = "z";
        #     rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
        #     sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        #   };
        # }
      ];
      shellAbbrs = {
        gs = "git status";
        gcm = "git commit --message";
        gclp = "git clone (wl-paste)";
        gdh = "git diff HEAD";
        gdc = "git diff --cached";
        ga = "git add";
        gaa = "git add --all .";
        gb = "git branch";
        gp = "git push";
        gpu = "git pull";
        gco = "git checkout";
        gl = "git log --pretty=format:\"%Cgreen%h%Creset - %Cblue%an%Creset @ %ar : %s\"";
        gl2 = "git log --pretty='format:%Cgreen%h%Creset %an - %s' --graph";
        glv = "git log --stat";
        tree = "eza --tree";
        du-sort = "du -xhla --max-depth 1 | sort -rh";
        z = "zathura --fork *.pdf";
        ff = "firefox";
        py = "python";
        pytohn = "python";
        nix-rebuild = "sudo nixos-rebuild-ng --flake ~/.config/nixconfig#default --show-trace --print-build-logs --verbose switch";
      };
      shellAliases = {
        mv = "mv -i";
      };
    };
  };

  services.mako = {
    enable = true;
    defaultTimeout = 3000;
  };
  programs.waybar = import ./dotfiles/waybar.nix waybarCSS;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      defaultWorkspace = "workspace number 1";
      fonts = {
        names = [ "Hack" ];
        size = 13.0;
      };
      input = {
        "*" = {
          accel_profile = "flat";
        };
        "type:keyboard" = {
          xkb_layout = "pl,de";
          xkb_options = "grp:win_space_toggle";
        };
        "2:10:TPPS/2_IBM_TrackPoint" = {
          accel_profile = "adaptive";
        };
        "1739:0:Synaptics_TM3276-022" = {
          accel_profile = "adaptive";
        };
      };
      output = {
        DP-1 = {
          bg = "${wallpaper.external} fill";
          position = "1920,0";
        };
        eDP-1 = {
          bg = "${wallpaper.default} fill";
          position = "0,0";
        };
      };
      assigns = {
        "workspace 1" = [ { app_id = "firefox"; } ];
        "workspace 4" = [ { class = "vesktop"; } ];
        "workspace 5" = [ { app_id = "org.keepassxc.KeePassXC"; } ];
      };
      window.titlebar = false;
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
      startup = [
        {
          command = "keepassxc";
        }
        # doesn't work
        # { command = "autotiling-rs"; always = true; }
      ];
      keybindings =
        with pkgs;
        lib.mkOptionDefault {
          # audio stuff
          "XF86AudioRaiseVolume" = "exec ${wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          "XF86AudioLowerVolume" = "exec ${wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          "XF86AudioMute" = "exec ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          # brightness stuff
          "XF86MonBrightnessUp" = "exec ${light}/bin/light -T 1.19 ";
          "XF86MonBrightnessDown" = "exec ${light}/bin/light -T 0.84";
          # screenshot stuff
          "Print" = "exec ${sway-contrib.grimshot}/bin/grimshot copy screen";
          "Print+alt" = "exec ${sway-contrib.grimshot}/bin/grimshot save screen";
          "Shift+Print" = "exec ${sway-contrib.grimshot}/bin/grimshot copy area";
          # programs stuff
          "${modifier}+f" = "exec ${firefox}/bin/firefox";
          "${modifier}+t" = "exec ${xfce.thunar}/bin/thunar";
          "${modifier}+Shift+f" = "fullscreen";
          # exit stuff
          "${modifier}+Shift+e" = "exec ${wlogout}/bin/wlogout";
        };
    };
  };
  /*
    evaluation warning: vi profile: `gtk.catppuccin.enable` and `gtk.catppuccin.gnomeShellTheme` are deprecated and will be removed in a future release.

                    The upstream port has been archived and support will no longer be provided.
                    Please see https://github.com/catppuccin/gtk/issues/262
  */
  # Theme
  catppuccin = {
    flavor = "mocha";
    cursors = {
      accent = "light";
      enable = true;
    };
    alacritty.enable = true;
    bat.enable = true;
    btop.enable = true;
    fish.enable = true;
    helix.enable = true;
    tmux.enable = true;

    sway.enable = true;
    mako.enable = true;
    kvantum.enable = true;
    kvantum.apply = true;
    gtk = {
      enable = true;
      icon.enable = true;
    };
  };
  gtk = {
    enable = true;
  };
  qt = {
    enable = true;
    style = {
      name = "kvantum";
    };
    platformTheme.name = "kvantum";
  };

  xdg.configFile =
    # Copy over my fish functions that aren't managed by Nix
    fish-functions;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
