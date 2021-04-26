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


import options, colors, unicode
import nanovg, private/gladgl, glfw
import types, utils
import testmyway

var
  parent*, prev_parent*, self*: UiNode
  event*: UiEvent
  windows*: seq[UiNode] = @[]

proc draw(node: UiNode) {.gcsafe.}

proc top*(node: UiNode): UiAnchor =
  UiAnchor node.y - node.padding_bottom

proc set_top*(node: UiNode, top: UiAnchor) =
  node.top_anchored = true
  if node.parent != nil:
    if float32(node.parent.top) == float32 top:
      node.y = node.padding_top
      return
 
  node.y = (float32 top) + node.padding_top

proc left*(node: UiNode): UiAnchor =
  UiAnchor node.x + node.padding_right

proc set_left*(node: UiNode, left: UiAnchor) =
  node.left_anchored = true
  if node.parent != nil:
    if float32(node.parent.left) == float32 left:
      node.x = node.padding_left
      return

  node.x = (float32 left) - node.padding_left

proc right*(node: UiNode): UiAnchor =
  UiAnchor(node.x + node.w + node.padding_left)

proc set_right*(node: UiNode, right: UiAnchor) =
  if node.left_anchored:
    if node.parent != nil and float(node.parent.right) == float(right):
      node.w = (float32 right) - node.x - node.padding_right - node.parent.x - node.parent.padding_left
    else:
      node.w = (float32 right) - node.x - node.padding_right
  else:
    if node.parent != nil:
      if float32(node.parent.right) == float32 right:
        node.x = node.parent.w - node.w - node.padding_right
        return
    node.x = (float32 right) - node.w - node.padding_right

proc bottom*(node: UiNode): UiAnchor =
    UIAnchor(node.y + node.h + node.padding_top)

proc set_bottom*(node: UiNode, bottom: UiAnchor) =
  if node.top_anchored:
    if node.parent != nil and float(node.parent.bottom) == float(bottom):
      node.h = (float32 bottom) - node.y - node.padding_bottom - node.parent.y - node.parent.padding_top
    else:
      node.h = (float32 bottom) - node.y - node.padding_bottom
  else:
    if node.parent != nil:
      if float32(node.parent.bottom) == float32 bottom:
        node.y = node.parent.h - node.h - node.padding_bottom
        return
    node.y = (float32 bottom) - node.h - node.padding_bottom

proc name*(node: UiNode, detailed: bool = false): string =
  result = node.id & " (" & $node.kind & ")"
  if detailed:
    result.add " | (x: " & $node.x & ", " & "y: " & 
      $node.y & ", w: " & $node.w & ", h: " & $node.h & ")" 

proc contains*(node: UiNode, x, y: float32): bool =
  node.x < x and x < (node.x + node.w ) and 
    y > node.y and y < (node.y + node.h)

proc trigger_update_attributes*(node: UiNode) =
  ## Calls `update_attributes` for `node`, followed by
  ## all its children. Also causing layouts to arrange
  for ua in node.update_attributes:
    {.cast(gcsafe).}:
      ua(node, node.parent)
  if node.kind == UiLayout:
    for al in node.arrange_layout:
      {.cast(gcsafe).}:
        al(node, node.parent)
  for child in node.children:
    child.trigger_update_attributes()
    child.rootx = node.rootx + child.x
    child.rooty = node.rooty + child.y
  
  when not defined release:
    if node.w <= 0:
      ouiwarning node.name() & " width is " & $node.w
    if node.h <= 0:
      ouiwarning node.name() & " height is " & $node.h

proc axis_alignment(node: UiNode, inkw, inkh: float32): tuple[x, y: float32] =
  const padding = 5
  case node.halign:
  of UiRight, UiTop:
    result.x = node.w - inkw - padding
  of UiCenter:
    result.x = node.w / 2 - inkw / 2
  of UiLeft, UiBottom:
    result.x = padding
  case node.valign:
  of UiTop, UiRight:
    result.y = padding
  of UiCenter:
    result.y = node.h / 2 - inkh / 2
  of UiBottom, UiLeft:
    result.y = node.h - inkh - padding

proc force_children_to_redraw(node: UiNode) =
  for n in node.children:
    if n.force_redraw == true:
      continue
    n.force_redraw = true
    n.force_children_to_redraw()

proc force_parents_to_redraw(node: UiNode) =
  node.force_redraw = true
  if node.parent != nil:
    node.parent.force_parents_to_redraw()

proc draw_children(node: UiNode, vg: NVGContext) =
  for child in node.children:
    if child.visible == false:
      continue
    if child.window == nil:
      # Delegates don't get a window when being created?? thats why this is here
      child.window = node.window 
    vg.save()
    vg.translate(child.x, child.y)
    # vg.scissor(0, 0, child.w, child.h)
    child.draw()
    vg.restore()

proc draw(node: UiNode) =
  if (node.w == node.oldw and node.h == node.oldh) and node.force_redraw == false:
    ouidebug "shoud be speed drawing " & node.name()
  else:
    ouidebug "slow drawing " & $node.name(true)
  

  node.oldw = node.w
  node.oldh = node.h
  var vg = node.window.vg
  if vg == nil:
    oui_error "vg is nil"
  vg.save()
  case node.kind:
    of UiWindow:
      draw_rounded_rectangle(vg, node.color, node.opacity, 0f, 0f, node.w, node.h, 
        0f, 0f, black(1))
    of UiBox:
      draw_rounded_rectangle(vg, node.color, node.opacity, 0f, 0f, node.w, node.h,
        node.radius, node.border_width, node.border_color)
    of UiText:
      var pos = node.axis_alignment(vg.textWidth(node.str), node.size)
      vg.draw_text(node.str, node.face, node.color, node.size, pos.x, pos.y)
    of UiCanvas:
        vg.save()
        for p in node.paint:  
          {.cast(gcsafe).}:
            p(node, node.parent, vg)
        vg.restore()
    of UiImage:
      draw_image(vg, node.src)
    else:
      discard
  vg.restore()
  node.draw_children(vg)
  for draw_post in node.draw_post:
    if draw_post.isNil() == false:
      {.cast(gcsafe).}:
        draw_post(node, node.parent)
  node.force_redraw = false

proc handle_event*(window, node: UiNode, ev: var UiEvent) {.gcsafe.}

template handle_event_offset(window, child: UiNode, ev: var UiEvent) =
  var
    tmpx = ev.x
    tmpy = ev.y
  ev.x = ev.x - child.x
  ev.y = ev.y - child.y
  window.handle_event(child, ev)
  ev.x = tmpx
  ev.y = tmpy

proc request_focus*(node, target: UiNode) {.gcsafe.} =
  assert node.kind == UiWindow
  if node.focused_node != nil:
    node.focused_node.has_focus = false
    var e = UiEvent(kind: UiUnfocus, x: 0, y: 0)
    node.handle_event_offset(node.focused_node, e)

  node.focused_node = target
  target.has_focus = true
  var e = UiEvent(kind: UiFocus, x: 0, y: 0)
  node.handle_event_offset(target, e)

  ouidebug "focus given to " & target.name

proc queue_redraw*(target: UiNode = nil, update: bool = true) =
  if update:
    target.trigger_update_attributes()
  target.force_parents_to_redraw()
  if target.kind != UiWindow:
    target.force_children_to_redraw()

proc resize*(node: UiNode, w, h: float32) =
  if node.kind == UiWindow:
    if node.resizing == false:
      when glfw_supported():
        node.handle.size=(w: int32 w, h: int32 h)
    node.w = w
    node.h = h
    node.queue_redraw()

proc handle_event*(window, node: UiNode, ev: var UiEvent) =
  if node.animating:
    return
  for on_ev in node.event:
    {.cast(gcsafe).}:
      on_ev(node, node.parent, ev)
  for n in node.children:
    if n.visible == false or n.animating:
      break
    if n.contains(float32(ev.x), float32(ev.y)) or n.has_focus:
      if ev.kind == UiMousePress and ev.button == mb1:
        if n.accepts_focus and n.has_focus == false:       
          window.request_focus(n)
         
      if n.hovered == false:
        n.hovered = true
        if ev.kind != UiEnter:
          var e = UiEvent(kind: UiEnter, x: ev.x, y: ev.y)
          window.handle_event_offset(n, e)
      window.handle_event_offset(n, ev)
    else:
      if n.hovered:
        n.hovered = false
        if ev.kind != UiLeave:
          var e = UiEvent(kind: UiLeave, x: ev.x, y: ev.y)
          window.handle_event_offset(n, e)

proc draw_opengl*(window: UiNode) =
  assert window.kind == UiWindow
  var
    (fbWidth, fbHeight) = window.handle.framebufferSize
  if window.buffer != nil:
    nvgluDeleteFramebuffer(window.buffer)
    window.buffer = nil
  window.buffer = nvgluCreateFramebuffer(window.vg, int window.w, int window.h, {ifRepeatX, ifRepeatY})
  glViewport(0, 0, fbWidth, fbHeight)       
  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glCullFace(GL_BACK)
  glFrontFace(GL_CCW)
  nvgluBindFramebuffer(window.buffer)
  window.vg.beginFrame(cfloat window.w, cfloat window.h, 1.0)
  window.trigger_update_attributes()
  window.draw()
  nvgluBindFramebuffer(nil)
  window.vg.beginPath()
  var p = imagePattern(window.vg, 0, 0, float window.w, float window.h, 0, window.buffer.image, 1.0f)
  window.vg.fillPaint(p)
  window.vg.fill()
  window.vg.endFrame()
  
  for child in window.gl_nodes: 
    if child.kind == UiOpenGl:
      glEnable(GL_SCISSOR_TEST)
      glScissor(int32 child.rootx, int32 child.rooty, int32 child.w, int32 child.h)
      glClearColor(0, 0, 0, 0)
      glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
      for render in child.render:
        render(child, child.parent)
      glDisable(GL_SCISSOR_TEST)

when glfw_supported():
  var glfw_not_inited: bool = true
  proc create_glfw_window(window: UiNode): Window =
    if glfw_not_inited:
      glfw.initialize()
  
    var cfg = DefaultOpenglWindowConfig
    cfg.size = (w: int window.w, h: int window.h)
    cfg.title = "oui_glfw_window"
    cfg.resizable = true
    cfg.transparentFramebuffer = true
    cfg.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 16)
    cfg.version = glv20
    cfg.debugContext = true
    result = newWindow(cfg)
    glfw.makeContextCurrent(result) 
    if glfw_not_inited:
      glfw_not_inited = false
      nvgInit(getProcAddress)
      if not gladLoadGL(getProcAddress):
        oui_error "glad failed to load gl"

    result.windowSizeCb = proc(w: Window, size: tuple[w, h: int32]) =
      window.resizing = true
      window.resize(float size.w, float size.h)
      window.resizing = false
    
    result.mouseButtonCb = proc(w: Window, b: MouseButton, pressed: bool, mods: set[ModifierKey]) =
      if pressed:
        var e = UiEvent(kind: UiMousePress, button: b, x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e)
      else:
        var e = UiEvent(kind: UiMouseRelease, button: b, x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e)
    
    result.cursorPositionCb = proc(w: Window, pos: tuple[x, y: float64]) =
      window.cursor_pos = (x: pos.x, y: pos.y)
      var e = UiEvent(kind: UiMouseMotion, x: pos.x, y: pos.y)
      window.handle_event(window, e)

    result.cursorEnterCb = proc(w: Window, entered: bool) =
      if entered:
        var e = UiEvent(kind: UiEnter,  x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e)
      else:
        var e = UiEvent(kind: UiLeave, x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e)
    
    result.charCb = proc(w: Window, codePoint: Rune) =
      var e = UiEvent(kind: UiKeyPress, key: keyUnknown, mods: {}, ch: codePoint.toUTF8(),
        x: window.cursor_pos.x, y: window.cursor_pos.y)
      window.handle_event(window, e)
    
    result.keyCb = proc(w: Window, key: Key, scanCode: int32, action: KeyAction,
        mods: set[ModifierKey]) =
      if action == kaDown:
        var e = UiEvent(kind: UiKeyPress, key: key, mods: mods, ch: "",
          x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e) 
      elif action == kaUp:
        var e = UiEvent(kind: UiKeyRelease, key: key, mods: mods, ch: "",
          x: window.cursor_pos.x, y: window.cursor_pos.y)
        window.handle_event(window, e)

proc ensure_minimum_size(node: UiNode) =
  ## Resizes the node's w/h when < minw/minh
  node.update_attributes.add proc(s, p: UiNode) =
    if s.kind == UiText:
      if s.window != nil or s.window.vg != nil:
        s.minw = s.window.vg.textWidth(s.str)
        s.minh = s.size * 2
    if s.w < s.minw and s.minw > 0:
      s.w = s.minw
    if s.h < s.minh and s.minh > 0:
      s.h = s.minh
    if s.kind == UiWindow:
      s.handle.set_size_limits(int32 s.minw, int32 s.minh, -1, -1)

proc init*(T: type UiNode, k: UiNodeKind): UiNode =
  result = UiNode(kind: k,
    id: "noid",
    x: 0f,
    y: 0f,
    w: 0f,
    h: 0f,
    visible: true,
    animating: false,
    force_redraw: false,
    update_attributes: @[],
    event: @[],
    draw_post: @[],
    accepts_focus: false,
    index: 0,
    table: nil,
    children: @[],
    color: rgb(255, 255, 255),
    opacity: 1f,
    left_anchored: false,
    top_anchored: false)

  result.ensure_minimum_size()
  if result.kind == UiWindow:
    result.window = result
    result.title = "oui - Ocicat Ui Framework"
    result.is_popup = false
    result.focused_node = nil
    result.w = 100
    result.h = 100
    result.color = rgb(228, 228, 228)
    when glfw_supported():
      result.handle = create_glfw_window(result)
    result.vg = nvgCreateContext({nifStencilStrokes})
    var font = result.vg.createFont("sans", "Roboto-Regular.ttf")
    if font == NoFont:
      oui_error "Couldn't load font" 
    discard addFallbackFont(result.vg, font, font)
    windows.add result
  if result.kind == UiText:
    result.face = "sans"
    result.size = 18
    result.color = rgb(35, 35, 35)

proc fill*(node, target: UiNode) =
  node.set_left target.left
  node.set_top target.top
  node.set_bottom target.bottom
  node.set_right target.right

proc vcenter*(node, target: UiNode) =
  if target != node.parent:
    node.y = target.y + target.h / 2 - node.h / 2
  else:
    node.y = target.h / 2 - node.h / 2

proc hcenter*(node, target: UiNode) =
  if target != node.parent:
    node.x = target.x + target.w / 2 - node.w / 2
  else:
    node.x = target.w / 2 - node.w / 2

proc center*(node, target: UiNode) =
  node.vcenter(target)
  node.hcenter(target)

proc add*(node: UiNode, child: UiNode) =
  if child.kind == UiWindow:
    return
  child.parent = node
  child.window = node.window
  if child.kind == UiOpenGl:
    child.window.gl_nodes.add(child)
  node.children.add(child)

proc add_delegate*(node: UiNode, index: int) =
  var delegate = node.delegate(node.table, index)
  delegate.table = node.table
  delegate.index = index
  node.add(delegate)

proc set_table*(node: UiNode, table: UiTable) =
  if table == nil:
    node.table = nil
    return

  node.table = table
  node.table.table_added = proc(index: int) =
    node.add_delegate(index)
    ouidebug "table row added at index " & $index
  node.table.table_removed = proc(index: int) =
    ouidebug "table row removed at index " & $index

proc show*(node: UiNode) =
  if node.kind == UiWindow:
    node.resize(node.w, node.h)
    when glfw_supported():
      node.handle.show()
      node.handle.shouldClose = false
  node.visible = true
  for s in node.shown:
    s(node, node.parent)
  for child in node.children:
    child.show()

proc hide*(node: UiNode) =
  ## The application will be terminated if all windows are hidden
  if node.kind == UiWindow:
    when glfw_supported():
      node.handle.hide()
      node.handle.shouldClose = true
  node.visible = false
  for h in node.hidden:
    h(node, node.parent)
  for child in node.children:
    child.hide()

test_my_way "node":
  var
    box1 = UiNode.init(UiBox)
    box2 = UiNode.init(UiBox)
  box1.w = 100
  box1.h = 100
  box2.w = 200
  box2.h = 59

  test "contains":
    check  box1.contains(99, 99)
    check box2.contains(50, 50)

    box2.set_left box1.right

    check box2.contains(50, 50)
    check box2.contains(105, 150) == false
    check box2.contains(105, 50)
    check box2.contains(105, 99)

  test "window":
    var win = UiNode.init(UiWindow)
    win.color = black(245)
    box1.color = red(255)
    box2.color = blue(255)
    box1.update_attributes.add proc(s, p: UiNode) =
      s.set_right(p.right)
      s.set_bottom(p.bottom)
    
    win.add box1 
    win.add box2
    var box3 = UiNode.init(UiBox)
    box3.w = 50
    box3.h = 50
    box3.color = green(200)
    box2.add box3
    var box4 = UiNode.init(UiBox)
    box4.w = 50
    box4.h = 50
    box4.color = green(150)
    box4.update_attributes.add proc(s, p: UiNode) =
      s.center(p)
    win.add box4
    win.show()