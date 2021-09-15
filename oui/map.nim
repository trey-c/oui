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

import oui, nimgl/glfw/native, winim, threadpool, osproc, strutils

proc start_ouimap_exe(handle: string, cb: proc(winid: int)) {.thread.} =
  var p = startProcess("ouimapf.exe", "", [handle], nil, {poUsePath, poStdErrToStdOut})
  for line in p.lines:
    let l = line.split(':')
    echo line
    if l.len == 2:
      cb(parse_int(l[1]))
  p.close()

proc map*(window: UiNode): UiNode =
  assert window.kind == UiWindow
  result = UiNode.init(UiEmbedded)
  var closured = result
  spawn start_ouimap_exe($cast[int](getWin32Window(window.handle)), proc(winid:int) = closured.winid = winid)

window:
  pressed:
    self.add map(self)
  w 500
  h 400
  color rgb(100, 0,  100)
  self.show()