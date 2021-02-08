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

template stack_view_switch*(node, target: UiNode, animate: untyped) =
  for n in node.children:
    if n.visible == true and n != target:
      n.visible = false
    if n == target:
      n.visible = true
      animate

decl_style button: 
  normal: "#212121"
  hover: "#313113"
  active: "#555555"
template button*(id, inner:untyped, style: ButtonStyle = button_style) = 
  box id:
    color style.normal
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
    inner
template button*(inner: untyped) =
  node_without_id button, inner

template text_box*(id, inner: untyped, password: bool = false) = 
  var
    shift {.gensym.} = false
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
template text_box*(inner: untyped) =
  node_without_id text_box, inner

template row*(id, inner: untyped) = 
  layout id:
    arrange_layout:
      arrange_row_or_column(y, h, id)
    inner
template row*(inner: untyped) {.dirty} =
  node_without_id row, inner

template column*(id, inner: untyped) =
  layout id:
    arrange_layout:
      arrange_row_or_column(x, w, id)
    inner
template column*(inner: untyped) =
  node_without_id column, inner

template swipe_view*(id, inner: untyped) = 
  var 
    swipeing {.gensym.} = false 
    yoffset {.gensym.} = 0
    pos {.gensym.} = (x: 0, y: 0)
  layout id:
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
    inner
template swipe_view*(inner: untyped) =
  node_without_id swipe_view, inner

template list_view*(id, inner: untyped) =
  row id:
    discard
    inner
template list_wiew*(inner: untyped) =
  node_without_id list_view, inner

template popup*(id, inner: untyped) =
  window id:
    self.is_popup = true
    inner
template popup*(inner: untyped) =
  node_without_id popup, inner

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

template stack_view*(id, inner: untyped) =
  layout id:
    arrange_layout:
      for node in self.children:
        if node.visible != true:
          continue
        node.fill self
template stack_view*(inner: untyped) =
  node_without_id stack_window, inner

when defined(testing) and is_main_module:
  import unittest
  import model, tables, math, utils
  import animation

  window app:
    title "Test App"
    size 600, 400
    stack_view my_page:
      update:
        size parent.w / 2, parent.h
      box box1:
        update:
          fill parent
        color "#ff0000"
        visible true # node shown by default
      box box2:
        update:
          fill parent
        color "#00ff00"
        visible false # node hidden by default
      box box3:
        update:
          fill parent
        color "#0000ff"
        visible true # the node hidden by default
    button:
      update:
        w parent.w / 2
        top parent.top
        bottom parent.bottom
        right parent.right
      events:
        button_press:
          echo $self.name & " was pressed " & $event.button         
      text:
        update:
          fill parent
        text "Click me"
  app.show()  
  oui_main()
