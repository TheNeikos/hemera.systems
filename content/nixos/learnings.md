# Random Nix stuff I learned

## `getExe` uses meta.mainProgram

The `nixpkgs` lib function `getExe` uses `meta.mainProgram` to get a path to
the executable in a package. It's final path will then be interpolated into
`$out/bin/{name}`.

[Source](https://github.com/NixOS/nixpkgs/blob/72bf900cbb64d166c4a93ad756f11a78eb9d1600/lib/meta.nix#L433-L438)

## Creating inline derivations in nix files

Sometimes one simply wants to write a quick script, or some other text file in a nix derivation.

The easiest way to achieve that is with the 'trivial' builders that nixpkgs has to offer.

[Their descriptions in the manual](https://nixos.org/manual/nixpkgs/unstable/#chap-trivial-builders)
