{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = with import nixpkgs {system = "x86_64-linux"; };
      stdenv.mkDerivation {
        name = "kicad";
        src = fetchGit {
          url = "https://gitlab.com/kicad/code/kicad.git";
          rev = "286b0611feca00727bf70bfa184ec2c28a745dc3";
        };

        buildInputs = let wxGTK = wxGTK32.overrideAttrs (oldAttrs: {
          configureFlags = oldAttrs.configureFlags ++ [ "--disable-glcanvasegl"];
        }); in [ 
          cmake 
          glew 
          glm 
          zlib 
          zstd
          curl
          cairo
          libgit2
          boost
          harfbuzz
          libngspice
          opencascade-occt
          protobuf
          swig
          python311
          python311Packages.wxpython
          wxGTK
          unixODBC
          pkg-config
          gtk3
          libsecret
        ];

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        configurePhase = ''
          mkdir -p build/release
          cd build/release
          cmake -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=RelWithDebInfo -DKICAD_IPC_API=OFF -DKICAD_USE_EGL=OFF -DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade  ../../
        '';

        buildPhase = ''
          make
        '';

        postFixup = ''
          wrapProgram $out/bin/kicad --suffix LD_LIBRARY_PATH : $out/lib
        '';
      };

  };
}
