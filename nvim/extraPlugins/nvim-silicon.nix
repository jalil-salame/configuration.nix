{
  vimUtils,
  fetchFromGitHub,
}:
vimUtils.buildVimPlugin {
  name = "nvim-silicon";
  src = fetchFromGitHub {
    owner = "michaelrommel";
    repo = "nvim-silicon";
    rev = "v1.0.0";
    hash = "sha256-cZOzgzLUNC9qOS2m/rc6YJfpNGdRTSCAdEPQDy+wT6I=";
  };
}
