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
import nanovg
import json

proc glfm_supported*(): bool =
  if defined android:
    true
  else:
    false

proc glfw_supported*(): bool =
  if glfm_supported():
    false
  elif defined(windows):
    true
  elif defined(linux):
    true
  else:
    false

when glfw_supported():
  import nimgl/glfw

when glfm_supported():
  import glfm/glfm

type
  UiEventKind* = enum
    UiMousePress, UiMouseRelease, UiKeyPress, UiKeyRelease,
    UiMouseMotion, UiExpose, UiResize, UiEnter, UiLeave,
    UiFocus, UiUnfocus, UiTouch

  UiEvent* = object
    case kind*: UiEventKind
    of UiKeyPress, UiKeyRelease:
      when glfw_supported():
        key*: int32
        mods*: int32
      ch*: string
    of UiTouch:
      when glfm_supported():
        phase*: GLFMTouchPhase
    of UiMousePress, UiMouseRelease:
      when glfw_supported():
        button*: int32
      discard
    else:
      discard
    x*, y*: float

  UiEventCallback* = proc(ev: UiEvent) {.gcsafe.}

  UiAnchor* = distinct float32

  UiAlignment* = enum
    UiRight, UiCenter, UiLeft
    UiTop, UiBottom

  UpdateAttributesCb* = proc(self, parent: UiNode)
  ArrangeLayoutCb* = proc(self, parent: UiNode)
  OnEventCb* = proc(self, parent: UiNode; event: var UiEvent)
  DrawPostCb* = proc(self, parent: UiNode)
  RenderCb* = proc(self, parent: UiNode)
  PaintCb* = proc(self, parent: UiNode; vg: NVGContext)
  ShownCb* = proc(self, parent: UiNode)
  HiddenCb* = proc(self, parent: UiNode)

  UiNodeKind* = enum
    UiWindow, UiBox, UiText,
    UiImage, UiCanvas, UiLayout,
    UiOpenGl, UiEmbedded

  UiNode* = ref object
    parent*, window*: UiNode
    children*: seq[UiNode]
    id*: string
    x*, y*, w*, h*: float32
    minw*, minh*: float32
    rootx*, rooty*: float
    padding_top*, padding_left*, padding_bottom*, padding_right*: float32
    margin_top*, margin_left*, margin_bottom*, margin_right*: float32
    json_array*: JsonNode
    delegate*: proc(table: JsonNode; index: int): UiNode
    visible*, force_redraw*, animating*: bool
    hovered*, has_focus*, accepts_focus*: bool
    update_attributes*: seq[UpdateAttributesCb]
    event*: seq[OnEventCb]
    draw_post*: seq[DrawPostCb]
    shown*: seq[ShownCb]
    hidden*: seq[HiddenCb]
    index*: int
    color*: Color
    opacity*: range[0f..1f]
    left_anchored*, top_anchored*: bool
    oldw*, oldh*: float32
    gradient*: tuple[sx, sy, ex, ey: float; active: bool; color1, color2: Color]
    radius*: float32
    case kind*: UiNodeKind
    of UiWindow:
      when glfw_supported():
        handle*: GLFWWindow
      vg*: NVGContext
      title*: string
      exposed*, is_popup*: bool
      focused_node*: UiNode
      resizing*, resizable*, borderless*: bool
      cursor_pos*: tuple[x, y: float]
      gl_nodes*: seq[UiNode]
    of UiBox:
      border_width*: float32
      border_color*: Color
      shadow*: tuple[enabled: bool, col1, col2: Color,
        blur, h_offset, v_offset: float]
    of UiText:
      str*, face*: string
      size*: float32
      valign*, halign*: UiAlignment
    of UiCanvas:
      paint*: seq[PaintCb]
    of UiLayout:
      spacing*: float32
      arrange_layout*: seq[ArrangeLayoutCb]
    of UiImage:
      src*: string
      data*: Image
      datapaint*: Paint
    of UiOpenGl:
      render*: seq[RenderCb]
    of UiEmbedded:
      winid*: int64

