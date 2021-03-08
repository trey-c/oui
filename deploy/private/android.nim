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

import os, osproc, strutils, sets, asyncdispatch
import dependencies

proc install_android_sdk*(location: string, linecb: proc(l: string)) {.async.} =
  var 
    code = 0 
  when defined(windows):
    var mkdir = "mkdir "
  when defined(linux):
    var mkdir = "mkdir -p "
  run_shell_command(mkdir & location, code):
    linecb line & "\n"
    await sleepAsync(1)
  set_current_dir(location)
  
  var 
    sdk_root = "--sdk_root=" & normalized_path "./cmdline-tools"
    sdkmanager = normalized_path "cmdline-tools/tools/bin/sdkmanager"
    sdk_commands = @["wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -p .", 
      "unzip commandlinetools-linux-6609375_latest.zip -d cmdline-tools", 
      "rm commandlinetools-linux-6609375_latest.zip", 
      sdkmanager & " --update " & sdk_root,
      sdkmanager & " --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\" " & sdk_root]
  for cmd in sdk_commands:
    run_shell_command(cmd, code):
      linecb line & "\n"
      await sleepAsync(1)
