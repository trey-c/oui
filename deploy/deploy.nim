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
import oui/ui
import private/dependencies

const images = @["android.png", "linux.png", "windows.png"]

proc switch_os_page(img: string, stack: UiNode) =
  discard

when is_main_module:
  window app:
    size 400, 600
    box header:
      color "#0000ff"
      update:
        w parent.w
        h 50
        top app.top
      text:
        str "Choose the platform your deploying to "
        update:
          fill parent
    row:
      update:
        top header.bottom
        bottom parent.bottom
        w parent.w
      for img in images:
        image:
          src img
          update:
            size 200, 50

  app.show()
  oui_main()

