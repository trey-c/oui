import glfw, nanovg
import oui/types, oui/node, oui/sugarsyntax, oui/ui, oui/utils
export types, node, sugarsyntax, utils, ui
import nimclipboard/libclipboard
export libclipboard
import testmyway

proc no_windows_opened(): bool =
  for window in windows:
    if window.handle.shouldClose() == false:
      return false
  true

proc oui_main*() =
  when glfw_supported():
    
    var close = false
    while close != true:
      glfw.swapInterval(0) 
      for window in windows:
        if window.handle.shouldClose():
          if no_windows_opened():
            close = true
        glfw.makeContextCurrent(window.handle)
        window.draw_opengl()
        glfw.swapBuffers(window.handle)
       
      glfw.waitEvents()

testmyway "oui":
  test "no_windows_opened":
    check no_windows_opened()
    window:
      id win
    win.show()
    check no_windows_opened() == false
    window:
      id win2
    check no_windows_opened() == false
    win2.show()
    win.hide()
    check no_windows_opened() == false
    win2.hide()
    check no_windows_opened()
  
  test "oui_main":
    window:
      id app
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
          str "Click me"
          size 15
          color 245, 245, 245
          face "sans"
    app.show()
    oui_main()   