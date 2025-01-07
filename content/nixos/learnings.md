# Random Nix stuff I learned

## `getExe` uses meta.mainProgram

The `nixpkgs` lib function `getExe` uses `meta.mainProgram` to get a path to
the executable in a package. It's final path will then be interpolated into
`$out/bin/{name}`.

[Source](https://github.com/NixOS/nixpkgs/blob/72bf900cbb64d166c4a93ad756f11a78eb9d1600/lib/meta.nix#L433-L438)
