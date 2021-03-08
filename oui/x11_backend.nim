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

import asyncdispatch
import cairo, cairoxlib, x11/x, x11/xlib, x11/xatom
import types

var xdisplay: PDisplay = nil
proc get_xdisplay*(): PDisplay =
  if xdisplay == nil:
    xdisplay = XOpenDisplay(nil)
  result = xdisplay

proc set_xwindow_attributes*(window: Window, popup: bool) =
  if popup:
    var attribs: XSetWindowAttributes
    attribs.override_redirect = 1
    var atom_type = XInternAtom(get_xdisplay(), "_NET_WM_WINDOW_TYPE", false.XBool)
    var atom = XInternAtom(get_xdisplay(), "_NET_WM_WINDOW_TYPE_DIALOG", false.XBool)
    discard XChangeProperty(get_xdisplay(), window, atom_type, XA_ATOM, 32,
        PropModeReplace, cast[Pcuchar](atom.addr), 1)
    discard XChangeWindowAttributes(get_xdisplay(), window,
        CWOverrideRedirect, addr attribs)
    discard XFlush(get_xdisplay())

proc map_xwindow*(window: Window) =
  discard XMapWindow(get_xdisplay(), window)
  discard XFlush(get_xdisplay())

proc unmap_xwindow*(window: Window) =
  discard XUnMapWindow(get_xdisplay(), window)
  discard XFlush(get_xdisplay())

proc resize_xwindow*(window: Window, width, height: int) =
  discard XMoveResizeWindow(get_xdisplay(), window, cint -1, cint -1,
      cuint width, cuint height)
  discard XFlush(get_xdisplay())

proc move_xwindow*(window: Window, x, y: int) =
  discard XMoveWindow(get_xdisplay(), window, cint x, cint y)
  discard XFlush(get_xdisplay())

proc create_xwindow*(): Window =
  var screen = XDefaultScreen(get_xdisplay())
  result =
    XCreateSimpleWindow(get_xdisplay(),
                        XRootWindow(get_xdisplay(), screen),
                        -1,
                        -1,
                        10,
                        10,
                        0,
                        XBlackPixel(get_xdisplay(), screen),
                        XWhitePixel(get_xdisplay(), screen))

  discard XSelectInput(get_xdisplay(), result,
                       ButtonPressMask or
                       ButtonReleaseMask or
                       KeyPressMask or
                       KeyReleaseMask or
                       PointerMotionMask or
                       StructureNotifyMask or
                       ExposureMask)

proc create_xcairo_surface*(window: Window, width,
    height: int): ptr Surface =
  xlibSurfaceCreate(get_xdisplay(),
                      window,
                      XDefaultVisual(get_xdisplay(), cint 0),
                      int32 width, int32 height)

proc native_from_xwindow(xwindow: Window): UiNative =
  when defined linux:
    for native in oui_natives:
      if native.xwindow == xwindow:
        return native
  nil

proc expose_xwindow*(xwindow: Window) =
  var ev: XEvent
  ev.theType = Expose
  ev.xexpose.window = xwindow
  discard XSendEvent(get_xdisplay(), xwindow, XBool(false), ExposureMask, addr ev)
  discard XFlush(get_xdisplay())

proc main_x11*() =
  var event: XEvent
  let fd = AsyncFD ConnectionNumber(get_xdisplay())
  fd.register()

  fd.add_read proc (fd: AsyncFD): bool {.gcsafe.} =
    case event.theType
    of Expose:
      var native = native_from_xwindow(event.xexpose.window)
      assert native.isNil() == false
      native.surface.xlib_surface_set_size(int32 native.width, int32 native.height)
      native.ctx = native.surface.create()
      exposecb(event.xexpose.x, event.xexpose.y, native)
      native.ctx.destroy()
    of KeyPress, KeyRelease:
      var
        key = XLookupKeysym(cast[PXKeyEvent](addr event), 0)
        native = native_from_xwindow(event.xkey.window)
        kmod = if event.theType == KeyPress: UiEventKeyPress else: UiEventKeyRelease
      assert native.isNil() == false
 
      if event.theType == KeyPress: 
        keycb(UiEventKeyPress, int event.xkey.x, int event.xkey.y, int event.xkey.keycode, $(XKeysymToString(key)), native)
      elif event.theType == KeyRelease:
        keycb(UiEventKeyRelease, int event.xkey.x, int event.xkey.y, int event.xkey.keycode, $(XKeysymToString(key)), native)
    of ButtonPress, ButtonRelease:
      var native = native_from_xwindow(event.xbutton.window)
      assert native.isNil() == false
      if event.theType == ButtonPress or event.xbutton.button == 4 or event.xbutton.button == 5: 
        buttoncb(UiEventMousePress, int event.xbutton.button, int event.xbutton.x, int event.xbutton.y, int event.xbutton.xroot,
          int event.xbutton.yroot, native)
      elif event.theType == ButtonRelease:
        buttoncb(UiEventMouseRelease, int event.xbutton.button, int event.xbutton.x, int event.xbutton.y, int event.xbutton.xroot,
          int event.xbutton.yroot, native)
    of MotionNotify:
      var native = native_from_xwindow(event.xmotion.window)
      assert native.isNil() == false
 
      motioncb(event.xmotion.x, event.xmotion.y, event.xmotion.xroot,
          event.xmotion.yroot, native)
    of ConfigureNotify:
      var native = native_from_xwindow(event.xconfigure.window)
      assert native.isNil() == false
 
      resizecb(event.xconfigure.width, event.xconfigure.height, native)
    else:
      discard
    return false

  while true:
    poll()
    while XPending(get_xdisplay()) > 0:
      discard XNextEvent(get_xdisplay(), addr event)
    oui_framecount.inc
