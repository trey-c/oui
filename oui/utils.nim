# Copyright © 2020 Trey Cutter <treycutter@protonmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import strutils, terminal, os, json
export terminal
import nanovg
when defined android:
  import glfm/glfm
  import android/extras/pathutils
  import android/content/res/asset_manager
  import android/content/context
  import android/ndk/aasset_manager
  import jnim

import sequtils, json

proc filter*(jarray: JsonNode, cb: proc(j: JsonNode): bool): JsonNode =
  %* jarray.getElems().filter(proc(j: JsonNode): bool = cb(j))

proc draw_text*(vg: NVGContext, text, face: string, color: Color, size,
    x, y: float32) =
  vg.beginPath()
  vg.fontSize(size)
  vg.fontFace(face)
  vg.fillColor(color)
  vg.textAlign(haLeft, vaTop)
  discard vg.text(x, y, text)

proc draw_rounded_rectangle*(vg: NVGContext, color: Color, opacity, x, y, w,
    h, rad, border_width: float32, border_color: Color) =
  vg.beginPath()
  vg.roundedRect(x, y, w, h, rad)
  vg.fillColor(color)
  vg.fill()

  if border_width < 0:
    return
  vg.beginPath()
  vg.roundedRect(x, y, w, h, rad)
  vg.strokeColor(border_color)
  vg.stroke()

proc draw_image*(vg: NVGContext, path: string, w, h: float) =
  # vg.beginPath()
  # var img = vg.image_pattern(0, 0, 50, 50, 0, vg.createImage(path), 1)
  # vg.rect(0, 0, 50, 50)
  # vg.fill_paint(img)
  # vg.fill()
  discard

proc str_to_camel_case*(
  str: string): string =
  var go_up = false
  for c in str:
    if go_up:
      result.add(
          c.to_upper_ascii())
      go_up = false
      continue
    if c == '_':
      go_up = true
    else:
      result.add(c)

template oui_debug*[T](t: T) =
  ## Wraps `styled_echo` when -d:release isnt defined
  when defined releease:
    styled_echo fgGreen, "oui_debug  ", resetStyle, t

template oui_warning*[T](t: T) =
  ## Wraps `styled_echo`
  styled_echo fgYellow, "oui_warning ", resetStyle, t

template oui_error*[T](t: T) =
  ## Wraps `styled_echo` with an error prefix
  styled_echo fgRed, "oui_error ", resetStyle, t

template oui_log*[T](t: T) =
  ## Wraps `styled_echo` with a log prefix.
  styled_echo fgMagenta, "oui_log ", resetStyle, t

proc load_font_by_name*(vg: NVGContext, name: string) {.exportc.} =
  ## Loads from oui's default font locatio
  when defined windows:
    var loc = get_home_dir() & ".oui\\fonts\\" & name & ".ttf"
  when defined android:
    var loc = "font/" & name & ".ttf"
    var fileasset = open(glfmAndroidGetActivity().asset_manager, "font/" &
        name & ".ttf", AASSET_MODE_BUFFER)
    try:
      var buf = cast[ptr UncheckedArray[byte]](fileasset.getBuffer())
      var font = vg.createFontMem(name, toOpenArray[byte](buf, 0,
          fileasset.getLength()))
      discard addFallbackFont(vg, font, font)
    except:
      echo "Couldn't load font: @" & loc
  elif defined linux:
    var loc = get_home_dir() & ".oui/fonts/" & name & ".ttf"
  when not defined android:
    try:
      var font = vg.createFont(name, loc)
      discard addFallbackFont(vg, font, font)
    except:
      echo "Couldn't load font: @" & loc
