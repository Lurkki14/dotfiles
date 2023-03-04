pinnedCommit="3c5319ad3aa51551182ac82ea17ab1c6b0f0df89"
nixpkgsUrlFromCommit="https://github.com/NixOS/nixpkgs/archive/$pinnedCommit.tar.gz"


NIX_PATH="nixpkgs=$nixpkgsUrlFromCommit" sudo -E nixos-rebuild switch -I nixos-config=configuration.nix
