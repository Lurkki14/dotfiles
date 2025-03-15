# Commit comes from nixos-unstable branch
pinnedCommit="3de810d52cbec1e0de2ca83f2c67cca290b7b6ff"
nixpkgsUrlFromCommit="https://github.com/NixOS/nixpkgs/archive/$pinnedCommit.tar.gz"

NIX_PATH="nixpkgs=$nixpkgsUrlFromCommit" sudo -E nixos-rebuild switch -I nixos-config=configuration.nix "$@"
