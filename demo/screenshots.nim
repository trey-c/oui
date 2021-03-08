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
import oui/animation

window app:
  size 600, 600
  color "#cccccc"
  column:
    spacing 10
    update:
      fill parent
    for i in 1..5:
      box:
        color "#0000ff"
        w 50
        h 100 * float i
        border_color "#000000"
        border_width 4
        events:
          button_press:
            async_check parent.slide_node(self, UiRight)
app.show()  
oui_main()
