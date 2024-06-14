{pkgs}: {
  vim-jjdescription = pkgs.callPackage ./vim-jjdescription.nix {};
  nvim-silicon = pkgs.callPackage ./nvim-silicon.nix {};
}
