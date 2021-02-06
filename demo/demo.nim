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

const 
  sidebar_color = "#00b07e"
  content_color = "#eeeeee"

template demo_sidebar() =
  box sidebar:
    color sidebar_color
    update:
      w 175
      h app.h
    text logo:
      text "Ocicat\nUi\nFramework"
      family "Sans Bold 14"
      color content_color
      halign UiRight
      valign UiTop
      update:
        top sidebar.top
        left sidebar.left
        right sidebar.right
        h 80

template demo_content() =
  box content:
    color content_color
    update:
      left sidebar.right
      right app.right
      h app.h  

proc main() =
  window app:
    title "Demo"
    w 600
    h 400

    demo_sidebar()
    demo_content()
 
  app.show()
  oui_main()
main()
