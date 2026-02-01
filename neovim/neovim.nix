# My neovim based on ayats..
{
  fd,
  fzf,
  ripgrep,
  clang,
  libclang,
  curl,
  git,
  tree-sitter,
  tree-sitter-grammars,
  luarocks,
  tectonic,
  ghostscript,
  mermaid-cli,
  imagemagick,
  lua-language-server,
  rustPlatform,

  fetchFromGitHub,

  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  lib,
}: let
  specific-tree-sitter = tree-sitter.overrideAttrs (old: rec {
    version = "0.26.3";
    src = fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      tag = "v0.26.3";
      hash = "sha256-G1C5IhRIVcWUwEI45ELxCKfbZnsJoqan7foSzPP3mMg=";
      fetchSubmodules = true;
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-kHYLaiCHyKG+DL+T2s8yumNHFfndrB5aWs7ept0X4CM=";
    };

    patches = [];
  });

  packageName = "my-neovim";

  # Gotta do `:TSInstall rust` to get it going...
  startPlugins = with vimPlugins; [
    telescope-nvim
    nvim-treesitter.withAllGrammars
    nvim-dap
    fzf-lua
    lazy-nvim
    lazygit-nvim
    LazyVim
    rustaceanvim
    tokyonight-nvim
    plenary-nvim
    catppuccin-nvim
    nix-develop-nvim
    solarized-nvim
    nvchad
    markdown-preview-nvim
    neogit
  ];

  foldPlugins = builtins.foldl' (
    acc: next:
      acc
      ++ [
        next
      ]
      ++ (foldPlugins (next.dependencies or []))
  ) [];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);

  packpath = runCommandLocal "packpath" {} ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    ${
      lib.concatMapStringsSep
      "\n"
      (plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}")
      startPluginsWithDeps
    }
  '';
  
in
  symlinkJoin {
    name = "neovim-custom";
    paths = [
      neovim-unwrapped

      clang
      libclang
      curl
      fd
      fzf
      ripgrep
      git
      specific-tree-sitter
      tree-sitter-grammars.tree-sitter-rust
      luarocks
      tectonic
      ghostscript
      mermaid-cli
      imagemagick
      lua-language-server
    ];
    nativeBuildInputs = [
      makeWrapper
    ];
    postBuild = ''
      #wrapProgram $out/bin/nvim \
      #  --argv0 nvim-lazy \
      #  --add-flags '--cmd' \
      #  --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
      #  --set-default NVIM_APPNAME nvim-lazy
      
      wrapProgram $out/bin/nvim \
        --add-flags '-u' \
        --add-flags '${./init.lua}' \
        --add-flags '--cmd' \
        --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
        --set-default NVIM_APPNAME nvim-custom
    '';

    passthru = {
      inherit packpath;
    };
  }


