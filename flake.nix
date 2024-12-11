{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    emanote.url = "github:srid/emanote";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.emanote.flakeModule
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          emanote = {
            sites = {
              default = {
                layers = [
                  {
                    path = ./content;
                    pathString = "./content";
                  }
                ];
                prettyUrls = true;
              };
            };
          };
        };
    };
}
