import glfw
import oui/types, oui/node
export types, node
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
    var win = UiNode.init("win", UiWindow)
    check no_windows_opened() == false
    win.show()
    var win2 = UiNode.init("win2", UiWindow)
    check no_windows_opened() == false
    win2.show()
    win.handle.shouldClose = true
    check no_windows_opened() == false
    win2.handle.shouldClose = true
    check no_windows_opened()
  
  test "oui_main":
    oui_main()   