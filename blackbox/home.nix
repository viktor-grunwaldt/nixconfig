{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "vi";
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
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    wl-clipboard
    noctalia

    keepassxc
    syncthing
    firefox
    vesktop
    transmission_4-gtk
    thunderbird

    tokei
    fd
    ripgrep
    # python313
    unzip
    bashmount
    file
    xarchiver
    jq
    distrobox
    pstree
    fzf
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = { };

  # TODO: this is example niri setup
  # XXX: commented out: they conflict with noctalia
  # programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  # programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
  # services.mako.enable = true; # notification daemon
  # services.swayidle.enable = true; # idle management daemon
  # services.polkit-gnome.enable = true; # polkit

  xdg.configFile."noctalia/config.toml".text = ''
    [theme]
    mode = "dark"
  '';

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
        keyboard = {
          bindings = [
            {
              key = "Return";
              mods = "Control|Shift";
              action = "SpawnNewInstance";
            }
          ];
        };
      };
    };
    zathura = {
      enable = true;
      # TODO
      # extraConfig = zathurarc;
    };
    yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "yy";
    };
    fastfetch = {
      enable = true;
      # TODO
      # settings = fastfetchConf;
    };
    tmux = {
      enable = true;
    };
    eza = {
      enable = true;
    };
    btop = {
      enable = true;
      settings = {
        update_ms = 500;
      };
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
    # TODO: import config (maybe refactor those as modules?)
    mpv.enable = true;
    helix.enable = true;
    git = {
      enable = true;
      signing.format = null;
      settings = {
        user.name = "Viktor Grunwaldt";
        user.email = "v.gruenwaldt@protonmail.com";
        merge.conflictstyle = "zdiff3";
        pull.ff = "only";
        init.defaultBranch = "master";
      };
    };
    fish = {
      enable = true;
      functions = {
        fish_greeting = "${pkgs.fortune}/bin/fortune";
        rust-docs = ''open "$(rustc --print sysroot)/share/doc/rust/html/index.html"'';
      };
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        # { name = "grc"; src = pkgs.fishPlugins.grc.src; }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
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
        switch = "sudo nixos-rebuild --flake /home/vi/.config/nixconfig#blackbox --print-build-logs --verbose switch";
      };
      shellAliases = {
        mv = "mv -i";
      };
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.niri.package = pkgs.niri; # only used for build-time validation here

  programs.niri.settings =
    let
      noctalia =
        cmd:
        [
          "noctalia"
          "msg"
        ]
        ++ lib.splitString " " cmd;
    in
    {
      spawn-at-startup = [ { command = [ "noctalia" ]; } ];

      binds = with config.lib.niri.actions; {
        "Mod+Return".action.spawn = [ "alacritty" ];
        "Mod+Space".action.spawn = noctalia "panel-toggle launcher";
        "Mod+S".action.spawn = noctalia "panel-toggle control-center";
        "Mod+Shift+Comma".action.spawn = noctalia "settings-toggle";
        "XF86AudioRaiseVolume".action.spawn = noctalia "volume-up";
        "XF86AudioLowerVolume".action.spawn = noctalia "volume-down";
        "XF86AudioMute".action.spawn = noctalia "volume-mute";

        "Mod+Q".action = close-window;
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Shift+E".action = quit;
      };

      # from Noctalia's niri page: floating settings window + notification actions
      window-rules = [
        {
          matches = [ { app-id = "dev.noctalia.Noctalia"; } ];
          open-floating = true;
          default-column-width.fixed = 1080;
          default-window-height.fixed = 920;
        }
      ];
      debug.honor-xdg-activation-with-invalid-serial = [ ];
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
  home.sessionVariables = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # "dark mode" for ncurses menus like whiptail (nmtui)
    NEWT_COLORS = "root=,black;window=,black;border=blue,black;title=blue,black;textbox=white,black;button=black,blue;actbutton=white,blue;compactbutton=white,black;listbox=white,black;actlistbox=black,white;sellistbox=black,blue;actsellistbox=black,blue;checkbox=white,black;actcheckbox=black,white";
    # '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
