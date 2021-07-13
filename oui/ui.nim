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
import types, node, sugarsyntax, utils
import times
import tables
import math
import testaid

template arrange_row_or_column*(axis, size: untyped, node: UiNode) =
  var tmp = 0.0
  for child in node:
    child.`axis` = tmp
    tmp = tmp + child.`size` + node.spacing

template stack_switch*(node, target: UiNode, animate: untyped) =
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
    pressed:
      color style.active
      self.queue_redraw()
    released:
      when glfw_supported():
        color style.hover
      when glfm_supported():
        color style.normal
      self.queue_redraw()
    inner

proc text_box_key_press*(text: var string, event: var UiEvent, password,
    focused: bool, caretIndex: var int) =
  when glfw_supported():
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
    discard

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
      str label
      update:
        if textstr.len > 0 or self.parent.has_focus:
          size 11
          left parent.left
          top parent.top
          padding_left 3
          padding_top 3
        else:
          center parent
          size 14
    text:
      size 14
      update:
        bottom parent.bottom
        left parent.left
        padding_left 3
        padding_bottom 3
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
    when glfw_supported():
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
    borderless true
    resizable false
    unfocus:
      self.hide()
    when glfw_supported():
      shown:
        let
          cursorpos = cursor_pos(self.handle)
          windowpos = pos(self.handle)
        self.move(float(windowpos.x + int(cursorpos.x)), float(windowpos.y +
            int(cursorpos.y)))
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
        ypos = self.h
        i = 0
        ysc = 0.0
        maxyname = 0.0
      for d in data:
        if maxyname < parse_float(d[1]):
          maxyname = parse_float(d[1])
      var x = 1.0
      while x <= maxyname:
        if maxyname mod x == 0.0:
          vg.draw_text($x, "bauhaus", blue(255), SCALE, 25, ypos)
          x = x + 1
          ypos -= 20
        else:
          x = x * 2
      for d in data:
        if i == 0:
          xpos += vg.text_width(data[0][1])
        vg.draw_text(d[0], "bauhaus", blue(255), SCALE, xpos, self.h - SCALE - 5)

        # Bars
        var tw = vg.text_width(d[0])
        vg.beginPath()
        vg.rect(xpos - 5, (self.h - ypos) - 25 - (parse_float(d[1])), tw + 5,
            parse_float(d[1]))
        vg.fillColor(red(255))
        vg.fill()

        xpos += vg.text_width(d[0]) + 25
        i.inc
    inner

template logbargraph*(inner: untyped, data: var seq[tuple[xname: string,
    yname: string]]) =
  canvas:
    paint:
      var
        vg = self.window.vg
        xpos = 25.0
        ypos = self.h
      for x in 1..5:
        vg.draw_text($x, "bauhaus", blue(255), 25.0, xpos, ypos)
        ypos -= 5
    inner


template linegraph*(inner: untyped, data: var seq[tuple[name: string,
    specific: string]], ycount: float) =
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
        total = 0.0
        dpoint = 0.0
      for d in data:
        total += parse_float(d[1])
        if maxyname < parse_float(d[1]):
          maxyname = parse_float(d[1])
      var rycount = self.h / maxyname
      for i in 0..ycount:
        ysc = round(ysc)
        vg.draw_text($ysc, "bauhaus", blue(255), SCALE, 25, ypos)
        ysc += maxyname / ycount
        ypos -= SCALE + 15
      for d in data:
        if i == 0:
          xpos += vg.text_width(data[0][1])
        vg.draw_text(d[0], "bauhaus", blue(255), SCALE, xpos, self.h - SCALE - 5)
        # Data Points
        var tw = vg.text_width(d[0])
        vg.beginPath()
        vg.circle(xpos - 5, total - parse_float(d[1]), 4)
        vg.fillColor(red(255))
        vg.fill()
        if i < (ycount - 1):
          #dpoint is a variable name for "data point"
          dpoint = total - parse_float(d[1])
          vg.beginPath()
          vg.moveTo(xpos - 5, dpoint)
          vg.strokeColor(rgb(0, 160, 192))

          xpos += vg.text_width(d[0]) + 25

          vg.lineTo(xpos - 5, total - parse_float(data[i + 1][1]))
          vg.strokeWidth(3.0)
          vg.stroke()
        i.inc
    inner

template calendar_button(inner: untyped, label: string, widget: UiNode) =
  button:
    text:
      str label
      size 11
      update:
        center parent
    update:
      size widget.w / 7, widget.h / 6
    inner

proc add_days_for_week_day(cal: var OrderedTable[string, seq[int]],
    week: WeekDay, month: int, year: int) =
  let wk = ($week)[0..2]
  cal[wk] = @[]
  for day in 1..get_days_in_month(Month(month), year):
    if get_day_of_week(day, Month(month), year) == week:
      cal[wk].add day

template calendar*(inner: untyped, year, month: int, cb: proc(day, month, year: int)) =
  var cal = initOrderedTable[string, seq[int]]()
  var
    first = get_day_of_week(1, Month(month), year)
    first_yet = false
    offsetdays: seq[WeekDay]
  for week in WeekDay:
    if first == week:
      first_yet = true
    if first_yet == false:
      offsetdays.add(week)
      continue
    add_days_for_week_day(cal, week, month, year)
  for weekday in offsetdays:
    add_days_for_week_day(cal, weekday, month, year)
  row:
    var widget = self
    text:
      str $Month(month) & " - Year " & $year
      size 15
      update:
        hcenter parent
    spacing 5
    column:
      update:
        h parent.h - parent[0].h
        w parent.w
      for k, v in cal.pairs:
        column:
          update:
            w widget.w / 7
            h parent.h
          row:
            update:
              w widget.w / 7
              h parent.h
            calendar_button:
              discard
            do: k
            do: widget
            for d in v:
              calendar_button:
                pressed:
                  cb(parse_int(self[0].str), month, year)
              do: $d
              do: widget
    inner

testaid:
  test "button":
    button:
      size 200, 40
      pressed:
        if not self.window.is_nil():
          self.window.hide()
      text:
        str "Tap to close"
        update:
          center parent
      self.show()

  test "textbox":
    var txtstr = ""
    textbox:
      size 200, 40
      self.show()
    do: txtstr
    do: "Txtstr label"

  test "row":
    row:
      size 200, 500
      for i in 1..3:
        box:
          size parent.w, 50
      self.show()
  test "column":
    column:
      size 500, 200
      for i in 1..3:
        box:
          size 50, parent.h
      self.show()

  test "calendar":
    calendar:
      update:
        size 1000, 1000
      self.show()
    do: 2011
    do: 3
    do: (proc(day, month, year: int) = discard)

  test "logbargraph":
    var data = @[
      ("Monday", "55"),
      ("Tuesday", "104"),
      ("Wednesday", "35"),
      ("Thursday", "65"),
      ("Friday", "51"),
      ("Saturday", "93")
    ]
    logbargraph:
      size 500, 500
      self.show()
    do: data
