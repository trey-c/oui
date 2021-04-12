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

import macros, strutils
import nanovg except text
import types, node, utils
import testmyway

var
  parents* {.compileTime.}: seq[NimNode] = @[]

macro node_init*(id: untyped, kind: UiNodeKind): untyped =
  var self_id = id.str_val
  result = quote do:
    UiNode.init `self_id`, `kind`

macro node_next_parent(id: untyped, delegate: bool = false) =
  var current_parent = if parents.len > 0: parents[parents.high] else: new_nil_lit()
  if current_parent.kind != nnkNilLit and delegate.bool_val == false:
    result = quote do:
      parent.add(`id`)
  parents.add(id)

template node*(id: untyped, kind: UiNodeKind, inner: untyped,
    delegate: bool = false) =
  var `id` {.inject.} = node_init(id, kind)
  parent = self
  self  = id
  node_next_parent(id, delegate)
  parent = id.parent
  inner
  static:
    if parents.len > 0:
      discard parents.pop()

template decl_ui_node*(name: untyped, kind: UiNodeKind) =
  template name*(id: untyped, inner: untyped) =
    var p {.gensym.}, s {.gensym.}: UiNode
    s = self
    p = parent
    node id, kind, inner, false
    self = s
    parent = p
  template name*(inner: untyped) =
    block:
      name noid, inner

macro decl_style*(name, inner: untyped) =
  var styles: seq[tuple[name, color: string]] = @[]
  assert inner.kind == nnkStmtList
  for call in inner:
    assert call.kind == nnkCall
    styles.add((name: call[0].str_val, color: call[1][0].str_val))  

  var
    type_name = name.str_val
    type_str = ""
    var_str = ""
    i = 0
  for style in styles:
    type_str.add style.name
    var_str.add style.name & ": \"" & style.color  & "\""
    if i != styles.len - 1:
      type_str.add ", "
      var_str.add ", "
    i.inc

  result = parse_stmt("""
type
  $1* = tuple[$2: string]
var $3* = ($4)
  """ % [type_name.capitalize_ascii.str_to_camel_case & "Style", type_str, type_name & "_style", var_str])

macro decl_widget*(name, base, params, inner: untyped) =
  var params_list: seq[string] = @[]
  assert params.kind == nnkStmtList
  for p in params:
    if p.kind == nnkDiscardStmt:
      continue
    var pfixed = p.repr
    pfixed.remove_prefix("var ")
    params_list.add((pfixed))
  var
    params_str = ""
    params_call_str = ""
  for param in params_list:
    params_str.add ", " & param
    var fparam = param
    fparam.delete(param.find(":"), param.len - 1)
    params_call_str.add ", " & fparam
  var cmd = nnkCommand.new_tree(base, ident("id"), inner)
  var strstmt = """
template $1*(id, inner: untyped$2) = $3
  inner
template $1*(inner: untyped$2) = 
  block:
    noid_with_counter "$1", "$4": 
    $5
  """ % [name.str_val, params_str, cmd.repr, params_call_str, inner.repr]
  echo strstmt
  result = parse_stmt(strstmt)

decl_ui_node window, UiWindow
decl_ui_node box, UiBox
decl_ui_node text, UiText
decl_ui_node canvas, UiCanvas
decl_ui_node layout, UiLayout
decl_ui_node image, UiImage

template correct_self(s, p: UiNode, inner: untyped) =
  var tmpself = self
  var tmpparent = parent
  self = s
  parent = p
  `inner`
  self = tmpself
  parent = tmpparent

template table*(m: UiTable) =
  self.set_table m

template delegate*(call: untyped, kind: UiNodeKind, inner: untyped) =
  self.delegate = proc(tmptable: UiTable, tmpindex: int): UiNode =
    var
      table {.inject.} = tmptable
      index {.inject.} = tmpindex
    node delegate, kind, inner, true
    return delegate

template paint*(inner: untyped) =
  self.paint.add proc(s, p: Uinode, tmpctx: ptr Context) {.closure.} =
    ctx = tmpctx
    correct_self(s, p, inner)

template top*(anchor: UiAnchor) =
  self.set_top anchor

template left*(anchor: UiAnchor) =
  self.set_left anchor

template bottom*(anchor: UiAnchor) =
  self.set_bottom anchor

template right*(anchor: UiAnchor) =
  self.set_right anchor

template padding_top*(t: float32) =
  self.padding_top = t

template padding_left*(l: float32) =
  self.padding_left = l

template padding_bottom*(b: float32) =
 self.padding_bottom = b

template padding_right*(r: float32) =
  self.padding_right = r

template padding*(top, left, bottom, right: float32) =
  self.padding_top = top
  self.padding_left = left
  self.padding_bottom = bottom
  self.padding_right = right

template border_width*(t: float32) =
  self.border_width = t

template border_color*(c: Color) =
  self.border_color = c

template border_color*(r, g, b: int = 255) =
  self.border_color = rgb(r, g, b)

template color*(c: Color) =
  self.color = c

template color*(r, g, b: int = 255) =
  self.color = rgb(r, g, b)

template opacity*(o: range[0f..1f]) =
  self.opacity = o

template w*(width: float32) =
  self.w = width

template h*(height: float32) =
  self.h = height

template size*(width, height: float32) =
  self.w = width
  self.h = height

template fill*(target: UiNode) =
  self.fill(target)

template vcenter*(target: UiNode) =
  self.vcenter(target)

template hcenter*(target: UiNode) =
  self.hcenter(target)

template visible*(b: bool) =
  self.visible = b

template center*(target: UiNode) =
  self.center(target)

template title*(str: string) =
  self.title = str

template str*(text: string) =
  self.str = text

template size*(s: float) =
  self.size = s

template face*(s: string) =
  self.face = s

template valign*(align: UiAlignment) =
  self.valign = align

template halign*(align: UiAlignment) =
  self.halign = align

template radius*(r: float32) =
  self.radius = r

template spacing*(s: float32) =
  self.spacing = s

template src*(s: string) =
  self.src = s

template accepts_focus*(af: bool) =
  self.accepts_focus = af

template minw*(mw: float32) =
  self.minw = mw

template minh*(mh: float32) =
  self.minh = mh

template update*(inner: untyped) =
  self.update_attributes.insert((proc(s, p: UiNode) {.closure.} =
    correct_self(s, p, inner)), 0)

template events*(inner: untyped) =
  self.on_event.add proc(s, p: UiNode, e: var UiEvent) {.closure.} =
    event = e
    correct_self(s, p, inner)

template key_press*(inner: untyped) =
  if event.kind == UiEventKeyPress:
    `inner`

template key_release*(inner: untyped) =
  if event.kind == UiEventKeyRelease:
    `inner`

template button_press*(inner: untyped) =
  if event.kind == UiEventMousePress:
    `inner`

template button_release*(inner: untyped) =
  if event.kind == UiEventMouseRelease:
    `inner`

template mouse_motion*(inner: untyped) =
  if event.kind == UiEventMouseMotion:
    `inner`

template mouse_enter*(inner: untyped) =
  if event.kind == UiEventEnter:
    `inner`

template mouse_leave*(inner: untyped) =
  if event.kind == UiEventLeave:
    `inner`

template focus*(inner: untyped) =
  if event.kind == UiEventFocus:
    `inner`

template unfocus*(inner: untyped) =
  if event.kind == UiEventUnfocus:
    `inner`

template arrange_layout*(inner: untyped) =
  self.arrange_layout.add proc(s, p: UiNode) {.closure.} =
    correct_self(s, p, inner)

template border_top*(thickness: float32, inner: untyped) =
  box bordertop:
    update:
      top parent.top
      size parent.w, thickness
      inner

template border_left*(thickness: float32, inner: untyped) =
  box borderleft:
    update:
      left parent.left
      size thickness, parent.h
      inner

template border_right*(thickness: float32, inner: untyped) =
  box borderright:
    update:
      top parent.top
      right parent.right
      size thickness, parent.h
      inner

template border_bottom*(thickness: float32, inner: untyped) =
  box borderbottom:
    update:
      bottom parent.bottom
      size parent.w, thickness
      inner

test_my_way "sugarsyntax":
  test "children":
    box box1:
      box box2:
        box box3:
          discard
        box box4:
          discard
      box box5:
        discard
      box box6:
        box box7:
          discard
        box:
          discard
        box:
          box:
            discard
          box: 
            discard
          check self.children.len == 2

    check box1.children.len == 3
    check box2.children.len == 2
    check box3.children.len == 0
    check box4.children.len == 0
    check box5.children.len == 0
    check box6.children.len == 3
    check box7.children.len == 0

  test "attributes":
    box:
      w 10
      h 10
      size self.w * 2, self.h * 2
      check self.w == 20
      check self.h == 20
      
      top self.top
      left self.left
      bottom self.bottom
      right self.right
      padding 10, 0, 10, 0
      padding_left 10
      padding_right 10
      padding_top 10
      padding_bottom 10
      
      color 255, 255, 255
      color self.color
      border_color 255, 255, 255
      border_color self.border_color
      opacity 0.5
      radius 5
      minw 1
      minh 1
    text:
      fill self
      vcenter self
      hcenter self
      center self
      valign UiBottom
      halign UiRight
      accepts_focus true
      str "something else"
      size 12
      face "Sans"
      visible true
    image:
      src "text.png"

  test "layout":
    layout testlayout:
      arrange_layout:
        check self.id == "testlayout"
        check self.children.len == 2
        check self.children[0].id == "testbox"
        self.children[0].w = 40
        self.children[0].h = 20
      box testbox:
        update:
          w 20
      box:
        discard
      
      check self.id == "testlayout"

      self.trigger_update_attributes()
      check self.children.len == 2
      check self.children[0].id == "testbox"
      check self.children[0].w == 20
      check self.children[0].h == 20
  
  test "delegate":
    layout testlayout:
      delegate box, UiBox:
        color 234, 234, 23
    check testlayout.children.len == 0
    testlayout.add_delegate(0)
    check testlayout.children.len == 1
    testlayout.add_delegate(1)
    testlayout.add_delegate(2)
    check testlayout.children.len == 3

    check testlayout.children[0].index == 0
    check testlayout.children[1].index == 1
    check testlayout.children[2].index == 2
  
  test "min sizes":
    box testbox:
      minw 100
      minh 100
      w 10
      h 10
      update:
        w 10
        h 10
    check testbox.w == 10
    check testbox.h == 10
    testbox.trigger_update_attributes()
    check testbox.w == 100
    check testbox.h == 100
    testbox.minw = 0
    testbox.minh = 0
    testbox.trigger_update_attributes()
    check testbox.w == 10
    check testbox.h == 10

