{
  description = "Astro + pnpm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nodeVersion = pkgs.nodejs_25; 
      in
      {
        devShells.default = pkgs.mkShell {
          #在这里列出你需要用到的工具
          buildInputs = with pkgs; [
            nodeVersion          
            pnpm                 
            biome
            typescript-language-server
            typescript
          ];
        };
      }
    );
}
