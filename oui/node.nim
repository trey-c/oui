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


import options, colors
import cairo
import types, backend, utils

var
  parent*, prev_parent*, self*: UiNode
  event*: UiEvent

proc draw(node: UiNode)

proc set_top*(node: UiNode, top: UiAnchor) =
  node.top_anchored = true
  node.y = float32 top

proc top*(node: UiNode): UiAnchor =
  UiAnchor node.y

proc set_left*(node: UiNode, left: UiAnchor) =
  node.left_anchored = true
  node.x = float32 left

proc left*(node: UiNode): UiAnchor =
  UiAnchor node.x

proc set_right*(node: UiNode, right: UiAnchor) =
  if node.left_anchored:
    node.w = (float32 right) - node.x
  else:
    node.x = (float32 right) - node.w 

proc right*(node: UiNode): UiAnchor =
  UiAnchor(node.x + node.w)

proc set_bottom*(node: UiNode, bottom: UiAnchor) =
  if node.top_anchored:
    node.h = (float32 bottom) - node.y
  else:
    node.y = (float32 bottom) - node.h

proc bottom*(node: UiNode): UiAnchor =
  UIAnchor(node.y + node.h)

proc name*(node: UiNode, detailed: bool = false): string =
  result = node.id & " (" & $node.kind & ")"
  if detailed:
    result.add " | (x: " & $node.x & ", " & "y: " & 
      $node.y & ", w: " & $node.w & ", h: " & $node.h & ")" 

proc trigger_update_attributes*(node: UiNode) =
  ## Calls `update_attributes` for `node`, followed by
  ## all its children. Also causing layouts to arrange
  for ua in node.update_attributes:
    ua(node, node.parent)
  for child in node.children:
    child.trigger_update_attributes()
  if node.kind == UiLayout:
    if node.arrange_layout != nil:
      node.arrange_layout()

proc axis_alignment(node: UiNode, inkw, inkh: float32): tuple[x, y: float32] =
  const padding = 5
  case node.halign:
  of UiRight, UiTop:
    result.x = padding
  of UiCenter:
    result.x = node.w / 2 - inkw / 2
  of UiLeft, UiBottom:
    result.x = node.w - inkw - padding
  case node.valign:
  of UiTop, UiRight:
    result.y = padding
  of UiCenter:
    result.y = node.h / 2 - inkh
  of UiBottom, UiLeft:
    result.y = node.h - inkh - padding

proc force_children_to_redraw(node: UiNode) =
  for n in node.children:
    if n.force_redraw == true:
      continue
    n.force_redraw = true
    n.force_children_to_redraw()

proc draw_children(node: UiNode, ctx: ptr Context) =
  for child in node.children:
    ctx.save()
    child.draw()
    ctx.set_source(child.surface, float64 child.x - node.x, float64 child.y - node.y)
    ctx.paint()
    ctx.restore()

proc speed_up_drawing(node: UiNode): bool = 
  if node.w == node.oldw and node.h == node.oldh and node.force_redraw == false:
    if node.surface != nil:
      node.need_redraw = false
      var ctx = node.surface.create()
      node.draw_children(ctx)
      ctx.destroy()
      return true
  elif node.w != node.oldw and node.h != node.oldh and node.force_redraw == true:
      node.force_children_to_redraw()
  node.oldw = node.w
  node.oldh = node.h
  false

proc draw(node: UiNode) =
  if node.speed_up_drawing():
    return
  
  if node.surface != nil:
    node.surface.destroy()
    node.surface = nil

  ouidebug "drawing " & $node.name(true)
  node.surface = image_surface_create(FormatArgb32, int32 node.w, int32 node.h)
  var ctx = node.surface.create()
  ctx.save()
  case node.kind:
    of UiWindow:
      ctx.set_source_rgba(1, 1, 1, 0)
      ctx.rectangle(0f, 0f, float64 node.w, float64 node.h)
      ctx.fill()
    of UiBox:
      draw_rounded_rectangle(ctx, node.color, node.opacity, 0f, 0f,
          node.w, node.h, node.radius)
    of UiText:
      var
        pixels = text_pixel_size(ctx, node.str, node.family)
        align = node.axis_alignment(pixels.w, pixels.h)
      draw_text(ctx, node.str, node.family, node.color, node.opacity, align.x, align.y)
    of UiCanvas:
      if node.paint.isNil() == false:
        ctx.save()
        node.paint(ctx)
        ctx.restore()
    of UiImage:
      draw_png(ctx, node.src, 0, 0, node.w, node.h)
    else:
      discard
  ctx.restore()
  node.draw_children(ctx)
  for draw_post in node.draw_post:
    if draw_post.isNil() == false:
      draw_post()
  ctx.destroy()
  node.need_redraw = false
  node.force_redraw = false

proc contains*(node: UiNode, x, y: float32): bool =
  node.x < x and x < (node.x + node.w ) and 
    y > node.y and y < (node.y + node.h)

proc request_focus*(node, target: UiNode) =
  assert node.kind == UiWindow
  if node.focused_node != nil:
    node.focused_node.has_focus = false
  node.focused_node = target
  target.has_focus = true
  ouidebug "focus given to " & target.name

proc needs_redraw*(node: UiNode, from_parent: bool = false) =
  ## Marks the node and all it's children for a redraw. note: does not
  ## actually redraw right away; use queue_redraw instead
  node.need_redraw = true
  if from_parent == false:
    for n in node.children:
      needs_redraw(n)
  if node.parent != nil:
    node.parent.needs_redraw(true)

proc queue_redraw*(target: UiNode = nil, update: bool = true) =
  if update:
    target.trigger_update_attributes()
  target.force_redraw = true
  if target.kind != UiWindow:
    target.force_children_to_redraw()
    target.needs_redraw()
  target.window.native.expose()

proc resize*(node: UiNode, w, h: float32) =
  if node.kind == UiWindow:
    node.w = w
    node.h = h
    node.queue_redraw()

proc handle_event*(window, node: UiNode, ev: var UiEvent) =
  for on_ev in node.on_event:
    on_ev(node, node.parent, ev)
  for n in node.children:
    if n.visible == false or n.animating:
      continue
    if n.contains(float32(ev.x), float32(ev.y)) or n.has_focus:
      if ev.event_mod == UiEventPress and ev.button == 1:
        if n.wants_focus and n.has_focus == false:
          window.request_focus(n)

      if n.hovered == false:
        n.hovered = true
        var tmp = ev.event_mod
        ev.event_mod = UiEventEnter
        window.handle_event(n, ev)
        ev.event_mod = tmp
      window.handle_event(n, ev) 
    else:
      if n.hovered:
        n.hovered = false
        var tmp = ev.event_mod
        ev.event_mod = UiEventLeave
        window.handle_event(n, ev)
        ev.event_mod = tmp

proc init*(T: type UiNode, id: string, k: UiNodeKind): UiNode =
  result = UiNode(kind: k,
    id: id,
    x: 0f,
    y: 0f,
    w: 0f,
    h: 0f,
    visible: true,
    clip: false,
    animating: false,
    need_redraw: false,
    force_redraw: false,
    update_attributes: @[],
    on_event: @[],
    draw_post: @[],
    wants_focus: true,
    index: -1,
    model: nil,
    children: @[],
    opacity: 1f,
    left_anchored: false,
    top_anchored: false)
   
  if result.kind == UiWindow:
    result.window = result
    result.title = id
    result.is_popup = false
    result.focused_node = nil
    result.native = UiNative.init(100, 100)
    var window = result
    result.native.received_event = proc(ev: UiEvent) {.gcsafe.} =
      var tmp = ev
      if ev.event_mod == UiEventResize:
        window.native.width = ev.w
        window.native.height = ev.h
        window.needs_redraw()
        window.resize(float32 ev.w, float32 ev.h)
      elif ev.event_mod == UiEventExpose:
        window.needs_redraw()
        window.draw()
        if window.surface != nil:
          window.native.ctx.set_source(window.surface, 0f, 0f)
          window.native.ctx.paint()
        window.need_redraw = false
      else:
       window.handle_event(window, tmp)
  if result.kind == UiText:
    result.wants_focus = false
    result.valign = UiCenter
    result.halign = UiCenter

proc fill*(node, target: UiNode) =
  node.x = target.x
  node.y = target.y
  node.w = target.w
  node.h = target.h

proc vcenter*(node, target: UiNode) =
  node.y = target.y + target.h / 2 - node.h / 2

proc hcenter*(node, target: UiNode) =
  node.x = target.x + target.w / 2 - node.w / 2

proc center*(node, target: UiNode) =
  node.vcenter(target)
  node.hcenter(target)

proc add*(node: UiNode, child: UiNode) =
  if child.kind == UiWindow:
    return
  child.parent = node
  child.window = node.window
  node.children.add(child)

proc add_delegate(node: UiNode, index: int) =
  var delegate = node.delegate(node.model, index)
  delegate.model = node.model
  delegate.index = index
  node.add(delegate)

proc set_model*(node: UiNode, model: UiModel) =
  if model == nil:
    node.model = nil
    return

  node.model = model
  node.model.table_added = proc(index: int) =
    node.add_delegate(index)
    ouidebug "table row added at index " & $index
  node.model.table_removed = proc(index: int) =
    ouidebug "table row removed at index " & $index

proc show*(node: UiNode) =
  if node.kind == UiWindow:
    set_window_attributes(node.native, node.is_popup)
    resize_window(node.native, int node.w, int node.h)
    show_window(node.native)
  node.visible = true

proc hide*(node: UiNode) =
  if node.kind == UiWindow:
    hide_window(node.native)
  node.visible = false

when defined(testing) and is_main_module:
  import unittest

  proc main() =
    suite "node":
      var
        box1 = UiNode.init("box1", UiBox)
        box2 = UiNode.init("box2", UiBox)

      box1.w = 100
      box1.h = 100
      box2.fill(box1)

      test "contains":
        assert box1.contains(99, 99)
        assert box2.contains(50, 50)

        box2.set_left box2.right

        assert box2.contains(50, 50) == false
        assert box2.contains(105, 150) == false
        assert box2.contains(105, 50)
        assert box2.contains(105, 99)
  main()
