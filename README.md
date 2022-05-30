# Hemera Systems

A technical blog about all things at once.

## Running using Nix

To start the Emanote live server using Nix:

```sh
nix run
```
This will create server listening on http://localhost:7072.



To update Emanote version in flake.nix:

```sh
nix flake lock --update-input emanote
```

To build the static website via Nix:

```sh
nix build -o ./result
# Then test it:
nix run nixpkgs#nodePackages.live-server -- ./result
```
