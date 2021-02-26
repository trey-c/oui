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

import tables, strutils
import cairo as cairo
import colors, macros

when defined linux:
  import
    x11/x
elif defined android:
  import private/egl
elif defined windows:
  import winim

type
  UiNative* = ref object
    ctx*: ptr cairo.Context
    surface*: ptr Surface
    width*, height*: int
    received_event*: proc(ev: UiEvent) {.gcsafe.}
    when defined(linux):
      xwindow*: Window
    when defined(android):
      eglsurface*: EGLSurface
    when defined(windows):
      trackx*, tracky*: int
      hwnd*: HWND

  UiEventKind* = enum
    UiEventMousePress, UiEventMouseRelease, UiEventKeyPress, UiEventKeyRelease, 
    UiEventMouseMotion, UiEventExpose, UiEventResize, UiEventEnter, UiEventLeave,
    UiEventFocus, UiEventUnfocus

  UiEvent* = object
    case kind*: UiEventKind
    of UiEventKeyPress, UiEventKeyRelease:
      key*: int
      caps_lock_state*, shift_state*, num_lock_state*: bool  
      ch*: string
    of UiEventExpose, UiEventResize:
      w*, h*: int
    of UiEventMouseMotion, UiEventMousePress, UiEventMouseRelease:
      button*, xroot*, yroot*: int
    else:
      discard
    x*, y*: int
    native*: UiNative
    
  UiEventCallback* = proc(ev: UiEvent) {.gcsafe.}

type
  UiTableRow* = OrderedTable[int, string]

  UiTable* = ref object
    list*: seq[UiTableRow]
    count*: int
    table_added*, table_removed*: proc(index: int)

type
  UiAnchor* = distinct float32

  UiAlignment* = enum
    UiRight, UiCenter, UiLeft
    UiTop, UiBottom

  UpdateAttributesCb* = proc(self, parent: UiNode)
  ArrangeLayoutCb* = proc(self, parent: UiNode)
  OnEventCb* = proc(self, parent: UiNode, event: var UiEvent)
  DrawPostCb* = proc()

  UiNodeKind* = enum
    UiWindow, UiBox, UiText,
    UiImage, UiCanvas, UiLayout

  UiNode* = ref object
    parent*, window*: UiNode
    surface*: ptr cairo.Surface
    children*: seq[UiNode]
    id*: string
    x*, y*, w*, h*: float32
    padding_top*, padding_left*, padding_bottom*, padding_right*: float32
    table*: UiTable
    clip*, visible*, hovered*, has_focus*, accepts_focus*, animating*,
        need_redraw*, force_redraw*: bool
    update_attributes*: seq[UpdateAttributesCb]
    on_event*: seq[OnEventCb]
    draw_post*: seq[DrawPostCb]
    index*: int
    color*: colors.Color
    opacity*: range[0f..1f]
    left_anchored*, top_anchored*: bool
    oldw*, oldh*: float32
    case kind*: UiNodeKind
    of UiBox:
      radius*: float32
      border_width*: float32
      border_color*: colors.Color
    of UiWindow:
      title*: string
      exposed*, is_popup*: bool
      focused_node*: UiNode
      native*: UiNative
    of UiText:
      str*, family*: string
      valign*, halign*: UiAlignment
    of UiCanvas:
      paint*: proc(ctx: ptr cairo.Context)
    of UiLayout:
      spacing*: float32
      delegates: seq[UiNode]
      delegate*: proc(table: UiTable, index: int): UiNode
      arrange_layout*: seq[ArrangeLayoutCb]
    of UiImage:
      src*: string

var
  oui_framecount* = 0
  oui_natives*: seq[UiNative] = @[]

macro exposecb*(x, y, native: untyped) =
  result = parse_stmt("""
$1.received_event((UiEvent(
  kind: UiEventExpose,
  x: $2,
  y: $3,
  w: -1,
  h: -1,
  native: $1)))
""" % [native.repr, x.repr, y.repr])

macro keycb*(kind, x, y, key, ch, native: untyped) =
  result = parse_stmt("""
$1.received_event((UiEvent(
  kind: $6,
  x: $2,
  y: $3,
  key: $4,
  ch: $5,
  native: $1)))
""" % [native.repr, x.repr, y.repr, key.repr, ch.repr, kind.repr])

macro buttoncb*(kind, button, x, y, xroot, yroot, native: untyped) =
  result = parse_stmt("""
$1.received_event((UiEvent(
  kind: $7,
  button: $2,
  x: $3,
  y: $4,
  xroot: $5,
  yroot: $6,
  native: $1)))
 
""" % [native.repr, button.repr, x.repr, y.repr, xroot.repr, yroot.repr, kind.repr])

macro motioncb*(x, y, xroot, yroot, native: untyped) =
  result = parse_stmt("""
$1.received_event((UiEvent(
  kind: UiEventMouseMotion,
  button: -1,
  x: $2,
  y: $3,
  xroot: $4,
  yroot: $5,
  native: $1)))
""" % [native.repr, x.repr, y.repr, xroot.repr, yroot.repr])

macro resizecb*(width, height, native: untyped) =
  result = parse_stmt("""
$1.received_event((UiEvent(
  kind: UiEventResize,
  x: -1,
  y: -1,
  w: $2,
  h: $3,
  native: $1)))
""" % [native.repr, width.repr, height.repr])

