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

import macros, colors, strutils, cairo
export colors, strutils
import types, node, sugarsyntax, backend
export types, node, sugarsyntax, backend
import testmyway

proc text_box_key_press*(text: var string, event: var UiEvent, ch: string, password, focused: bool) =
  echo event.shift_state
  if focused:
    case event.key:
    of 65288:
      text.delete(text.high, text.high)
    of 32:
      if password:
        text.add("*")
      else:
        text.add(" ")
    of 65505, 65507, 65509:
      discard
    else:
      if password:
        text.add("*")
      else:
        if event.shift_state == true:
          text.add(ch.to_upper())
        else:
          text.add(ch)

template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
  var tmp = 0.0
  for child in node.children:
    child.`axis` = tmp
    tmp = tmp + child.`size` + node.spacing

template stack_switch*(node, target: UiNode, animate: untyped) =
  for n in node.children:
    n.visible = false
  for n in node.children:
    if n == target:
      n.visible = true
      animate
      break
  node.queue_redraw()

decl_style button: 
  normal: "#0099ff"
  hover: "#00ccff"
  active: "#006bb3"
  border: "#003d66"
decl_widget button, box:
  style: ButtonStyle = button_style
do:
  color style.normal
  radius 10
  border_width 2
  border_color style.border
  events:
    mouse_enter:
      color style.hover
      self.queue_redraw()
    mouse_leave:
      color style.normal
      self.queue_redraw()
    button_press:
      color style.active
      self.queue_redraw()
    button_release:
      color style.hover
      self.queue_redraw()

decl_style textbox: 
  normal: "#252525"
  border_focus: "#00ccff"
  border_normal: "#212121"
  txt: "#cccccc"
decl_widget textbox, box:
  var textstr: var string
  password: bool = false
  style: TextboxStyle = textbox_style
do:
  var
    this {.gensym.} = self
  accepts_focus true
  border_width 2
  radius 10
  color style.normal
  border_color style.border_normal
  text:
    halign UiRight
    color style.txt
    update:
      str textstr
      fill parent
  self = this
  events:
    focus:
      border_color style.border_focus
      self.queue_redraw()
    unfocus:
      border_color style.border_normal
      self.queue_redraw()
    key_press:
      text_box_key_press(textstr, event, event.ch, password, this.has_focus)
      this.queue_redraw()

decl_widget row, layout:
  discard
do:
  arrange_layout:
    arrange_row_or_column(y, h, id)

decl_widget column, layout:
  discard
do:
  arrange_layout:
    arrange_row_or_column(x, w, id)

decl_widget swipe_view, layout:
  discard
do:
  var 
    swipeing {.gensym.} = false 
    yoffset {.gensym.} = 0
    pos {.gensym.} = (x: 0, y: 0)
  arrange_layout:
    for child in self.children:
      child.x = self.x
      child.y = self.y + float32 yoffset
  events:
    button_press:
      case event.button:
      of 5:
        yoffset = yoffset - 5
        self.queue_redraw()
      of 4:
        yoffset = yoffset + 5
        self.queue_redraw()
      of 1:
        swipeing = true
        pos.x = event.x
        pos.y = event.y
      else:
        discard
  button_release:
    if event.button == 1:
      swipeing = false
  mouse_motion:
    if swipeing:
      yoffset = yoffset + (pos.y - event.y)

decl_widget list, layout:
  discard
do:
  discard

decl_widget popup, window:
  discard
do:
  self.is_popup = true

decl_widget combobox, textbox:
  discard
do:
  var up {.gensym.}: UiNode
  popup:
    up = self
    size 150, 400
    list:
      update:
        fill parent
  events:
    button_press:
      up.show()
      up.engine.move_window(ev.xroot, ev.yroot)

decl_widget stack, layout:
  discard
do:
  arrange_layout:
    for node in self.children:
      if node.visible != true:
        continue
      node.fill self

test_my_way "ui":
  test "declarations":
    box box1:
      button btn:
        check parent.id == "box1"
        text:
          check parent.id == "btn"
      row rw:
        check parent.id == "box1"
      column clmn:
        check parent.id == "box1"
      var tt = "f"
      textbox txtbx:
        check self.id == "txtbx"
        check parent.id == "box1"
      do: tt
    check box1.children.len == 4
