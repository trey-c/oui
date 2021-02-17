version = "0.1.0"
author = "Trey Cutter"
description = "TODO"
license = "Apache License 2.0"
backend = "c"
#bin = @["deploy"]
namedBin["deploy"] = "ouideploy"
requires "nim >= 1.4.0"
requires "oui"


requires "https://github.com/trey-c/testmyway.git"
