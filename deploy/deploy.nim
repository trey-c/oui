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

import os, osproc, strutils, json
import oui/ui
import private/dependencies

const images = @["android.png", "linux.png", "windows.png"] 

template lazy_button*(txt: string, id, up, clicked: untyped) {.dirty.} =
  button id, button_style:
    text:
      str txt
      update:
        fill parent
    events:
      button_press:
        if event.button == 1:
          clicked
    update:
      size 100, 50
      up       

template add_dep() {.dirty.} =
  var 
    name_text = ""
    url_text = ""
    compile_step_text = ""    

  textbox name, name_text, false:
    update:
      size 100, 25
  textbox url, url_text, false:
    update:
      size 100, 25
      top name.bottom
  textbox compilestep, compile_step_text, false:
    update:
      size 100, 25
      top url.bottom
  
  var compile_steps = new_j_array()
  lazy_button("Add compile step", addstep):
    bottom compilestep.bottom 
  do:
    compile_steps.add(new_j_string(compile_step_text))
    compile_step_text = ""
    
  
proc switch_os_page(img: string, stack: UiNode) =
  discard

when is_main_module:
  window app:
    size 400, 600
    var myemailtext = ""
    textbox email, myemailtext, false:
      echo "hello"
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
    row ttt:
      update:
        top header.bottom
        bottom parent.bottom
        w 199
        right parent.right
      for img in images:
        image:
          src img
          update:
            size 200, 50
  app.show()
  oui_main()

