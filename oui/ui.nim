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

import macros, strutils, nimgl/glfw
import nanovg except text
import types, node, sugarsyntax, utils
import times
import tables
import math
import testaid
import json

template arrange_row_or_column*(min1, min2, axis, size: untyped, node: UiNode) =
  node.`min1` = 0
  node.`min2` = 0
  var
    tmp = 0.0
    i = 0
  for child in node:
    i.inc
    node.`min1` = if node.`min1` < child.`min1`: child.`min1` else: node.`min1`
    if i == node.children.len:
      node.`min2` += child.`min2`
    else:
      node.`min2` += child.`min2` + self.spacing + 1

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

ui_theme["button.normal"] = rgb(241, 241, 241)
ui_theme["button.hover"] = rgb(200, 200, 200)
ui_theme["button.active"] = rgb(130, 130, 130)

template button*(inner: untyped) =
  box:
    color ui_theme["button.normal"]
    radius 2
    mouse_enter:
      color ui_theme["button.hover"]
      self.queue_redraw()
    mouse_leave:
      color ui_theme["button.normal"]
      self.queue_redraw()
    pressed:
      color ui_theme["button.active"]
      self.queue_redraw()
    released:
      when glfw_supported():
        color ui_theme["button.hover"]
      when glfm_supported():
        color ui_theme["button.normal"]
      self.queue_redraw()
    inner
                                 
proc text_box_key_press*(text: var string, event: var UiEvent, password,
    focused: bool, caretIndex: var int) =
  when glfw_supported():
    case event.key:
    of GLFWKey.Left:
      caretIndex -= 1
    of GLFWKey.Right:
      caretIndex += 1
    of GLFWKey.Backspace:
      if text.len() > 0:
        text.delete(text.len() - 1, text.len())
        caretIndex -= 1
      else:
        text.set_len(0)
    else:
      if event.mods == GLFWKey.LeftShift or event.mods == GLFWKey.Capslock:
        text.insert(event.ch.to_upper(), text.len())
      else:
        text.insert(event.ch.to_lower(), text.len())
    discard

ui_theme["textbox.normal"] = rgb(241, 241, 241)
ui_theme["textbox.txt"] = rgb(100, 100, 100)
ui_theme["textbox.txt_focus"] = rgb(35, 35, 35)
ui_theme["textbox.carret"] = rgb(11, 11, 11)

template textbox*(inner: untyped, textstr: var string, label: string,
    password: bool = false) =
  var
    caretX = 0.0
    caretIndex = 0
    glyphs: array[100, GlyphPosition]
    nglyphs = 0
  box:
    accepts_focus true
    color ui_theme["textbox.normal"]
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
          color ui_theme["textbox.txt_focus"]
        else:
          color ui_theme["textbox.txt"]
      mouse_press:
        nglyphs = self.window.vg.textGlyphPositions(self.x, self.y, textstr,
                                            0, textstr.len - 1, glyphs)
        for j in 0..<nglyphs:
          if event.x <= glyphs[j + 1].x and event.x >= glyphs[j].x:
            caretX = glyphs[j].x
            caretIndex = j
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
      vg.fillColor(ui_theme["textbox.carret"])
      vg.fill()
    inner

template combobox*(inner: untyped, jarray: JsonNode, label: string) =
  block:
    var
      comstr = "sh"
    textbox:
      id txtbx
      popup:
        id up

        size 150, 200
        visible false
        self.event.set_len 0
        self.shown.set_len 0
        shown:
          var pos = txtbx.real_root_coords()
          self.resize(txtbx.w, up.h)
          self.move(float pos.x, float(pos.y) + txtbx.h)
          txtbx.window.request_focus(txtbx)
        row:
          json_array jarray
          update:
            fill parent
          spacing 10
          delegate:
            text:
              result = self
              str jarray[index].get_str()
      hidden:
        if up.visible:
          up.hide()
      key_press:
        var ok = false
        for j in jarray:
          if j.get_str().to_lower().contains(comstr.to_lower()):
            ok = true

        if ok:
          up[0].set_j_array jarray.filter(proc(j: JsonNode): bool =
            j.get_str().to_lower().contains(comstr.to_lower())
          )
          # comstr.delete(comstr.high, comstr.high)
          up[0].show()
      pressed:
        up.show()

      inner
    do: comstr
    do: label

template row*(inner: untyped) =
  layout:
    arrange_layout:
      arrange_row_or_column(minw, minh, y, h, self)
    inner

template column*(inner: untyped) =
  layout:
    arrange_layout:
      arrange_row_or_column(minh, minw, x, w, self)
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
        if event.button == 1:
          swiping = true
        if event.button == 4:
          yoffset = yoffset + 8
        elif event.button == 5:
          yoffset = yoffset - 8
        self.queue_redraw()
      mouse_release:
        if event.button == 1:
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
      arrange_row_or_column(minw, minh, y, h, self)
    inner

template popup*(inner: untyped) =
  window:
    self.is_popup = true
    borderless true
    resizable false
    unfocus:
      self.hide()
    # when glfw_supported():
    #   shown:
    #     let
    #       cursorpos = cursor_pos(self.handle)
    #       windowpos = pos(self.handle)
    #     self.move(float(windowpos.x + int(cursorpos.x)), float(windowpos.y +
    #         int(cursorpos.y)))
    inner

template stack*(inner: untyped) =
  layout:
    arrange_layout:
      for node in self:
        if node.visible != true:
          continue
        node.fill self
    inner

template bargraph*(inner: untyped, num_of_ys: int = 4, scale: float = 25.0) =
  canvas:
    inner
    assert not self.json_array.is_nil()
    paint:
      var
        vg = self.window.vg
        ypos = self.h
        max_yval = 0.0
        ysc = 0.0
        xpos = scale * 2.0
      for jobj in self.json_array:
        var yval = float jobj["yval"].get_int()
        max_yval = if yval > max_yval: yval else: max_yval

      # Draw y axis vals
      for i in 0..num_of_ys - 1:
        ysc += max_yval / float num_of_ys
        ypos -= (self.h) / float(num_of_ys)
        vg.draw_text($(int ysc), "bauhaus", blue(255), scale, 0, ypos)

      # Draw x axis words
      for jobj in self.json_array:
        var
          yval = float jobj["yval"].get_int()
          xname = jobj["xname"].get_str()
          txtwidth = vg.text_width(xname)
        vg.draw_text(xname, "bauhaus", blue(255), scale,
            xpos, self.h - scale)

        # Drawing bars
        var
          bottomy = self.h - scale
        vg.beginPath()
        vg.rect(xpos, bottomy, txtwidth, -(bottomy) * (yval / max_yval))
        vg.fillColor(red(255))
        vg.fill()

        xpos += txtwidth + scale

template linegraph*(inner: untyped, ycount: float) =
  canvas:
    inner
    assert not self.json_array.is_nil()
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
      for jobj in self.json_array:
        total += jobj["yval"].get_float()
        if maxyname < jobj["yval"].get_float():
          maxyname = jobj["yval"].get_float()
      var rycount = self.h / maxyname
      
      for i in 0..ycount:
        ysc = round(ysc)
        vg.draw_text($ysc, "bauhaus", blue(255), SCALE, 3.0 * 25, ypos)
        ysc += maxyname / ycount
        ypos -= SCALE + 15
      for jobj in self.json_array:
        vg.draw_text(jobj["xname"].get_str(), "bauhaus", blue(255), SCALE, xpos, self.h - SCALE - 5)
        # Data Points
        var tw = vg.text_width(jobj["xname"].get_str())
        vg.beginPath()
        vg.circle(xpos - 5, total - jobj["yval"].get_float(), 4)
        vg.fillColor(red(255))
        vg.fill()
        if i < (ycount - 1):
          #dpoint is a variable name for "data point"
          dpoint = total - jobj["yval"].get_float()
          vg.beginPath()
          vg.moveTo(xpos - 5, dpoint)
          vg.strokeColor(rgb(0, 160, 192))

          xpos += vg.text_width(jobj["xname"].get_str()) + 25

          vg.lineTo(xpos - 5, total - self.json_array[i + 1]["yval"].get_float())
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
  test "bargraph":
    bargraph:
      pressed:
        echo $ui_theme
      json_array ( %* [
        {"xname": "Apple", "yval": 49},
        {"xname": "Grape", "yval": 29},
        {"xname": "Orange", "yval": 299},
        {"xname": "Pair", "yval": 2},
        {"xname": "Pair", "yval": 2},
        {"xname": "Pair", "yval": 2},
        {"xname": "Pair", "yval": 140},
        {"xname": "Pair", "yval": 2},
        {"xname": "Pair", "yval": 2},
      ])
      minw 400
      minh 300
      self.show()
    do: 8
    do: 20.0

  test "linegraph":
    linegraph:
      json_array ( %* [
        {"xname": "Apple", "yval": 49},
        {"xname": "Grape", "yval": 29},
        {"xname": "Orange", "yval": 299},
      ])
      minw 400
      minh 300
      self.show()
    do: 8

  test "combobox":
    var customers = %* ["Sheridan", "Apples", "Meridan Hotel? Tavigo"]
    combobox:
      size 150, 40
      self.show()
    do: customers
    do: "cool text box"

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
      spacing 20
      for i in 1..8:
        box:
          color green(255)
          minw(40.0 * float(i))
          minh(40.0)
      self.show()

  test "column":
    column:
      spacing 20
      for i in 1..8:
        box:
          color green(255)
          minh(40.0 * float(i))
          minw(40.0)
      self.show()

  test "calendar":
    calendar:
      update:
        size 1000, 1000
      self.show()
    do: 2011
    do: 3
    do: (proc(day, month, year: int) = discard)
