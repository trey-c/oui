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

import oui
import nanovg
import oui/table
 
when is_main_module:
  window:
    id app
    size 600, 400
    var data = @[
      ("Canada", "55"), 
      ("U.S", "104"),
      ("Russia", "35"),
      ("China", "65"),
      ("U.K", "51"),
      ("Mexico", "55"),
    ]
    bargraph:
      update:
        w app.w / 2
        h app.h / 2
    do: data
    do: 8

    bargraph:
      update:
        w app.w / 2
        h app.h / 2
        right parent.right
    do: data
    do: 8

    bargraph:
      update:
        w app.w / 2
        h app.h / 2
        bottom parent.bottom
    do: data
    do: 8

    bargraph:
      update:
        w app.w / 2
        h app.h / 2
        bottom parent.bottom
        right parent.right
    do: data
    do: 8

    button:
      size 200, 30
      update:
        center parent
      text:
        str "Press if u hate graphs"
        update:
          center parent
  app.show()
  oui_main()
