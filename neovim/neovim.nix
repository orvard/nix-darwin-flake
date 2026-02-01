# My neovim based on ayats..
{
  fd,
  fzf,
  ripgrep,
  curl,
  git,
  tree-sitter,
  luarocks,
  tectonic,
  ghostscript,
  mermaid-cli,
  imagemagick,

  fetchFromGitHub,

  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  lib,
}: let
  #specific-tree-sitter = tree-sitter.overrideAttrs (old: {
  #  version = "0.26.3";
  #  src = fetchFromGitHub {
  #    owner = "tree-sitter";
  #    repo = "tree-sitter";
  #    tag = "v0.26.3";
  #    hash = "sha256-G1C5IhRIVcWUwEI45ELxCKfbZnsJoqan7foSzPP3mMg=";
  #    fetchSubmodules = true;
  #  };
  #});

  packageName = "my-neovim";

  startPlugins = with vimPlugins; [
    telescope-nvim
    nvim-treesitter.withAllGrammars
    fzf-lua
    lazy-nvim
    lazygit-nvim
    LazyVim
    rustaceanvim
    tokyonight-nvim
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

      curl
      fd
      fzf
      ripgrep
      git
      tree-sitter
      luarocks
      tectonic
      ghostscript
      mermaid-cli
      imagemagick
    ];
    nativeBuildInputs = [
      makeWrapper
    ];
    postBuild = ''
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


