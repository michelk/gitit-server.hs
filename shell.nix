{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, gitit, stdenv }:
      mkDerivation {
        pname = "gitit-server";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [ base gitit ];
        executableHaskellDepends = [ base ];
        testHaskellDepends = [ base ];
        homepage = "http://github.com/michelk/gitit-server#readme";
        description = "Serve multiple wikis with gitit";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
