## Ocicat Ui Framework (oui)

> :warning: Read the [manual](doc/MANUAL.md) before trying and understand that **oui** is pre-v1.0.0 :warning:

Open source, and expressive Ui framework with near native preformance, an easy to use syntax, addon modules, animations, and a GUI for seamless deployments (Android & Linux & Windows)

### Features

- Animations
- Low memory usage
- GUI for cross-platform deployments
- No html/css/nodejs
- Support for multiple backends
  * Android/Egl
  * X11
  * Wayland
  * Win32
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
  * ListView
  * StackView
  * SwipeView
  * Popup
- Addons that add support for
  * MapBox `(very soon)`

### Minimal code example

Check out the [demo](/demo) application for a more realistic example. Or read the [manual](doc/MANUAL.md) for an explanation of whats below

```nim
import oui/ui

window app:
  title "Minimal App"
  size 600, 400
  box:
    color "#212121"
    update:
      fill parent
      w parent.w / 2
  
app.show()
oui_main()
```

### Dependencies

Listed below is what certain or all **oui** modules depend on. Nimble dependencies are listed in the oui.nimble file

- All
  * nim
  * cairo
  * pango
- oui/x11_backend.nim
  * xlib
- oui/win32_backend.nim
  * win32 api
- oui/android_backend.nim
  * egl
  * androidndk

#### Addons

- oui/mapbox.nim
  * mapbox-gl-native

### Installing/building

#### Nim

www.nim-lang.org/downloads

```shell
> curl https://nim-lang.org/choosenim/init.sh -sSf | sh
> choosenim
> export PATH=$PATH:/home/<user>/.nimble/bin
```
#### Dependencies

##### Android or any addons

You may grab the needed dependencies via `ouideploy` **coming very soon**

##### Linux (Ubuntu)

```shell
> sudo apt-get install cairo-devel pango-devel
```

##### Linux (Arch)

```shell
> sudo pacman -S cairo pango
```

##### Linux (OpenSUSE)

```shell
> sudo zypper in cairo-devel pango-devel
```

##### Windows 10

www.msys2.org or any other method for installing mingw64 packages

```shell
> pacman -S --needed base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-cairo mingw-w64-x86_64-pango
```
#### oui

```shell
> git clone https://github.com/trey-c/oui.git
> cd oui
> nimble install
```

### License

**oui** is licensed under the Apache-2.0 License - check [LICENSE](LICENSE) for more details

**note** that a few borrowed private modules are licensed under the MIT license
