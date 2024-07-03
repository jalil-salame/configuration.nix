{ vimUtils, fetchFromGitHub }:
vimUtils.buildVimPlugin {
  name = "jjdescription";
  src = fetchFromGitHub {
    owner = "avm99963";
    repo = "vim-jjdescription";
    rev = "c9bf9f849ead3961ae38ab33f68306996e64c6e8";
    hash = "sha256-qnZFuXbzpm2GN/+CfksFfW2O+qTosUZcUagqCTzmtWo=";
  };
}
