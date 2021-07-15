# import oui

import types
when glfm_supported():
  import glfm/glfm
  import android/ndk/[aasset_manager, anative_activity]
  import android/util/display_metrics
  import android/view/[window_manager, display]
  import android/app/activity
  import opengl
when glfw_supported():
  import glfw
  import private/gladgl

import utils
import json
import nanovg
import testaid
import options, colors, unicode, os, strutils

proc draw(node: UiNode, vg: NVGContext)
proc handle_event*(window, node: UiNode, ev: var UiEvent)

var
  parent*, prev_parent*, self*: UiNode
  event*: UiEvent

when glfw_supported():
  var windows*: seq[UiNode] = @[]
when glfm_supported():
  var onlywindow*: UiNode

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
      node.w = (float32 right) - node.x - node.padding_right - node.parent.x -
          node.parent.padding_left
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
      node.h = (float32 bottom) - node.y - node.padding_bottom - node.parent.y -
          node.parent.padding_top
    else:
      node.h = (float32 bottom) - node.y - node.padding_bottom
  else:
    if node.parent != nil:
      if float32(node.parent.bottom) == float32 bottom:
        node.y = node.parent.h - node.h - node.padding_bottom
        return
    node.y = (float32 bottom) - node.h - node.padding_bottom

iterator items*(node: UiNode): UiNode =
  for child in node.children:
    yield child

proc `[]`*(node: UiNode, idx: int): UiNode =
  node.children[idx]

proc name*(node: UiNode, detailed: bool = false): string {.exportc.} =
  result = node.id & " (" & $node.kind & ")"
  if detailed:
    result.add " | (x: " & $node.x & ", " & "y: " &
      $node.y & ", w: " & $node.w & ", h: " & $node.h & ")"

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
  for child in node:
    child.trigger_update_attributes()
    child.rootx = node.rootx + child.x
    child.rooty = node.rooty + child.y

proc force_children_to_redraw(node: UiNode) =
  for n in node:
    if n.force_redraw == true:
      continue
    n.force_redraw = true
    n.force_children_to_redraw()

proc force_parents_to_redraw(node: UiNode) =
  node.force_redraw = true
  if node.parent != nil:
    node.parent.force_parents_to_redraw()

template handle_event_offset(window, child: UiNode, ev: var UiEvent) =
  var
    tmpx = ev.x
    tmpy = ev.y
  ev.x = ev.x - child.x
  ev.y = ev.y - child.y
  window.handle_event(child, ev)
  ev.x = tmpx
  ev.y = tmpy

proc request_focus*(node, target: UiNode) {.gcsafe, exportc.} =
  assert node.kind == UiWindow
  node.handle.focus()
  if node.focused_node != nil:
    node.focused_node.has_focus = false
    {.cast(gcsafe).}:
      var e = UiEvent(kind: UiUnfocus, x: 0, y: 0)
      node.handle_event_offset(node.focused_node, e)
  node.focused_node = target
  target.has_focus = true
  {.cast(gcsafe).}:
    var e = UiEvent(kind: UiFocus, x: 0, y: 0)
    node.handle_event_offset(target, e)

proc contains*(node: UiNode, x, y: float32): bool =
  node.x < x and x < (node.x + node.w) and
    y > node.y and y < (node.y + node.h)

proc fill*(node, target: UiNode) {.exportc.} =
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

proc real_root_coords*(node: UiNode): tuple[x, y: int32] =
  ## Works for both windows and any of their children
  when glfw_supported():
    if node.kind == UiWindow:
      result = node.handle.pos
    else:
      var pos = node.parent.real_root_coords()
      result = (x: int32(self.x) + pos.x, y: int32(self.y) + pos.y)
  when glfm_supported():
    discard

proc move*(node: UiNode, x, y: float) {.exportc.} =
  when glfw_supported():
    if node.kind == UiWindow:
      node.handle.pos = (x: int32 x, y: int32 y)
  when glfm_supported():
    discard

proc queue_redraw*(target: UiNode = nil, update: bool = true) =
  if update:
    target.trigger_update_attributes()
  target.force_parents_to_redraw()
  if target.kind != UiWindow:
    target.force_children_to_redraw()
    var pos = target.real_root_coords()
    target.move(float pos.x, float pos.y)

proc resize*(node: UiNode, w, h: float32) =
  if node.kind == UiWindow:
    if node.resizing == false:
      when glfw_supported():
        node.handle.size = (w: int32 w, h: int32 h)
      when glfm_supported():
        discard
    node.w = w
    node.h = h
    node.queue_redraw()

proc draw_children(node: UiNode, vg: NVGContext) =
  for child in node:
    if child.visible == false:
      continue
    if child.window == nil:
      child.window = node.window # Delegates don't get a window when being created??
    vg.save()
    vg.translate(child.x, child.y)
    vg.intersect_scissor(0, 0, child.w, child.h)
    child.draw(vg)
    vg.reset_scissor()
    vg.restore()

when glfw_supported():
  proc draw_opengl*(window: UiNode) {.exportc.} =
    assert window.kind == UiWindow
    glViewport(0, 0, GLint window.w, GLint window.h)
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
    glCullFace(GL_BACK)
    glFrontFace(GL_CCW)
    nvgluBindFramebuffer(window.buffer)
    window.vg.beginFrame(cfloat window.w, cfloat window.h, 1.0)
    window.trigger_update_attributes()
    window.draw(window.vg)
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

proc draw(node: UiNode, vg: NVGContext) =
  node.oldw = node.w
  node.oldh = node.h
  vg.save()
  case node.kind:
    of UiWindow, UiBox:
      vg.beginPath()
      let rad = if node.kind == UiBox: node.radius else: 0
      vg.roundedRect(0, 0, node.w, node.h, rad)
      if node.gradient.active:
        let bg = vg.linear_gradient(node.gradient.sx, node.gradient.sy,
          node.gradient.ex, node.gradient.ey,
          node.gradient.color1, node.gradient.color2)
        vg.fill_paint(bg)
      else:
        vg.fill_color node.color
      vg.fill()
      if node.kind == UiBox:
        if node.border_width < 0:
          return
        vg.beginPath()
        vg.roundedRect(0, 0, node.w, node.h, node.radius)
        vg.stroke_color(node.border_color)
        vg.stroke()
    of UiText:
      var
        rows = vg.textBreakLines(node.str, node.str.low, node.str.high, node.w, 1024)
        realy = 0.0
      for row in rows:
        vg.begin_path()
        vg.fillColor(node.color)
        vg.fontSize(node.size)
        vg.fontFace(node.face)
        vg.textAlign(haLeft, vaTop)
        let (_, _, lineh) = vg.text_metrics()
        discard vg.text(0, realy, node.str, row.startPos, row.endPos)
        realy += lineh
    of UiCanvas:
      vg.save()
      for p in node.paint:
        {.cast(gcsafe).}:
          p(node, node.parent, vg)
      vg.restore()
    of UiImage:
      draw_image(vg, node.src, node.w, node.h)
    else:
      discard
  vg.restore()
  node.draw_children(vg)
  for draw_post in node.draw_post:
    if draw_post.isNil() == false:
      {.cast(gcsafe).}:
        draw_post(node, node.parent)
  node.force_redraw = false

proc handle_event*(window, node: UiNode, ev: var UiEvent) =
  if node.animating:
    return
  for on_ev in node.event:
    {.cast(gcsafe).}:
      on_ev(node, node.parent, ev)
  for n in node:
    if n.visible == false or n.animating:
      continue
    if n.contains(float32(ev.x), float32(ev.y)) or n.has_focus:
      when glfw_supported():
        if ev.kind == UiMousePress and ev.button == mb1:
          if n.accepts_focus and n.has_focus == false:
            window.request_focus(n)
      when defined android:
        if ev.kind == UiTouch and ev.phase == GLFMTouchPhaseBegan:
          if n.accepts_focus and n.has_focus == false:
            window.request_focus(n)
        window.handle_event_offset(n, ev)
      if n.hovered == false:
        n.hovered = true
        if ev.kind != UiEnter:
          var e = UiEvent(kind: UiEnter, x: ev.x, y: ev.y)
          window.handle_event_offset(n, e)
        else:
          window.handle_event_offset(n, ev)
      else:
        window.handle_event_offset(n, ev)
    else:
      if n.hovered:
        n.hovered = false
        if ev.kind != UiLeave:
          var e = UiEvent(kind: UiLeave, x: ev.x, y: ev.y)
          window.handle_event_offset(n, e)
        else:
          window.handle_event_offset(n, ev)

proc hide*(node: UiNode) {.exportc.} =
  ## The application will be terminated if all windows are hidden
  if node.kind == UiWindow:
    when glfw_supported():
      node.handle.hide()
  node.visible = false
  for h in node.hidden:
    h(node, node.parent)
  for child in node:
    child.hide()

when glfw_supported():
  proc oui_glfw_main*(window: UiNode) =
    var close = false
    while close != true:
      glfw.swapInterval(0)
      if window.visible == false:
        close = true
      for win in windows:
        if win.handle.should_close():
          win.hide()
        if win.visible:
          glfw.makeContextCurrent(win.handle)
          win.draw_opengl()
          glfw.swapBuffers(win.handle)
      glfw.waitEvents()

  var glfw_not_inited: bool = true
  proc create_glfw_window(window: UiNode): Window =
    if glfw_not_inited:
      glfw.initialize()

    var cfg = DefaultOpenglWindowConfig
    cfg.size = (w: int window.w, h: int window.h)
    cfg.title = "oui_glfw_window"
    cfg.resizable = window.resizable
    cfg.decorated = if window.borderless: false else: true
    cfg.visible = false
    cfg.transparentFramebuffer = true
    cfg.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 16)
    when defined windows:
      cfg.version = glv20
    else:
      cfg.version = glv30
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

    when defined windows:
      # Allows the window to redraw while being resized
      result.framebufferSizeCb = proc(w: Window, size: tuple[w, h: int32]) =
        w.swapBuffers()

    result.mouseButtonCb = proc(w: Window, b: MouseButton, pressed: bool,
        mods: set[ModifierKey]) =
      if pressed:
        var e = UiEvent(kind: UiMousePress, button: b, x: window.cursor_pos.x,
            y: window.cursor_pos.y)
        window.handle_event(window, e)
      else:
        var e = UiEvent(kind: UiMouseRelease, button: b, x: window.cursor_pos.x,
            y: window.cursor_pos.y)
        window.handle_event(window, e)

    result.cursorPositionCb = proc(w: Window, pos: tuple[x, y: float64]) =
      window.cursor_pos = (x: pos.x, y: pos.y)
      var e = UiEvent(kind: UiMouseMotion, x: pos.x, y: pos.y)
      window.handle_event(window, e)

    result.cursorEnterCb = proc(w: Window, entered: bool) =
      if entered:
        var e = UiEvent(kind: UiEnter, x: window.cursor_pos.x,
            y: window.cursor_pos.y)
        window.handle_event(window, e)
      else:
        var e = UiEvent(kind: UiLeave, x: window.cursor_pos.x,
            y: window.cursor_pos.y)
        window.handle_event(window, e)

    result.window_focus_cb = proc(w: Window, focused: bool) =
      if focused:
        var e = UiEvent(kind: UiFocus, x: 0, y: 0)
        window.handle_event(window, e)
      else:
        var e = UiEvent(kind: UiUnfocus, x: 0, y: 0)
        window.handle_event(window, e)

    result.charCb = proc(w: Window, codePoint: Rune) =
      var e = UiEvent(kind: UiKeyPress, key: keyUnknown, mods: {},
          ch: codePoint.toUTF8(),
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

proc ensure_minimum_size(node: UiNode) {.exportc.} =
  ## Resizes the node's w/h when < minw/minh
  node.update_attributes.add proc(s, p: UiNode) =
    if s.kind == UiText:
      if s.window != nil:
        if s.window.vg != nil:
          s.minh = 0
          for str in s.str.split_lines():
            var
              (a, b, lineh) = s.window.vg.textMetrics()
              txtw = s.window.vg.text_width(str)
            if txtw > s.minw:
              s.minw = txtw
            s.minh += lineh
    if s.w < s.minw and s.minw > 0:
      s.w = s.minw
    if s.h < s.minh and s.minh > 0:
      s.h = s.minh
    when glfw_supported():
      if s.kind == UiWindow:
        s.handle.set_size_limits(int32 s.minw, int32 s.minh, -1, -1)

proc init*(T: type UiNode, k: UiNodeKind): UiNode =
  result = UiNode(kind: k,
    id: "noid",
    x: 0f,
    y: 0f,
    w: 0f,
    h: 0f,
    minw: 1f,
    minh: 1f,
    visible: true,
    animating: false,
    force_redraw: false,
    update_attributes: @[],
    event: @[],
    draw_post: @[],
    accepts_focus: false,
    index: 0,
    json_array: nil,
    children: @[],
    color: rgb(255, 255, 255),
    opacity: 1f,
    left_anchored: false,
    top_anchored: false,
    gradient: (sx: 0.0, sy: 0.0, ex: 0.0, ey: 0.0, active: false, color1: white(
        255), color2: white(255)))

  result.ensure_minimum_size()
  if result.kind == UiWindow:
    result.window = result
    result.resizable = true
    result.borderless = false
    result.title = "oui - Ocicat Ui Framework"
    result.is_popup = false
    result.focused_node = nil
    result.w = 100
    result.h = 100
    result.color = rgb(228, 228, 228)

  if result.kind == UiText:
    result.face = "bauhaus"
    result.size = 14
    result.color = rgb(35, 35, 35)


when glfm_supported():
  proc NimMain() {.importc.}
  proc glfmMain*(display: ptr GLFMDisplay) {.exportc.} =
    NimMain()

    glfmSetDisplayConfig(display, GLFMRenderingAPIOpenGLES2,
                         GLFMColorFormatRGBA8888, GLFMDepthFormat16,
                         GLFMStencilFormat8, GLFMMultisampleNone)
    glfmSetSurfaceCreatedFunc display, proc(display: ptr GLFMDisplay,
          width: cint, height: cint) =
      onlywindow.vg = nvgCreateContext({nifStencilStrokes})
      onlywindow.vg.load_font_by_name("bauhaus")
      glViewport(0, 0, width, height)
      onlywindow.resize(float width, float height)
    glfmSetSurfaceResizedFunc display, proc(display: ptr GLFMDisplay,
          width: cint, height: cint) =
      glViewport(0, 0, width, height)
      onlywindow.resize(float width, float height)
    glfmSetTouchFunc display, proc(display: ptr GLFMDisplay; touch: cint; phase: GLFMTouchPhase; x: cdouble;
               y: cdouble): bool =
      var e = UiEvent(kind: UiTouch, phase: phase, x: float (x * 1.5),
          y: float (y * 2.0))
      onlywindow.handle_event(onlywindow, e)

    glfmSetMainLoopFunc display, proc(display: ptr GLFMDisplay;
        frameTime: cdouble) =
      glClearColor(1.0, 0.0, 0.0, 1.0)
      glClear(GL_COLOR_BUFFER_BIT or GL_STENCIL_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
      glCullFace(GL_BACK)
      glFrontFace(GL_CCW)

      onlywindow.trigger_update_attributes()
      onlywindow.vg.beginFrame(cfloat onlywindow.w, cfloat onlywindow.h, 1.0)
      onlywindow.draw(onlywindow.vg)
      onlywindow.vg.endFrame()
      glFlush()

proc show*(node: UiNode) {.exportc.} =
  if node.kind == UiWindow:
    when glfw_supported():
      if node.handle == nil:
        node.handle = create_glfw_window(node)
        windows.add(node)
        node.vg = nvgCreateContext({nifStencilStrokes})
        node.vg.load_font_by_name("bauhaus")
    node.resize(node.w, node.h)
    discard
    when glfw_supported():
      node.handle.show()
      node.handle.shouldClose = false
  else:
    if node.parent == nil and node.window == nil:
      node.trigger_update_attributes()
      node.window = UiNode.init(UiWindow)
      node.window.w = if node.w > 0: node.w else: 100
      node.window.h = if node.h > 0: node.h else: 100
      node.window.add(node)
      node.update_attributes.add proc(s, p: UiNode) = s.fill p
      node.window.show()
      return

  if node.visible == false:
    for child in node:
      child.show()
  node.visible = true
  for s in node.shown:
    s(node, node.parent)
  when glfw_supported():
    if node.kind == UiWindow:
      oui_glfw_main(node)
  when glfm_supported():
    if node.kind == UiWindow:
      onlywindow = node


proc add_delegate*(node: UiNode, index: int) {.exportc.} =
  var delegate = node.delegate(node.json_array, index)
  delegate.json_array = node.json_array
  delegate.index = index
  node.add(delegate)

proc refill_delegates*(node: UiNode) =
  node.children.set_len 0
  var i = 0
  for j in node.json_array:
    node.add_delegate(i)
    i.inc

proc set_j_array*(node: UiNode, jarray: JsonNode) {.exportc.} =
  node.json_array = jarray
  node.shown.add(proc(s, p: UiNode) =
    node.refill_delegates()
  )
  node.hidden.add(proc(s, p: UiNode) =
    s.children.set_len 0
  )

