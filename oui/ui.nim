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

template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
  var tmp = 0.0
  for child in node.children:
    child.`axis` = tmp
    tmp = tmp + child.`size` + node.spacing

template stack_switch*(node, target: UiNode, animate: untyped) =
  node.trigger_update_attributes()
  for n in node.children:
    if n.visible:
      n.hide()
  for n in node.children:
    if n == target:
      n.show()
      animate
      break
  node.queue_redraw()

decl_style button: 
  normal: rgb(241, 241, 241)
  hover: rgb(200, 200, 200)
  active: rgb(100, 100, 100)
  border: rgb(210, 210, 210)

template button*(inner: untyped, style: ButtonStyle = button_style) =
  box:
    color style.normal
    radius 10
    border_width 2
    border_color style.border
    mouse_enter:
      color style.hover
      self.queue_redraw()
    mouse_leave:
      color style.normal
      self.queue_redraw()
    mouse_press:
      color style.active
      self.queue_redraw()
    mouse_release:
      color style.hover
      self.queue_redraw()
    inner

proc text_box_key_press*(text: var string, event: var UiEvent, password, focused: bool, caretIndex: var int) =
  case event.key:
  of keyLeft:
    caretIndex -= 1
  of keyRight:
    caretIndex += 1
  of keyBackspace:
    text.delete(caretIndex, caretIndex)
    caretIndex -= 1
  of keySpace:
    if password:
      text.add("*")
    else:
      text.add(" ")
  else:
    if password:
      text.add("*")
    else:
      caretIndex.inc
      if event.mods.contains(mkShift) or event.mods.contains(mkCapsLock):
        text.insert(event.ch.to_upper(), caretIndex)
      else:
        text.insert(event.ch.to_lower(), text.len)

decl_style textbox: 
  normal: rgb(241, 241, 241)
  border_focus: rgb(41, 41, 41)
  border_normal: rgb(210, 210, 210)
  txt: rgb(100, 100, 100)
  txt_focus: rgb(35, 35, 35)

template textbox*(inner: untyped, textstr: var string, label: string, password: bool = false, style: TextboxStyle = textbox_style) =
  var 
    caretX = 0.0
    caretIndex = 0
    glyphs: array[100, GlyphPosition]
    nglyphs = 0
  box:
    accepts_focus true
    border_width 2
    color style.normal
    border_color style.border_normal

    text: 
      size 15
      face "sans"
      halign UiLeft
      valign UiCenter
      update:
        fill parent
        str textstr
        if parent.has_Focus:
          color style.txt_focus
        else:
          color style.txt
      mouse_press:
        nglyphs = self.window.vg.textGlyphPositions(self.x, self.y, textstr,
                                            0, textstr.len - 1, glyphs)
        for j in 0..<nglyphs:
          if event.x <= glyphs[j + 1].x and event.x >= glyphs[j].x:
            caretX = glyphs[j].x
            caretIndex = j
    focus:
      border_color style.border_focus
      self.queue_redraw()
    unfocus:
      border_color style.border_normal
      self.queue_redraw()
    key_press:
      if self.has_focus == false:
        return
      text_box_key_press(textstr, event, password, self.has_focus, caretIndex)
      self.queue_redraw()
    draw_post:
      
      var vg = self.window.vg
      vg.beginPath()
      for j in 0..<nglyphs:
        if caretIndex == j:
          caretX = glyphs[j].x
      vg.rect(caretX, 0, 1.5, self.minh)
      vg.fillColor(rgb(0, 0, 250))
      vg.fill()
    inner

template combobox*(inner: untyped) =
  var ppp: UiNode
  popup:
    ppp = self
    delegate text, UiText:
      str "idk"
  textbox:
    mouse_press:
      up.show()
      up.move_window(ev.xroot, ev.yroot)
    inner

template row*(inner: untyped) = 
  layout:
    arrange_layout:
      arrange_row_or_column(y, h, self)
    inner

template column*(inner: untyped) = 
  layout:
    arrange_layout:
      arrange_row_or_column(x, w, self)
    inner

template scrollable*(inner: untyped) =
  var 
    swiping = false 
    yoffset = 1.0
    mousey = 0.0
  layout:
    arrange_layout:
      for child in self.children:
        child.y = float32 yoffset
    mouse_leave:
      swiping = false
    mouse_press:
      if event.button == mb1:
        swiping = true
      if event.button == mb4:
        yoffset = yoffset + 8
      elif event.button == mb5:
        yoffset = yoffset - 8
      self.queue_redraw()
    mouse_release:
      if event.button == mb1:
        swiping = false
    mouse_motion:
      if swiping:
        yoffset = yoffset - (mousey - float event.y)
        self.queue_redraw()
      mousey = float event.y
    inner

template list*(inner: untyped) =
  scrollable:
    arrange_layout:
      arrange_row_or_column(y, h, self)
    inner

template popup*(inner: untyped) = 
  window:
    self.is_popup = true
    mouse_leave:
      self.hide()
    inner

template stack*(inner: untyped) =
  layout:
    arrange_layout:
      for node in self.children:
        if node.visible != true:
          continue
        node.fill self
    inner

test_my_way "ui":
  test "declarations":
    box:
      id box1
      button:
        id btn
        check parent.id == "box1"
        text:
          check parent.id == "btn"
      row:
        check parent.id == "box1"
      column :
        check parent.id == "box1"
      var tt = "f"
      textbox:
        id txtbx
        check self.id == "txtbx"
        check parent.id == "box1"
      do: tt
      check box1.children.len == 4
