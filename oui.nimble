version = "0.1.4"
author = "Trey Cutter"
description = "Ocicat Ui Framework (oui)"
license = "Apache License 2.0"
backend = "c"
namedBin["oui/deployandroid"] = "deployandroid"
namedBin["oui/testaid"] = "testaid"
installExt = @["oui"]
requires "nim >= 1.4.0"

# thanks https://github.com/johnnovak/nim-nanovg/issues/2#issuecomment-813278849
requires "https://github.com/johnnovak/nim-nanovg#099121232829722752d33e0472a11201195feb55"
requires "nimgl"

requires "https://github.com/trey-c/nim-glfm.git"
requires "https://github.com/yglukhov/android.git"

import os, strutils

before install:
  cp_dir(".oui", get_home_dir() & ".oui")

after install:
  echo "Ocicat Ui Framework (oui)"
  echo "Read the manual - https://github.com/trey-c/oui/blob/master/doc/MANUAL.md"
  echo "Report any bugs or suggestions - https://github.com/trey-c/oui/issues"
