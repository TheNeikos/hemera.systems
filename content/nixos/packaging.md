# Packaging things in Nix

[[nixos]] is notoriously underdocumented, and it frankly has no structure that lends itself to be nicely documented. (Maybe [[flakes]] will provide some relief? I doubt it though.

Until that situation is better, here's my own documentation on things:


## Getting node modules into your env

Use `pkgs.yarn2nix-moretea.mkYarnModules` to generate a derivation that contains the packages you need through a lock file:

```nix
nodeModules = pkgs.yarn2nix-moretea.mkYarnModules {
    inherit version;
    pname = "${project-name}-js-deps";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
};
```

This will create a derivation that contains a `node_modules` folder with all the dependencies.

In this case, I wanted to have `tailwind` access to more packages. So, I had to
add the `nodeModules` derivation to the `NODE_PATH` env variable.

Luckily, this is possible with the `makeWrapper` helper:

```nix
tailwind = pkgs.stdenv.mkDerivation {
    inherit version;
    pname = "${pname}-tailwindcss";

    nativeBuildInputs = [ pkgs.makeWrapper ];

    buildCommand = ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.nodePackages.tailwindcss}/bin/tailwindcss $out/bin/tailwindcss \
            --prefix NODE_PATH ":" "${nodeModules}/node_modules"
    '';
};
```

This prefixed the `NODE_PATH` env variable with a path to the `node_modules`
folder that we built earlier. This way, `tailwind` will find whatever we gave it.
