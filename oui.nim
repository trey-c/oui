import glfw, nanovg
import oui/types, oui/node, oui/sugarsyntax, oui/ui, oui/utils
export types, node, sugarsyntax, utils
import testmyway

proc no_windows_opened(): bool =
  for window in windows:
    if window.handle.shouldClose() == false:
      return false
  true

proc oui_main*() =
  when glfw_supported():
    glfw.swapInterval(0)
    var close = false
    while close != true:
      for window in windows:
        glfw.makeContextCurrent(window.handle)
        window.draw_opengl()
        glfw.swapBuffers(window.handle)

        if window.handle.shouldClose():
          if no_windows_opened():
            close = true
      glfw.waitEvents()

testmyway "oui":
  test "no_windows_opened":
    check no_windows_opened()
    window win:
      discard
    win.show()
    check no_windows_opened() == false
    window win2:
      discard
    check no_windows_opened() == false
    win2.show()
    win.hide()
    check no_windows_opened() == false
    win2.hide()
    check no_windows_opened()
  
  test "oui_main":
    window app:
      size 100, 100
      button_press:
        echo "coime AT me draew"
      button:
        update:
          size 100, 28
          center app
        pressed:
          echo "Click me"
        text:
          update:
            fill parent
          var font = self.window.vg.createFont("icons", "entypo.ttf")
          if font == NoFont:
            oui_error "Couldn't load font" 
          str "Clicfk me"
          size 11
          color 100, 0, 100
          face "icons"
    app.show()
    oui_main()   