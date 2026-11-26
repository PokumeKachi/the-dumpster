{
    description = "devshell";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    outputs =
        { self, nixpkgs }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; };

            tex = pkgs.texlive.combine {
                inherit (pkgs.texlive)
                    scheme-small
                    xetex
                    xecjk
                    xcolor
                    fontspec
                    unicode-math
                    noto
                    ;
            };
            buildInputs = with pkgs; [

                # texlive.combined.scheme-small
                # texlive.noto
                zathura
                pandoc
                tex
            ];
        in
        {
            devShells.${system}.default = pkgs.mkShell {
                packages = with pkgs; [
                ];

                inherit buildInputs;

                shellHook = ''
                    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH
                    export SHELL=/run/current-system/sw/bin/bash
                '';
            };
        };
}
