{
  description = "A basic devShell using flake-utils each";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";  # use the unstable packages for more up-to-date packages
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs,  flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [ 
          zsh
          ripgrep
          python3Full
          go
          golangci-lint
          gopls
          gnumake
          python310Packages.pip
          python310Packages.poetry
          diffutils
        ];

        BUF_BUILD_VER="1.1.0";
        PROTOC_GEN_GO_VER="1.27.1";
        PROTOC_GEN_GO_GRPC_VER="1.2.0";
        PROTOC_GEN_JSONSCHEMA_VER="1.3.7";
        PROTOC_GEN_GRPC_GATEWAY_VER="2.7.3";
        PROTOC_GEN_OPENAPIV2_VER="2.7.3";
        PROTOC_GEN_DOC_VER="1.5.1";

        shellHook = ''
          export GOPATH=$PWD/.data/go
          export PATH=$GOPATH/bin:$PATH

          tools="github.com/bufbuild/buf/cmd/buf@v$BUF_BUILD_VER
          google.golang.org/protobuf/cmd/protoc-gen-go@v$PROTOC_GEN_GO_VER
          google.golang.org/grpc/cmd/protoc-gen-go-grpc@v$PROTOC_GEN_GO_GRPC_VER
          github.com/chrusty/protoc-gen-jsonschema/cmd/protoc-gen-jsonschema@$PROTOC_GEN_JSONSCHEMA_VER
          github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v$PROTOC_GEN_GRPC_GATEWAY_VER
          github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v$PROTOC_GEN_OPENAPIV2_VER
          github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@v$PROTOC_GEN_DOC_VER"

          # Note: Make sure the above tools and versions match the ones in devops-infra/docker/cipipeline/Dockerfile
          echo "$tools" | while read -r toolurl ; do
              go install "$toolurl"
          done

          echo "Go development shell"
        '';
      };
    }
  );
}

