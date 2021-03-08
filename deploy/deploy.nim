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

import os, osproc, strutils, json, asyncdispatch
import oui/ui
import private/dependencies
import private/android
import oui/animation

const images = @["android.png", "linux.png", "windows.png"]

const red_button = (normal: "#ff1a1a", hover: "#ff6666", active: "#b30000", border: "#4d0000")
const green_button = (normal: "#00cc00", hover: "#33ff33", active: "#008000", border: "#003300")

var default_page: UiNode = nil

template button_with_label*(txt: string, up, clicked: untyped, style: ButtonSTyle = button_style) =
  button:
    text:
      update:
        str txt
        fill parent
    events:
      button_press:
        if event.button == 1:
          clicked
    update:
      up
  do: style

template add_dep() {.dirty.} =
  var 
    name_text = ""
    url_text = ""
    compile_step_text = ""    

  var compile_steps = new_j_a1rray()
  # compile_steps.add(new_j_string(compile_step_text))
  # compile_step_text = ""
    
template switch_os_page(img: string) =
  if img == "android.png":
    mainstack.stack_switch(android_page):
      #async_check mainstack.slide_node(android_page, UiRight)
      discard
  elif img == "linux.png":
    mainstack.stack_switch(linux_page):
      discard
  elif img == "windows.png": 
    mainstack.stack_switch(windows_page):
      discard

template build_header() =
  box header:
    color "#0000ff"
    update:
      w parent.w
      h 50
      top app.top
    text:
      str "Tap on the platform your deploying to"
      update:
        fill parent

template build_mainstack() =
  var mytext = ""
  var othertext = ""
  stack mainstack:
    update:
      top header.bottom
      bottom parent.bottom
      right parent.right
      left parent.left
      
    box android_page:
      visible false
      color 255, 0, 255
      box footer:
        update:
          h 75
          bottom parent.bottom
          w parent.w
        button_with_label "Install":
          h parent.h
          w parent.w / 2
        do:
          var i = 0
          async_check install_android_sdk(base_dir() & normalized_path "/androidsdk", proc(line: string) {.closure.} = 
            othertext.add line
            android_page.queue_redraw()
            i.inc
            if i >= 40:
              othertext = line
              i = 0
            )
        do: green_button
 
        button_with_label "Back":
           right parent.right
           h parent.h
           w parent.w / 2
        do:
          mainstack.stack_switch(default_page):
            discard
        do: red_button

      scrollable:
        update:
          top parent.top
          bottom footer.top
          right parent.right
          left parent.left
        box:
          color "#000000"
          update:
            fill parent
          text:
            valign UiTop
            halign UiRight
            update:
              fill parent
              str othertext
            color "#ffffff"
        
    box linux_page:
      visible false
    box windows_page:
      visible false
    row:
      default_page = self
      spacing 5
      for img in images:
        image:
          src img
          update:
            size 100, 50
          events:
            button_press:
              echo "pressed"
              switch_os_page(self.src)

when is_main_module:
  window app:
    size 400, 600
    build_header()
    build_mainstack()
  app.show()
  oui_main()

