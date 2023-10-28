# Commit comes from nixos-unstable branch
pinnedCommit="8efd5d1e283604f75a808a20e6cde0ef313d07d4"
nixpkgsUrlFromCommit="https://github.com/NixOS/nixpkgs/archive/$pinnedCommit.tar.gz"

NIX_PATH="nixpkgs=$nixpkgsUrlFromCommit" sudo -E nixos-rebuild switch -I nixos-config=configuration.nix "$@"
