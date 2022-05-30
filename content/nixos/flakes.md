# Flakes

Flakes are an upcoming feature of `nix` the package manager.

They do a lot of things, and I am still trying to grasp it fully.

Here are some thing I've found out so far:

They are a way to specify _all_ dependencies in a declarative way through:

- Being explicit about the `inputs` of the flake
    - In a flake you cannot load local files that are not part of its repository
    - You also cannot load external files without also specifying their sha hash
- Streamlining `lock` files, to make sure it stays reproducible



----------------


Some important links:

- [NixOS Wiki on Flakes](https://nixos.wiki/wiki/Flakes)
- [Xe's Blog on Flakes](https://xeiaso.net/blog/nix-flakes-1-2022-02-21)
