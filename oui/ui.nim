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

when not defined android:
  import nimclipboard/libclipboard
import macros, strutils, glfw
import nanovg except text
export strutils
import types, node, sugarsyntax
import testmyway
import times
import tables

template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
  var tmp = 0.0
  for child in node:
    child.`axis` = tmp
    tmp = tmp + child.`size` + node.spacing

template stack_switch*(node, target: UiNode, animate: untyped) =
  node.trigger_update_attributes()
  for n in node:
    if n.visible:
      n.hide()
  for n in node:
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
    radius 2
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

proc text_box_key_press*(text: var string, event: var UiEvent, password,
    focused: bool, caretIndex: var int) =
  case event.key:
  of keyLeft:
    caretIndex -= 1
  of keyRight:
    caretIndex += 1
  of keyBackspace:
    if text.len() > 0:
      text.delete(text.len() - 1, text.len())
      caretIndex -= 1
    else:
      text.set_len(0)
  else:
    if event.mods.contains(mkShift) or event.mods.contains(mkCapsLock):
      text.insert(event.ch.to_upper(), text.len())
    else:
      text.insert(event.ch.to_lower(), text.len())

decl_style textbox:
  normal: rgb(241, 241, 241)
  border_focus: rgb(41, 41, 41)
  border_normal: rgb(210, 210, 210)
  txt: rgb(100, 100, 100)
  txt_focus: rgb(35, 35, 35)

template textbox*(inner: untyped, textstr: var string, label: string,
    password: bool = false, style: TextboxStyle = textbox_style) =
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
      update:
        vcenter parent
        left parent.left
        padding_left 5
        if password:
          var smth = ""
          for e in textstr:
            smth.add("*")
          str smth
        else:
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
      when not defined android:
        if event.key == keyRightAlt:
          var cb = clipboard_new(nil)
          textstr.add cb.clipboard_text()
          cb.clipboard_free()
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
      for child in self:
        child.y = float32 yoffset + child.y
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
    unfocus:
      self.hide()
    inner

template stack*(inner: untyped) =
  layout:
    arrange_layout:
      for node in self:
        if node.visible != true:
          continue
        node.fill self
    inner

template bargraph*(inner: untyped, data: var seq[tuple[xname: string,
    yname: string]], ycount: float) =
  canvas:
    paint:
      const SCALE = 15
      var
        vg = self.window.vg
        xpos = 25.0 + SCALE
        ypos = self.h - SCALE * 3
        i = 0
        ysc = 0.0
        maxyname = 0.0
      for d in data:
        if maxyname < parse_float(d[1]):
          maxyname = parse_float(d[1])
      var rycount = self.h / maxyname
      echo rycount
      for i in 0..ycount:
        vg.draw_text($ysc, "bauhaus", blue(255), SCALE, 25, ypos)
        ysc += maxyname / ycount
        ypos -= SCALE + 15
      for d in data:
        if i == 0:
          xpos += vg.text_width(data[0][1])
        vg.draw_text(d[0], "bauhaus", blue(255), SCALE, xpos, self.h - SCALE - 5)

        # Bars
        var tw = vg.text_width(d[0])
        vg.beginPath()
        vg.rect(xpos - 5, self.h - 25 - (ycount * parse_float(d[1])), tw + 5,
            ycount * parse_float(d[1]))
        vg.fillColor(red(255))
        vg.fill()

        xpos += vg.text_width(d[0]) + 25
        i.inc
    inner

template calendar_button(label: string) =
  button:
    text:
      str label
      update:
        center parent
    update:
      size 50, self[0].minh * 2


template calendar*(inner: untyped, year, month: int) =
  var cal = initOrderedTable[string, seq[int]]()
  for week in WeekDay:
    let wk = ($week)[0..2]
    cal[wk] = @[]
    for day in 1..get_days_in_month(Month(month), year):
      if get_day_of_week(day, Month(month), year) == week:
        cal[wk].add day

  row:
    text:
      str $Month(month) & " - Year " & $year
    column:
      update:
        h parent.h - parent[0].h * 2
        w parent.w
      for k, v in cal.pairs:
        column:
          w 50
          update:
            h parent.h
          row:
            w 100
            update:
              h parent.h
            calendar_button(k)
            for d in v:
              calendar_button($d)
    inner


  # inner

test_my_way "ui":
  test "calendar":
    row:
      size 1000, 1000
      calendar:
        w parent.w
        h 250
      do: 2021
      do: 3
      calendar:
        w parent.w
        h 250
      do: 2022
      do: 8
      calendar:
        w parent.w
        h 250
      do: 1000
      do: 9
      self.show()
  # test "declarations":
  #   window:
  #     id testapp
  #     size 100, 100
  #     button:
  #       id btn
  #       check parent.id == "testapp"
  #       text:
  #         check parent.id == "btn"
  #     row:
  #       check parent.id == "testapp"
  #     column:
  #       check parent.id == "testapp"
  #     var tt = "f"
  #     textbox:
  #       id txtbx
  #       check self.id == "txtbx"
  #       check parent.id == "testapp"
  #     do: tt
  #     do: "sdf"
  #     bargraph:
  #       discard
  #     check testapp.children.len == 5
  #   testapp.show()
