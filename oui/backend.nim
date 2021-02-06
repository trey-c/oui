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

import cairo
import types

when defined(linux):
  import x11_backend
when defined(android):
  import android_backend
when defined(windows):
  import win32_backend

proc oui_main*() =
  when defined(linux):
    main_x11()
  when defined(windows):
    main_win32()

proc init*(t: type UiNative, width, height: int): UiNative =
  when defined(linux):
    result = UiNative(xwindow: create_xwindow(), surface: nil, ctx: nil,
                      width: width, height: height, received_event: nil)
    result.surface = create_xcairo_surface(result.xwindow, width, height)
    result.ctx = create(result.surface)
  when defined windows:
    result = UiNative(hwnd: 0, surface: nil, ctx: nil,
                      width: width, height: height, received_event: nil)
    result.hwnd = create_hwnd(result)

  oui_natives.add result

proc set_window_attributes*(native: UiNative, popup: bool) =
  when defined(linux):
    set_xwindow_attributes(native.xwindow, popup)
  when defined(windows):
    set_hwnd_attributes(native.hwnd, popup)

proc show_window*(native: UiNative) =
  when defined(linux):
    map_xwindow(native.xwindow)
  when defined(windows):
    map_hwnd(native.hwnd)

proc hide_window*(native: UiNative) =
  when defined(linux):
    unmap_xwindow(native.xwindow)
  when defined(windows):
    unmap_hwnd(native.hwnd)

proc resize_window*(native: UiNative, width, height: int) =
  when defined(linux):
    resize_xwindow(native.xwindow, width, height)
  when defined(windows):
    resize_hwnd(native.hwnd, width, height)

proc move_window*(native: UiNative, x, y: int) =
  when defined(linux):
    move_xwindow(native.xwindow, x, y)
  when defined(windows):
    move_hwnd(native.hwnd, x, y)

proc expose*(native: UiNative) =
  when defined(linux):
    expose_xwindow(native.xwindow)
  when defined(windows):
    expose_hwnd(native.hwnd)
