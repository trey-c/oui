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
  size 100, 100
  text:
    str "Ocicat Ui"
    size 32
    update:
      bottom parent.bottom
      hcenter parent

  box:
    color green(255)
    shadow true, 20, 16, 16, black(240)
    update:
      w parent.w - 200
      h 200
      center parent

  self.show()
