{ writers, python3Packages }:
writers.writePython3Bin "jpassmenu" {
  libraries = [ python3Packages.click ];
  # line too long, but I like my code well documented
  flakeIgnore = [ "E501" ];
} ./jpassmenu.py
