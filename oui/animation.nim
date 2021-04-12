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

import times
import types, node
import asyncdispatch
export asyncdispatch

template animate_via_delta(cond: untyped, speed: float32 = 0.001, inner, finished: untyped) =
  var 
    current_time = cpuTime()
    dt {.inject.} = 0.0

  while cond:
    var 
      new_time = cpu_time()
      frame_time = new_time - current_time
    current_time = new_time
    dt += frame_time
    while dt >= speed:
      dt -= speed

    inner
  finished

proc slide_node*(node, target: UiNode, direction: UiAlignment) {.async.} =
  var 
    old = target.x
    count = 0.0
    newx = 0.0

  node.animating = true
  animate_via_delta newx <= self.w, 2:
    target.visible = true
    count += 10
    if direction == UiRight:
      newx = count * dt
    elif direction == UiLeft:
      newx = count * dt
    target.x = newx
    node.queue_redraw(false)
  do:  
    target.x = old
    node.queue_redraw(true)
    node.animating = false
