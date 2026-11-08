{
  description = "diffs-collection.nvim — comparisons, review, and conflicts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    diffs-src = {
      url = "github:barrettruth/diffs.nvim/9c408315f1ae70c26e21541df6e216b8946fe46e";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      diffs-src,
      ...
    }:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);

      devShells = forEachSystem (
        pkgs:
        let
          ts-plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.diff ]);
          diff-grammar = pkgs.vimPlugins.nvim-treesitter-parsers.diff;
          luaEnv = pkgs.luajit.withPackages (
            ps: with ps; [
              busted
              nlua
            ]
          );
          busted-with-grammar = pkgs.writeShellScriptBin "busted" ''
            nvim_bin=$(which nvim)
            tmpdir=$(mktemp -d)
            trap 'rm -rf "$tmpdir"' EXIT
            printf '#!/bin/sh\nexec "%s" --cmd "set rtp+=${ts-plugin}/runtime" --cmd "set rtp+=${diff-grammar}" "$@"\n' "$nvim_bin" > "$tmpdir/nvim"
            chmod +x "$tmpdir/nvim"
            PATH="$tmpdir:$PATH" exec ${luaEnv}/bin/busted "$@"
          '';
          commonPackages = [
            busted-with-grammar
            pkgs.just
            pkgs.biome
            pkgs.stylua
            pkgs.selene
            pkgs.lua-language-server
            pkgs.neovim
          ];
        in
        {
          default = pkgs.mkShell {
            packages = commonPackages;
            DIFFS_NVIM_PATH = "${diffs-src}";
            VIMRUNTIME = "${pkgs.neovim}/share/nvim/runtime";
          };
        }
      );
    };
}
