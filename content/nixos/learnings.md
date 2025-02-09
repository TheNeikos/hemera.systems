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

## Virtual Machine tests

Nix has some cool infrastructure to test anything you can in a configuration of multiple virtual machines.

It has some warts, as the test script is written in python... But overall, it gets its job done.

[Manual](https://nixos.org/manual/nixos/stable/#sec-running-nixos-tests)

## Getting a reproducible build time in flakes

Flakes, like anything in `nix` are meant to be reproducible. The way this is
usually achieved is to set some static time, like `1` in the unix epoch.

But this is 1970... So lots of stuff will display as being decades old.

But flakes are always (I think?) `git` repositories and as such you _have_ a
reproducible time, that also gets exposed.

This now needs to be transformed to something more standardized:

This will spit out a date in ISO8601 format, in UTC.

```nix
created =
  let
    sub = from: len: builtins.substring from len inputs.self.lastModifiedDate;
    year = sub 0 4;
    month = sub 4 2;
    day = sub 6 2;
    hour = sub 8 2;
    minute = sub 10 2;
    second = sub 12 2;
  in
  "${year}-${month}-${day}T${hour}:${minute}:${second}Z";
```
