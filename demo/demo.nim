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

window:
  id app
  color rgb(10, 100, 10)
  color "#324344"

  size 899, 900
  var txtstr = ""
  var txtstr1 = ""
  var txtstr2 = ""
  var txtstr3 = ""
  var txtstr4 = ""

  column:
    spacing 5
    update:
      fill parent
    row:
      spacing 20
      update:
        w 100
        h parent.h
      textbox:
        update:
          size 100, 34
      do: txtstr
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr1
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr2
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr3
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr4
      do: "Username"

    row:
      spacing 20
      update:
        w 100
        h parent.h
      textbox:
        update:
          size 100, 34
      do: txtstr
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr1
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr2
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr3
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr4
      do: "Username"

    row:
      spacing 20
      update:
        w 100
        h parent.h
      textbox:
        update:
          size 100, 34
      do: txtstr
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr1
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr2
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr3
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr4
      do: "Username"

    row:
      spacing 20
      update:
        w 100
        h parent.h
      textbox:
        update:
          size 100, 34
      do: txtstr
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr1
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr2
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr3
      do: "Username"
      textbox:
        update:
          size 100, 34
      do: txtstr4
      do: "Username"
app.show()


