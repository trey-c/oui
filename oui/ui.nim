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

import macros, strutils, glfw
import nanovg except text
export strutils
import types, node, sugarsyntax
import testmyway

# template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
#   var tmp = 0.0
#   for child in node.children:
#     child.`axis` = tmp
#     tmp = tmp + child.`size` + node.spacing

# template stack_switch*(node, target: UiNode, animate: untyped) =
#   node.trigger_update_attributes()
#   for n in node.children:
#     if n.visible:
#       n.hide()
#   for n in node.children:
#     if n == target:
#       n.show()
#       animate
#       break
#   node.queue_redraw()

decl_style button: 
  normal: rgb(50, 50, 50)
  hover: rgb(64, 64, 64)
  active: rgb(44, 44, 44)
  border: rgb(14, 14, 14)
decl_widget button, box:
  style: ButtonStyle = button_style
do:
  color style.normal
  radius 2
  border_width 2
  border_color style.border
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

# template button_with_text*(txt: string, up, clicked: untyped, style: ButtonSTyle = button_style) =
#   button:
#     text:      
#       str txt
#       update:
#         fill parent
#     events:
#       button_release:
#         if event.button == 1:
#           clicked
#     update:
#       up
#   do: style

# proc text_box_key_press*(text: var string, event: var UiEvent, password, focused: bool) =
#   case event.key:
#   of keyBackspace:
#     text.delete(text.high, text.high)
#   of keySpace:
#     if password:
#       text.add("*")
#     else:
#       text.add(" ")
#   else:
#     if password:
#       text.add("*")
#     else:
#       if event.mods. == true:
#         text.add(event.ch.to_upper())
#       else:
#         text.add(event.ch.to_lower())

decl_style textbox: 
  normal: rgb(50, 50, 50)
  border_focus: rgb(77, 77, 77)
  border_normal: rgb(38, 38, 38)
  txt: rgb(145, 145, 145)
decl_widget textbox, box:
  var textstr: var string
  label: string
  password: bool = false
  style: TextboxStyle = textbox_style
do:
  accepts_focus true
  border_width 2
  radius 2
  color style.normal
  border_color style.border_normal
  text:
    halign UiRight
    color style.txt
    update:
      str textstr
      fill parent
  focus:
    border_color style.border_focus
    self.queue_redraw()
  unfocus:
    border_color style.border_normal
    self.queue_redraw()
  key_press:
    if not self.focused:
      return
    text_box_key_press(textstr, event, event.ch, password, self.has_focus)
    self.queue_redraw()

# decl_widget combobox, textbox:
#   discard
# do:
#   var up {.gensym.}: UiNode
#   popup:
#     up = self
#     size 150, 400
#     list:
#       update:
#         fill parent
#   events:
#     button_press:
#       up.show()
#       up.engine.move_window(ev.xroot, ev.yroot)

# decl_widget row, layout:
#   discard
# do:
#   arrange_layout:
#     arrange_row_or_column(y, h, id)

# decl_widget column, layout:
#   discard
# do:
#   arrange_layout:
#     arrange_row_or_column(x, w, id)

# decl_widget scrollable, layout:
#   discard
# do:
#   var 
#     swipeing {.gensym.} = false 
#     yoffset {.gensym.} = 1.0
#     oldy {.gensym.}= 0.0
#   arrange_layout:
#     for child in self.children:
#       child.y = float32 yoffset
#   events:
#     mouse_leave:
#       swipeing = false
#     button_press:
#       if event.button == 1:
#         swipeing = true
#       if event.button == 5:
#         yoffset = yoffset + 8
#       elif event.button == 4:
#         yoffset = yoffset - 8
#       self.queue_redraw()
#     button_release:
#       if event.button == 1:
#         swipeing = false
#     mouse_motion:
#       if swipeing:
#         yoffset = yoffset - (oldy - float event.y)
#         self.queue_redraw()
#       oldy = float event.y

# decl_widget list, row:
#   discard
# do:
#   spacing 5

# decl_widget popup, window:
#   discard
# do:
#   self.is_popup = true

# decl_widget stack, layout:
#   discard
# do:
#   arrange_layout:
#     for node in self.children:
#       if node.visible != true:
#         continue
#       node.fill self

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
