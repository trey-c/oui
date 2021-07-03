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
# import glfm

when is_main_module:
  window:
    id app
    size 600, 400
    button:
      size 200, 30
      text:
        str "Press if u hate graphs"
        update:
          center parent
      update:
        center parent
        self.minw = self[0].minw * 1.5
        self.minh = self[0].minh * 1.5
    update:
      self.minw = self[0].minw
      self.minh = self[0].minh

    app.show()

# ➤ nim c --cpu:arm --os:android -d:androidNDK cd-d:noSignalHandler --passC="--target=arm-linux-androideabi29 -w -ferror-limit=3 -pthread -fno-asynchronous-unwind-tables" --passl:"-LC:\Users\trey\.oui\cmdline-tools\bin\cmdline-tools\ndk\21.2.6472646\toolchains\llvm\prebuilt\windows-x86_64\sysroot\usr\lib\arm-linux-androideabi\29 -LC:\Users\trey\.oui\cmdline-tools\bin\cmdline-tools\ndk\21.2.6472646\toolchains\llvm\prebuilt\windows-x86_64\lib\gcc\arm-linux-androideabi\4.9.x -llog -lc -lgcc" --cc:clang demo.ni
#im c --arm.android.clang.exe="clang" --arm.android.clang.linkerexe="ld" --arm.android.clang.path="/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin" --passC="--target=arm-linux-androideabi29" --passL="-L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/29 -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -lgcc -llog -lm -lc -lEGL -lGLESv2 -landroid"  -d:nvgGLES3 --app:lib --cpu:arm --os:android -d:androidNDK --noMain:on --cc:clang demo


# proc NimMain() {.importc.}

# proc glfmMain*(display: ptr GLFMDisplay) {.exportc.} =
#   NimMain()
#   echo "Hello, World! - oui"
