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

import oui
import nanovg

template items() =
  ## Showcases both the textbox and list widgets

  var itemstr = "I hate life"
  textbox:
    minw 200
    minh 35
    discard
  do: itemstr
  do: "Add Item"

  var itemstr1 = "I hate life"
  textbox:
    update:
      right parent.right
      # padding_right 25
      
      padding_right 29
    minw 200
    minh 35
  do: itemstr1
  do: "Add Item"

window:
  id app
  title "Demo"
  w 600
  h 400
  scrollable:
    update:
      fill parent
    items()
    text:
      id smexy
      str "Ocicat Ui Framework"
      update:
        bottom parent.bottom
        h 50
        w parent.w
        padding_bottom 25
        halign UiCenter
    box:
      id pp
      size 100, 100
    button:
      id crap
      text:
        str "Click me"
        halign UiCenter
        valign UiCenter
      update:
        size 100, 30
        top pp.bottom
        left pp.right
    button:
      text:
        update:
          fill parent
        str "Click me"
        halign UiCenter
        valign UiCenter
      update:
        size 100, 50
        top crap.bottom
        left pp.right
    box:
      id tt
      color 100, 100, 100
      size 100, 50
      update:
        top pp.bottom
    box:
      id ttt
      color 100, 0, 100
      size 100, 100
      update:
        top tt.bottom
 

app.show()
oui_main()
