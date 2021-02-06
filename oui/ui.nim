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

proc text_box_key_press*(text: var string, key: int, ch: string, shift: var bool, password, focused: bool) =
  if key == 65505:
    shift = true
  if focused:
    case key:
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
        if shift:
          text.add(ch.to_upper())
        else:
          text.add(ch)
    #root.queue_redraw(self)

proc text_box_key_release*(key: int, shift: var bool) = 
  if key == 65505:
    shift = false

template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
  var tmp = 0.0
  echo node.children.len
  for child in node.children:
    child.`axis` = tmp
    tmp = tmp + child.`size` + node.spacing

template button*(id, inner: untyped) {.dirty.} = 
  box:
    color "#212121"
    events:
      mouse_motion:
        echo "Motion " & $event.x & ":" & $event.y

template button*(inner: untyped) {.dirty} =
  button node_without_id(), inner

template text_box*(id, inner: untyped) {.dirty.} = 
  var
    shift {.gensym.} = false
    password {.gensym.} = false
  text id:
    halign UiRight
    color "#cccccc"
    box:
      color "#252525"
      update:
        fill parent
    events:
      key_press:
        text_box_key_press(id.text, event.key, event.ch, shift, password, focused)      
      key_release:
        text_box_key_release(event.key, event.ch)

template text_box*(inner: untyped) {.dirty} =
  node_without_id text_box, inner

template row*(id, inner: untyped) {.dirty.} = 
  layout id:
    arrange_layout:
      arrange_row_or_column(y, h, id)
    inner

template row*(inner: untyped) {.dirty} =
  node_without_id row, inner

template column*(id, inner: untyped) {.dirty.} =
  layout id:
    arrange_layout:
      arrange_row_or_column(x, w, id)
    inner

template column*(inner: untyped) {.dirty.} =
  node_without_id column, inner

template list_window*(id, inner: untyped) {.dirty.} =
  row id:
    discard
    inner

template list_window*(inner: untyped) {.dirty.} =
  node_without_id list_window, inner

template popup*(id, inner: untyped) {.dirty.} =
  window id:
    self.is_popup = true
    inner

template popup*(inner: untyped) {.dirty.} =
  popup node_without_id(), inner

template combo_box*(id, inner: untyped) =
  var up {.gensym.}: UiNode
  text_box id:
    popup:
      up = self
      size 150, 400
      list_window list:
        update:
          fill parent
    events:
      button_press:
        up.show()
        up.engine.move_window(ev.xroot, ev.yroot)

template combo_box*(inner: untyped) =
  node_without_id text_box, inner

template stack_window*(id, inner: untyped) {.dirty.} =
  layout id:
    events:
      key_press:
        discard
        #root.queue_redraw(id, false)

template stack_window*(inner: untyped) {.dirty.} =
  node_without_id stack_window, inner

when defined(testing) and is_main_module:
  import unittest
  import model, tables, math, utils
  window app:
    title "Test App"
    size 600, 400
  app.show()  
  oui_main()
