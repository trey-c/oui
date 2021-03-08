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

import asyncdispatch, strutils
import cairo, cairowin32, winim, winim/inc/windef
import types

proc set_hwnd_attributes*(hwnd: HWND, popup: bool) =
  if popup:
    hwnd.SetWindowLongPtrW(GWL_STYLE, WS_POPUP)
  hwnd.UpdateWindow()

proc map_hwnd*(hwnd: HWND) =
  hwnd.ShowWindow(1)
  hwnd.UpdateWindow()

proc unmap_hwnd*(hwnd: HWND) =
  hwnd.ShowWindow(SW_SHOW)
  hwnd.UpdateWindow()

proc resize_hwnd*(hwnd: HWND, width, height: int) =
  hwnd.SetWindowPos(0, 0, 0, int32 width, int32 height, SWP_NOMOVE or
      SWP_NOOWNERZORDER or SWP_NOZORDER)
  hwnd.UpdateWindow()

proc move_hwnd*(hwnd: HWND, x, y: int) =
  hwnd.SetWindowPos(0, int32 x, int32 y, 0, 0, SWP_NOSIZE)
  hwnd.UpdateWindow()

proc set_hwnd_title*(hwnd: HWND, title: string) =
  hwnd.SetWindowTextA(cstring title)
  hwnd.UpdateWindow()

proc native_from_hwnd*(hwnd: HWND): UiNative =
  when defined windows:
    for native in oui_natives:
      if native.hwnd == hwnd:
        return native
  nil

proc expose_hwnd*(hwnd: HWND) =
  InvalidateRect(hwnd, nil, false)
  UpdateWindow(hwnd)

proc handle_message(hwnd: HWND, msg: UINT, wparam: WPARAM,
    lparam: LPARAM): LRESULT {.stdcall.} =
  var native = native_from_hwnd(hwnd)
  case msg:
  of WM_MOUSEWHEEL:
    var delta = cast[int](GET_WHEEL_DELTA_WPARAM(wparam))
    if delta >  0:
       buttoncb(UiEventMousePress, 4, cast[int](
          GET_X_LPARAM(lparam)), cast[int](GET_Y_LPARAM(lparam)), -1, -1, native)
    else:
      buttoncb(UiEventMousePress, 5, cast[int](
          GET_X_LPARAM(lparam)), cast[int](GET_Y_LPARAM(lparam)), -1, -1, native)
  of WM_SIZE:
    var r: RECT
    native.hwnd.GetClientRect(addr r)
    resizecb(int(r.right - r.left), int(r.bottom - r.top), native)
  of WM_KEYUP, WM_KEYDOWN:
    var key = cast[int](wparam)
    var ch = $cast[char](wparam)
    ch = ch.toLowerAscii()
    if msg == WM_KEYDOWN:
      keycb(UiEventKeyPress, native.trackx, native.tracky, key, $ch, native)
    elif msg == WM_KEYUP:
      keycb(UiEventKeyRelease,  native.trackx, native.tracky, key, $ch, native)
  of WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN, WM_XBUTTONDOWN,
      WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP, WM_XBUTTONUP:
    var button = 1
    if msg == WM_LBUTTONDOWN or msg == WM_LBUTTONUP:
      button = 1
    elif msg == WM_RBUTTONDOWN or msg == WM_RBUTTONUP:
      button = 2
    elif msg == WM_MBUTTONDOWN or msg == WM_MBUTTONUP:
      button = 3
    else:
      button += 3 + cast[int](GET_XBUTTON_WPARAM(wparam))

    if msg == WM_LBUTTONDOWN or msg == WM_RBUTTONDOWN or msg ==
        WM_MBUTTONDOWN or msg == WM_XBUTTONDOWN:
      buttoncb(UiEventMousePress, button, cast[int](
          GET_X_LPARAM(lparam)), cast[int](GET_Y_LPARAM(lparam)), -1, -1, native)
    else:
      buttoncb(UiEventMouseRelease, button, cast[int](
          GET_X_LPARAM(lparam)), cast[int](GET_Y_LPARAM(lparam)), -1, -1, native)
  of WM_PAINT:
    var
      dc: HDC
      ps: PAINTSTRUCT
    dc = BeginPaint(hwnd, addr(ps))

    native.surface = win32_surface_create(dc)
    native.ctx = native.surface.create()
    exposecb(native.surface.get_width, native.surface.get_height, native)
    native.surface.destroy()
    native.ctx.destroy()

    discard EndPaint(hwnd, addr(ps))
  of WM_MOUSEMOVE:
    native.trackx = cast[int](GET_X_LPARAM(lparam))
    native.tracky = cast[int](GET_Y_LPARAM(lparam))
    motioncb(native.trackx, native.tracky, -1, -1, native)
  else:
    result = DefWindowProc(hwnd, msg, wparam, lparam)

proc create_hwnd*(native: UiNative): HWND =
  var wc: WNDCLASS
  wc.style = CS_HREDRAW or CS_VREDRAW
  wc.cbClsExtra = 0
  wc.cbWndExtra = 0
  wc.hInstance = 0
  wc.hIcon = 0
  wc.hCursor = 0
  wc.hbrBackground = COLOR_WINDOW+1
  wc.lpszMenuName = nil
  wc.lpszClassName = "app"
  wc.lpfnWndProc = handle_message
  discard RegisterClass(wc)

  result = CreateWindow("app", "oui", WS_OVERLAPPEDWINDOW, 0,
      0, 240, 160, 0, 0, 0, nil)

  discard SetWindowLongPtr(result, GWLP_USERDATA, cast[LONG_PTR](
      addr native[]))

proc main_win32*() =
  var msg: MSG
  while true:
    try:
      poll(100)
    except:
      discard

    while PeekMessage(addr msg, 0, 0, 0, PM_REMOVE) == windef.TRUE:
      discard TranslateMessage(addr msg)
      discard DispatchMessage(addr msg)
    oui_framecount.inc
