## Ocicat Ui Framework (oui)

:warning: :warning: :warning: **Repo is temporarily frozen as I've been rewriting 'nanovg'** :warning: :warning: :warning:

> :warning: Read the [manual](doc/MANUAL.md) before trying and understand that **oui** is pre-v1.0.0 with **lots of bugs** :warning:

Open source, and expressive Ui framework with near native preformance, an easy to use syntax, addon modules, and a GUI for seamless deployments (Desktop & Mobile)

### Features

- No html/css/nodejs
- Support for both desktop & mobile via glfw/glfm
- GUI for cross-platform deployments
- Drawing is done via nanovg
- 7 UiNodes
  * Window
  * Box
  * Text
  * Canvas
  * Image
  * Layout
- 9 included widgets (Aka. 1 or more UiNodes)
  * Button
  * Textbox
  * Combobox
  * Row
  * Column
  * List
  * Stack
  * SwipeView
  * Popup
- Addons that add support for
  * MapBox `(very soon)`

### Minimal code example

```nim
import oui

window:
  id app
  title "Minimal App"
  size 600, 400
  color 0, 0, 200
  box:
    color "#212121"
    update:
      fill parent
      w parent.w / 2
app.show()
```

Check out the [demo](/demo) application for a more realistic example. Or read the [manual](doc/MANUAL.md) for an explanation of whats above

### Dependencies

Listed below is what certain or all **oui** modules depend on. Nimble dependencies are listed in the oui.nimble file

- nim v1.4.x
- nanovg
- glfw (desktop only)
- gflm (mobile only)
- androidndk (android only)
- oui's tangram-es fork (`oui/map.nim` only)

### Installing/building

#### Linux 

**Check https://www.nim-lang.org/downloads and go grab nim's latest version (v1.4.x)**

Install a package like `glfw` or `glfw-x11` or `glfw-wayland` from your distro's package manager.
`nim` can be also installed using your package manager, but only if it contains the latest nim version 

#### Windows 10

Download git https://git-scm.com/downloads
Download nim https://www.nim-lang.org/downloads

```shell
> git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
> cd C:\vcpkg
> .\bootstrap-vcpkg.bat
> .\vcpkg install glfw3:x64-windows
> .\vcpkg integrate install
```

**importing `oui/map.nim` requires**
  - CMake https://cmake.org/download/ 
  - MSBuild (using the Visual Studio 
  Installer) https://visualstudio.microsoft.com/downloads/
  - oui's tangram-es fork https://github.com/trey-c/tangram-es.git. 

#### Android

> Android studio and gradle are **not** required

The following information is lacking. A more detailed explination will be added to the manual at somepoint.

Execute the CLI `oui/deployandroid` to download/setup the >5gb androidsdk.

`> oui/deployandroid setup sdk:29 jdk:8`

Compile your nim modules/files like so:

`> oui/deployandroid buildapk abi:armeabi nimfile:/absolute/path/app.nim`
Your built apk will be located @ 'working_dir/.generated/final-output.apk'

Connect your device via USB (make sure developer mode & usb debugging is enabled!)

`> oui/deployandroid buildapk abi:armeabi nimfile:/absolute/path/app.nim`
`> oui/deployandroid logcat`

#### oui

```shell
> git clone https://github.com/trey-c/oui.git
> cd oui
> nimble install
```

### License

**oui** is licensed under the Apache-2.0 License - check [LICENSE](LICENSE) for more details
