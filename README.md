## Ocicat Ui Framework (oui)

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

#### Addons

- oui/mapbox.nim
  * mapbox-gl-native

### Installing/building

#### Nim

https://www.nim-lang.org/downloads

#### Linux 

**Check https://www.nim-lang.org/downloads and go grab nim's latest version (v1.4.x)**

Install a package like `glfw` or `glfw-x11` or `glfw-wayland` from your distro's package manager.
`nim` can be also installed using your package manager, but only if it contains the latest nim version 

#### Windows 10

https://www.msys2.org or any other method for installing mingw64 packages

Avoid installing glfw or nano because the nim bindings use their c source files for static compilation.

```shell
> pacman -S --needed base-devel mingw-w64-x86_64-gcc mingw-w64-x86_64-nim mingw-w64-x86_64-nimble mingw-w64-x86_64-nimble
```

#### Android

> Android studio is **not** required

Run the gui `deploymobile` and connect an Android device to your computer.

#### oui

```shell
> git clone https://github.com/trey-c/oui.git
> cd oui
> nimble install
```

### License

**oui** is licensed under the Apache-2.0 License - check [LICENSE](LICENSE) for more details
