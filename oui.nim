import nanovg
import oui/types, oui/node, oui/sugarsyntax, oui/ui, oui/utils, oui/table
export types, node, sugarsyntax, utils, ui, nanovg, table
when not defined android:
  import nimclipboard/libclipboard
  export libclipboard
import testmyway

when glfw_supported():
  import glfw

when defined android:
  import glfm
