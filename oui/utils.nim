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


import colors, strutils
import cairo, private/[pango, glib2]
import types

proc rectangle*(ctx: ptr Context, node: UiNode) =
  ## Wraps cairo's rectangle using the node's geometry
  ctx.rectangle(
    node.x,
    node.y,
    node.w,
    node.h)

proc set_source_color*(ctx: ptr Context, color: Color, opacity: range[0f..1f] = 1f) =
  ## Wraps cairo's set_source_rgba using color and opacity
  var rgb = extract_rgb(color)
  ctx.set_source_rgba(rgb.r / 256,
                      rgb.g / 256,
                      rgb.b / 256,
                      opacity)

proc draw_png*(ctx: ptr Context, src: string, x, y, w, h: float) =
  var 
    img = image_surface_create_from_png(src)
    imgw = float img.get_width()
    imgh = float img.get_height()
  ctx.scale(w / imgw, h / imgh)
  ctx.set_source(img, x, y)
  ctx.paint()
  img.destroy()

proc draw_rounded_rectangle*(ctx: ptr Context, color: Color, opacity, x, y, w,
    h, rad, border_width: float32, border_color: Color) =
  ctx.set_source_color(color, opacity)
  var degrees = 3.14 / 180
  ctx.new_sub_path()
  ctx.arc(x + w - rad, y + rad, rad, -90 * degrees, 0 * degrees)
  ctx.arc(x + w - rad, y + h - rad, rad, 0 * degrees, 90 * degrees)
  ctx.arc(x + rad, y + h - rad, rad, 90 * degrees, 180 * degrees)
  ctx.arc(x + rad, y + rad, rad, 180 * degrees, 270 * degrees)
  ctx.close_path()
 
  var path = ctx.copy_path()
  ctx.fill()
  if border_width <= 0:
    return
  ctx.set_source_color(border_color, opacity)
  ctx.append_path(path)
  ctx.set_line_width(border_width)
  ctx.stroke()
  path.destroy()
  
template text_vars(ctx: ptr Context, text, family: string) {.dirty.} =
  var
    layout = pango_cairo_create_layout(ctx)
    font_desc = font_description_from_string(cstring family)
  layout.set_font_description(font_desc)
  layout.set_text(cstring text, -1)

template text_vars_free() =
  layout.free()
  font_desc.free()

proc text_pixel_size*(ctx: ptr Context, text, family: string): tuple[w, h: float32] =
  text_vars(ctx, text, family)

  var ink, logical: pango.TRectangle
  layout.get_pixel_extents(addr ink, addr logical)
  result.w = float32 ink.width
  result.h = float32 ink.height

  text_vars_free()

proc draw_text*(ctx: ptr Context, text, family: string, color: Color, opacity,
    x, y: float32) =
  text_vars(ctx, text, family)

  ctx.move_to(x, y)
  ctx.set_source_color(color, opacity)
  pango_cairo_update_layout(ctx, layout)
  pango_cairo_show_layout(ctx, layout)

  text_vars_free()

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

template ouidebug*[T](t: T) =
  ## Wraps `echo` to remove the statement when -d:ouidebug isn't defined
  when defined ouidebug: 
    echo t
