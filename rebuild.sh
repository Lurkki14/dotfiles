# Commit comes from nixos-unstable branch
pinnedCommit="78419edadf0fabbe5618643bd850b2f2198ed060"
nixpkgsUrlFromCommit="https://github.com/NixOS/nixpkgs/archive/$pinnedCommit.tar.gz"

NIX_PATH="nixpkgs=$nixpkgsUrlFromCommit" sudo -E nixos-rebuild switch -I nixos-config=configuration.nix "$@"
