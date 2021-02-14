# Copyright © 2020 Trey Cutter <treycutter@protonmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os, osproc, strutils, sets
import private/dependencies

proc setup_android_deps(dir, specific: string = "") =
  var
    sdk = "/home/androidsdk/cmdline-tools"
    ndk = sdk & "/ndk-bundle"
    toolchain = ndk & "/toolchains/llvm/prebuilt/linux-x86_64"
    target = "x86_64-linux-android"
    api = 29
    bin = toolchain & "/bin/"
    targetpath = bin & target
  
  var cross_compile_in = """
[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'arm'
endian = 'little'

$1
"""
  setup_cross_compilation(dir, (prefix: dir & "usr",
                                sys_root: toolchain & "/sysroot",
                                cc: targetpath & $api & "-clang",
                                cxx: targetpath & $api & "-clang++",
                                ar: targetpath & "-ar",
                                ld: targetpath & "-ld",
                                ass: targetpath & "-as",
                                strip: targetpath & "-strip",
                                ranlib: targetpath & "-ranlib", 
                                cross_compile: cross_compile_in))
  setup_deps(dir, specific)

proc setup_sdk_tools(location: string) =
  echo "setting up the sdk tool"
  if dir_exists(location):
    echo "skipping sdk tools as they seem to be setup already"
    return
  var unzip = false
  discard exec_shell("sudo mkdir -m777 " & location)
  set_current_dir(location)
  if exec_shell("wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -P ."):
    if exec_shell("unzip ./commandlinetools-linux-6609375_latest.zip -d ./cmdline-tools"):
      if exec_shell("rm ./commandlinetools-linux-6609375_latest.zip"):
        unzip = true
  if unzip != true:
    return
  
  var 
    sdk_root = "--sdk_root=./cmdline-tools"
    sdkmanager = false
  if exec_shell("./cmdline-tools/tools/bin/sdkmanager --update " & sdk_root):
    if exec_shell("./cmdline-tools/tools/bin/sdkmanager --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\" " & sdk_root, "y"):
      echo "the sdk tools are done being setup"

    discard exec_shell("./cmdline-tools/tools/bin/sdkmanager --licenses " & sdk_root, "y")
  if sdkmanager != true:
    echo "failed to setup the sdk tools. Skipping"

proc clean_sdk_tools(location: string) =
  discard exec_shell("rm -rf " & location)

proc main() =
  var
    base_dir = getCurrentDir() & "/.deploy/"
    android_dir = "/home/androidsdk"
  if param_count() == 0:
    echo "need an arg"
    return
  case param_str(1):
    of "clean":
      case param_count():
      of 1:
        echo "not enough args for clean"
      of 2:
        case param_str(2):
        of "sdktools":
          clean_sdk_tools(android_dir)
        of "deps":
          clean_deps(base_dir)
        of "deploy":
          discard exec_shell("rm -rf " & base_dir)
        else:
          echo("unkown arg " & param_str(2))
      of 3:
        clean_deps(base_dir, param_str(3))
      else:
        echo($param_count() & " is too many args for clean")
    of "setup":
      if dir_exists(base_dir) == false:
        discard exec_shell("mkdir " & base_dir)
      case param_count():
      of 1:
        setup_sdk_tools(android_dir)
        setup_android_deps(base_dir)
      of 2:
        case param_str(2)
        of "sdktools":
          setup_sdk_tools(android_dir)
        of "deps":
          setup_android_deps(base_dir)
        else:
          echo("unkown arg " & param_str(2))
      of 3:
        setup_android_deps(base_dir, param_str(3))
      else:
        echo($param_count() & " is too many args for setup")
    else:
      echo("unkown arg " & param_str(1))

when is_main_module:
  main()
