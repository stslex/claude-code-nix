{
  description = "Nix flake for Anthropic's Claude Code native binary";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        claude-code = pkgs.callPackage ./pkgs/claude-code { };
      in
      {
        packages = {
          default = claude-code;
          claude-code = claude-code;
        };

        apps.default = {
          type = "app";
          program = "${claude-code}/bin/claude";
        };
      }
    )
    // {
      overlays.default = final: _prev: {
        claude-code = final.callPackage ./pkgs/claude-code { };
      };
    };
}
