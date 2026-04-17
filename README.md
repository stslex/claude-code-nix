# claude-code-nix

Nix flake that packages [Claude Code](https://github.com/anthropics/claude-code) — Anthropic's official agentic coding CLI — as a native binary.

## Usage

### Flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    claude-code.url = "github:stslex/claude-code-nix";
    claude-code.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

### NixOS / home-manager via overlay

```nix
{ inputs, ... }:
{
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "claude-code" ];

  # NixOS
  environment.systemPackages = [ pkgs.claude-code ];

  # or home-manager
  home.packages = [ pkgs.claude-code ];
}
```

### Ad-hoc run

```bash
nix run github:stslex/claude-code-nix
```

## Updating

Bump to the latest stable version:

```bash
./scripts/update.sh
```

Pin to a specific version:

```bash
./scripts/update.sh 2.1.92
```

An automated GitHub Actions workflow for periodic updates will be added separately.

## Acknowledgements

Inspired by [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix) and [ryoppippi/nix-claude-code](https://github.com/ryoppippi/nix-claude-code).

## License

Packaging code: [MIT](LICENSE). Claude Code itself is proprietary (Anthropic).
