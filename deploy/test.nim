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

import oui/ui
import os, osproc, strutils, json

const opts = {poUsePath, poDaemon, poStdErrToStdOut, poEvalCommand}

template run_command*(cmd: string, exitcode: var int, inner: untyped) =
  var process = start_process(cmd, "", [], nil, opts)
  for line {.inject.} in process.lines:
    inner
  exitcode = process.peekExitCode()
  process.close()

const WGET_COMMAND* = "wget -O - $1 | tar xz"



when is_main_module:
  var pangourl = WGET_COMMAND % ["https://gitlab.gnome.org/GNOME/pango/-/archive/1.48.2/pango-1.48.2.tar.gz"]

  var pp: UiNode 
  pp = UiNode.init("apples", UiWindow)
  var code1 = 0
  run_command(pangourl, code1):
    echo line
  echo code1
  run_command("ls .", code1):
    echo line
  echo code1
