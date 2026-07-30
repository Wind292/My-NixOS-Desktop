{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland-preview-share-picker.url = "git+https://github.com/WhySoBad/hyprland-preview-share-picker?submodules=1"; 

    nix-editor.url = "github:snowfallorg/nix-editor";
    nix-editor.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-editor, ... }: 
    let 
      vars = import ./vars.nix;
    in {
    nixosConfigurations.${vars.hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };  
          home-manager.users.jp3 = import ./home.nix;
        }
      ];
    };
  };
}
