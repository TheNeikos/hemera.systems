# Packaging Dynamic Libraries

> [!info]
>
> This page was written on the 11th December 2024, so this might be outdated if
you read it in the future.

Packaging dynamic libs under nix is fairly easy usually:

1. Build whatever you are packaging
2. Copy it to `$out/lib/libnameoflibrary.so`
3. Profit!

But this will not necessarily allow using it in other build tools, as lots of
tools use `pkg-config` to discover locations of packages.

Nixpkgs support this form of discovery. The way you do that is as following:

**On the dependent**:

Wherever you plan on using `libnameoflibrary.so` you do the following:

```nix
stdenv.mkDerivation {
    buildInputs = [ pkg-config nameoflibrary ];
}
```

Fairly simple! Under the hood `pkg-config` registers an environment hook that
looks through all build dependencies and looks for `.pc` files in
`$dep/lib/pkgconfig/`. Those then get put into whatever env variables
pkg-config needs and allows them to be discovered.

**On the dependency**:

When building `nameoflibrary` you do the usual building steps but you also need
to place a `.pc` file at `$out/lib/pkgconfig/libnameoflibrary.pc`.

Luckily nixpkgs provides such a helper to create this:

`makePkgconfigItem` and `copyPkgconfigItems`.

The commit that added them has some info on how they are used:
https://github.com/NixOS/nixpkgs/commit/7249b8a2f3318bb03c50429f5907015e99901c0b

[Thanks Kiskae for the pointer!](https://hachyderm.io/@Kiskae/113634590760671566)

> [!warn]
> The method below works, but the above is easier.

Example content:

```pkgconfig
prefix=@out@
includedir=${prefix}/include
libdir=${prefix}/lib

Name: @pname@
Version: @version@
Description: A great library!
```

This file on its own is not ready yet, but we just need one other step:

```nix
stdenv.mkDerivation {
    # Your usual build stuff
    postInstall = ''
        substitute libnameoflibrary.pc $out/lib/pkgconfig/libnameoflibrary.pc \
            --subst-var out \
            --subst-var pname \
            --subst-var version
    '';
}
```

`substitute` will replace all those `@out@`/`@pname@` occurrences with the
corresponding env variable. (Which is what `out` and `pname` turn out to be)

substitute is part of the default building environment given by nix.

Now your downstream packages will be able to find your library!

Voila
