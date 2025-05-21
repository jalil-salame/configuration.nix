{ writers, python3Packages }:
writers.writePython3Bin "audiomenu" {
  libraries = [ python3Packages.click ];

  flakeIgnore = [
    "E501" # line too long, but I like my code well documented
    "W503" # line break before binary operator, ruff does this, I trust it
  ];
} ./audiomenu.py
