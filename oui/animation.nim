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

import math, os, asyncdispatch
import types, node

# Dunno whats up with nimpretty

template timer*(clock, interval: int, inner: untyped) = # TODO less hacky
                                                                                                var i {.gensym.} = 0
                                                                                                add_timer(clock, false, proc (asyncfd: AsyncFd): bool {.gcsafe.} =
                                                                                                                                                                                                if i < interval:
                                                                                                                                                                                                                                                                                                inner
                                                                                                                                                                                                else:
                                                                                                                                                                                                                                                                                                discard: # destroy timer?
                                                                                                                                                                                                i.inc
                                                                                                )


template timer*(clock, inner: untyped) =
                                                                                                add_timer(clock, false, proc (asyncfd: AsyncFd): bool {.gcsafe.} =
                                                                                                                                                                                                inner
                                                                                                )

proc fade_node*(self, window, target: UiNode, direction: UiAlignment) =
                                                                                                assert window.kind == UiWindow
                                                                                                self.animating = true
                                                                                                var old = target.x
                                                                                                for i in 1..int(target.x):
                                                                                                                                                                                                echo i
                                                                                                                                                                                                if direction == UiRight:
                                                                                                                                                                                                                                                                                                target.x = i.float32 + 1
                                                                                                                                                                                                elif direction == UiLeft:
                                                                                                                                                                                                                                                                                                target.x = i.float32 - 1

                                                                                                                                                                                                target.x = i.float32
                                                                                                                                                                                                window.queue_redraw(self, true)
                                                                                                                                                                                                sleep(2)
                                                                                                target.x = old
                                                                                                self.animating = false
