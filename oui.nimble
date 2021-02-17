version = "0.1.2"
author = "Trey Cutter"
description = "TODO"
license = "Apache License 2.0"
backend = "c"

requires "nim >= 1.4.0"
requires "https://github.com/trey-c/testmyway.git"

requires "cairo"
when defined linux:
  requires "x11"
when defined windows:
  requires "winim"

import strutils
from os import walkDirRec
from system import gorge_ex, exists

task tests, "Run all tests":
  for path in walkDirRec("oui"):
    if path.contains(".nim"):
      if path.contains("/private/") == true:
        continue

      if param_count() == 9:
        if path.contains(param_str(9)) == false:
          continue

      let (output, code) =
        gorge_ex "nim c -d:testing -r --hints:off " & path
      
      if output.len < 1:
        continue
      echo output
      if code == 0:
        echo " \e[0;32m\u2713\e[0m " & path
      elif code == 1:
        echo " \e[0;31m\u2717\e[0m " & path
        break

task clean, "Cleans all built targets":
  var exit = false
  for path in walkDirRec("oui"):
    if path.contains(".nim") == false or path.contains("/private/"):
      continue
    
    var rpath = path
    rpath.remove_suffix(".nim")
    let (output, code) =
      gorge_ex "rm " & rpath
    echo "\e[0;30m\u2713\e[0m Deleted " & rpath
    
