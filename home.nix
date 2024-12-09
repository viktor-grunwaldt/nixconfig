{
  lib,
  pkgs,
  ...
}:

let
  inputConf = builtins.readFile ./mpv/input.conf;
  waybarCSS = builtins.readFile ./waybar/style.css;
  zathurarc = builtins.readFile ./zathura/zathurarc;
  wallpaper = {
    external = ./cat.svg;
    default = ./aleksey-lopatin-manga-FHD.png;
  };
  # strips end-of-line "//" comments from multiline strings
  jsonFromJsonc =
    s:
    lib.pipe s [
      (builtins.split "\/\/[^\"\n]*\n")
      (builtins.filter builtins.isString)
      (builtins.concatStringsSep "")
    ];
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "vi";
  home.homeDirectory = "/home/vi";

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
  nixpkgs.config = {
    allowUnfreePredicate = _: true;
    allowUnfree = true;
  };
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
      catppuccin.enable = true;
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
      settings = builtins.fromJSON (jsonFromJsonc (builtins.readFile ./fastfetch/config.jsonc));
    };
    waybar = {
      enable = true;
      # catppuccin.enable = true;
      systemd.enable = true;
      style = waybarCSS;
      settings = [
        {
          "layer" = "top";
          "position" = "bottom";
          modules-left = [
            "sway/workspaces"
            "sway/window"
            "sway/mode"
          ];
          modules-center = [ "" ];
          modules-right = [
            "tray"
            "network"
            "wireplumber"
            "cpu"
            "memory"
            "battery"
            "clock#date"
            "clock#time"
          ];
          "network" = {
            "format-wifi" = "  {essid} ({signalStrength}%)";
            "format-ethernet" = "{ifname}";
            "format-disconnected" = " ";
            "max-length" = 50;
            "on-click" = "exec alacritty -e nmtui";
          };
          "cpu" = {
            "format" = " {usage}%";
            "tooltip" = false;
            "interval" = 1;
          };
          "memory" = {
            "format" = " {}%";
          };
          "battery" = {
            "format" = "{icon} {capacity}%";
            "format-icons" = {
              "default" = [
                "󰂎"
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
              "charging" = [
                "󰢜"
                "󰂇"
                "󰢝"
                "󰢞"
                "󰂅"
              ];
            };
            "states" = {
              "warning" = 20;
              "critical" = 10;
            };
          };
          "clock#date" = {
            "format" = "{:%d.%m}";
          };
          "clock#time" = {
            "format" = "{:%H:%M}";
          };
          "wireplumber" = {
            "format" = "{icon} {volume}%";
            "format-bluetooth" = "{icon} {volume}% {format_source}";
            "format-bluetooth-muted" = "󰝟 {icon} {format_source}";
            "format-muted" = "󰝟";
            "format-icons" = {
              "headphone" = "";
              "hands-free" = "";
              "headset" = "󰋎";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [
                ""
                "󰖀"
                "󰕾"
              ];
            };
            "on-click-right" = "pavucontrol";
            "on-click" = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          };
        }
      ];
    };

    tmux = {
      enable = true;
      catppuccin.enable = true;
    };
    eza = {
      enable = true;
    };
    btop = {
      enable = true;
      catppuccin.enable = true;
    };
    bat = {
      enable = true;
      catppuccin.enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true; # enabled by default???
      config = {
        global.warn_timeout = "0";
      };
    };
    mpv = {
      enable = true;
      # Use the contents of your mpv.conf file
      config = {
        geometry = "50%:50%";
        alang = "ja,jp,jpn,en,eng,de,deu,ger";
        slang = "en,eng,pl,pol";
        autofit-larger = "80%x80%";

        # save-position-on-quit
        no-border = true;
        msg-module = true;
        msg-color = true;
        term-osd-bar = true;
        use-filedir-conf = true;
        # pause
        keep-open = true;
        # autofit-larger = "100%x95%";
        cursor-autohide-fs-only = true;
        cursor-autohide = 1000;

        screenshot-format = "png";
        screenshot-png-compression = 8;
        screenshot-template = "~/Pictures/mpv/%F (%P) %n";

        hls-bitrate = "max";
        ytdl-format = "bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9][protocol!=http_dash_segments]+bestaudio/best";

        # Cache settings
        cache = true;
        # cache-default = 5000000;
        # cache-backbuffer = 25000;
        # cache-initial = 0;
        # cache-secs = 10;

        # OSD / OSC settings
        osd-level = 1;
        osd-duration = 2000;
        osd-status-msg = "$\\{time-pos} / $\\{duration}$\\{?percent-pos:　($\\{percent-pos}%)}$\\{?frame-drop-count:$\\{!frame-drop-count==0:　Dropped: $\\{frame-drop-count}}}\\n$\\{?chapter:Chapter: $\\{chapter}}";

        osd-font = "Hack";
        osd-font-size = 32;
        osd-color = "#CCFFFFFF";
        osd-border-color = "#DD322640";
        # osd-shadow-offset = 1;
        osd-bar-align-y = 1;
        osd-border-size = 2;
        osd-bar-h = 2;
        osd-bar-w = 60;

        # Profile-specific settings
        # TODO: figure out how profiles work
        # profiles = {
        #   "profile:extension.gif" = {
        #     "cache" = false;
        #     "no-pause" = true;
        #     "loop-file" = true;
        #   };

        #   "profile:extension.webm" = {
        #     # Uncomment the lines if needed
        #     # "cache" = false;
        #     # "no-pause" = true;
        #     # "loop-file" = true;
        #   };
        # };

        # Subtitle settings
        sub-ass-vsfilter-blur-compat = true;
        sub-fix-timing = true;
        sub-auto = "fuzzy";
        sub-font = "Andika New Basic Bold";
        sub-font-size = 52;
        sub-blur = 0.2;
        sub-border-color = "0.0/0.0/0.0/1.0";
        sub-border-size = 3.0;
        sub-color = "1.0/1.0/1.0/1.0";
        sub-margin-x = 100;
        sub-margin-y = 10;
        sub-shadow-color = "0.0/0.0/0.0/0.25";
        sub-shadow-offset = 0;

        # Debanding settings
        deband = true;
        deband-iterations = 4;
        deband-threshold = 48;
        deband-range = 16;
        deband-grain = 48;
      };
      # Use the contents of your input.conf file
      extraInput = inputConf;
    };
    # Don't forget to fetch grammars!
    helix = {
      enable = true;
      catppuccin.enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        nixd
        # nixfmt is in the process of being adopted by the NixOS org
        # see https://github.com/NixOS/nixfmt/issues/153
        nixfmt-rfc-style
      ];
      settings = {
        editor = {
          line-number = "relative";
          color-modes = true;
          bufferline = "multiple";
          lsp.display-inlay-hints = true;
          cursor-shape.insert = "bar";
        };
        keys.insert = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
        };
        keys.normal = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
          p = "paste_before";
          P = "paste_after";
        };
      };
      languages = {
        language = [
          {
            name = "python";
            auto-format = true;
            language-servers = [ "pyright" "ruff" ];
          }
          {
            name = "nix";
            formatter.command = "nixfmt";
            language-servers = [ "nixd" ];
          }
          {
            name = "ocaml";
            formatter = {
              command = "ocamlformat";
              args = [
                "-"
                "--impl"
              ];
            };
          }
        ];
        language-server = {
          pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
            config.python.analysis.typeCheckingMode = "basic";
          };
          ruff = {
            command = "ruff";
            args = ["server"];
          };
          nixd = {
            command = "nixd";
          };
        };
      };
    };
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
      catppuccin.enable = true;
      # interactiveShellInit = ''
      #   set fish_greeting # Disable greeting
      # '';
      functions = {
        fish_greeting = "${pkgs.fortune-kind}/bin/fortune";
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
        x = "sxiv -ft *";
        py = "python";
        pytohn = "python";
        nix-rebuild = "sudo nixos-rebuild --flake ~/.config/nixconfig#default --show-trace --print-build-logs --verbose switch";
      };
    };
  };
  services = {
    mako = {
      enable = true;
      catppuccin.enable = true;
      defaultTimeout = 3000;
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    catppuccin.enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      defaultWorkspace = "workspace 1";
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
        DP-1.bg = "${wallpaper.external} fill";
        eDP-1.bg = "${wallpaper.default} fill";
      };
      assigns = {
        "workspace 1" = [ { app_id = "firefox"; } ];
        "workspace 4" = [ { class = "vesktop"; } ];
        "workspace 5" = [ { app_id = "org.keepassxc.KeePassXC"; } ];
      };
      window.titlebar = false;
      bars = [ ];
      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
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

  # Theme
  catppuccin.flavor = "mocha";
  catppuccin.pointerCursor = {
    accent = "light";
    enable = true;
  };
  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
      icon.enable = true;
    };
  };
  qt = {
    enable = true;
    style = {
      name = "kvantum";
      catppuccin.enable = true;
      catppuccin.apply = true;
    };
    platformTheme.name = "kvantum";
  };

  xdg.configFile =
    # Copy over my fish functions that aren't managed by Nix
    with builtins;
    foldl' (
      acc: path:
      acc
      // {
        "fish/functions/${baseNameOf path}".text = readFile path;
      }
    ) { } (with lib.fileset; toList (fileFilter (file: file.hasExt "fish") ./fish/functions))
    # Add VS Code electron flags
    # EDIT: prefer to use env variable ELECTRON_OZONE_PLATFORM_HINT
    # // {
    #   "code-flags.conf".text = ''
    #     --enable-features=WaylandWindowDecorations
    #     --ozone-platform-hint=auto
    #   '';
    # }
    # Add Vesktop electron flags (Discord client)
    // {
      # electron bug: https://issues.chromium.org/issues/331796411#comment18
      # try to remove workaround when electron 34 is shipped
      "vesktop-flags.conf".text = ''
        --disable-gpu-memory-buffer-video-frames
      '';
    };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
