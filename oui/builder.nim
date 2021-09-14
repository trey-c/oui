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

var apple: UiNode
proc add_widget*(node: UiNode, kind: UiNodeKind) =
  var child = UiNode.init(kind)
  child.w = 50
  child.h = 30
  child.accepts_focus = true
  if child.kind == UiText:
    child.str = "New Text"
  child.event.add proc(s, p: UiNode, e: var UiEvent) = 
    if e.kind == UiMousePress:
      apple = s
  node.add(child)

template attribute_form(inner: untyped) = 
  column:
    fill parent
    textbox:
      discard
    do: thisstr
    do: "str"
    inner

window:
  id builder
  title "Ocicat Ui Builder"
  size 500, 500
  var mystr = ""
  textbox:
    update:
      w 100
      h 40
      center parent
    mouse_press:
      mystr = apple.str
    key_press:
      apple.str = mystr

  do: mystr
  do: "Edit Text"
  list:
    id nodes
    json_array(%* ["Text", "Box", "Image", "Row", "Column"])
    delegate:
      text:
        update:
          color if self.hovered: rgb(200, 11, 11) else: rgb(11, 11, 11)
        size 22
        result = self
        str jobj.get_str()
        pressed:
          builder[2].add_widget(UiText)
  row:
    update:
      left nodes.right
      right parent.right

  builder.show()