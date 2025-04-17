pkgs:
{
  enable = true;
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
      completion-timeout = 500;
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
        language-servers = [
          "pyright"
          "ruff"
        ];
      }
      {
        name = "markdown";
        soft-wrap.enable = true;
        auto-pairs = {
          "\"" = "\"";
          "'" = "'";
          "(" = ")";
          "[" = "]";
          "{" = "}";
        };
      }
      {
        name = "nix";
        formatter.command = "nixfmt";
        language-servers = [ "nixd" ];
      }
      {
        name = "sql";
        auto-format = false;
        language-servers = [ "sqls" ];
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
      {
        name = "c";
        formatter = {
          command = "clang-format";
        };
        persistent-diagnostic-sources = [
          "clangd"
          "clang-tidy"
        ];
      }
      {
        name = "cpp";
        formatter = {
          command = "clang-format";
        };
        persistent-diagnostic-sources = [
          "clangd"
          "clang-tidy"
        ];
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
        args = [ "server" ];
      };
      nixd = {
        command = "nixd";
      };
      clangd = {
        command = "clangd";
        args = [ "--clang-tidy" ];
        timeout = 60;
      };
      sqls = {
        command = "sqls";
      };
    };
  };
}
