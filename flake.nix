{
    description = "devshell";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    outputs =
        { self, nixpkgs }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };
            buildInputs = with pkgs; [
                pandoc
                texlivePackages.xelatex-dev
            ];
        in
        {
            devShells.${system}.default = pkgs.mkShell {
                packages = with pkgs; [
                ];

                inherit buildInputs;

                shellHook = ''
                    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH
                '';
            };
        };
}
