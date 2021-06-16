import oui

import nanovg

# proc install_android_sdk*(location: string, linecb: proc(l: string)) {.async.} =
#   var 
#     code = 0 
#   when defined(windows):
#     var mkdir = "mkdir "
#   when defined(linux):
#     var mkdir = "mkdir -p "
#   run_shell_command(mkdir & location, code):
#     linecb line & "\n"
#     await sleepAsync(1)
#   set_current_dir(location)
  
#   var 
#     sdk_root = "--sdk_root=" & normalized_path "./cmdline-tools"
#     sdkmanager = normalized_path "cmdline-tools/tools/bin/sdkmanager"
#     sdk_commands = @["wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip -p .", 
#       "unzip commandlinetools-linux-6609375_latest.zip -d cmdline-tools", 
#       "rm commandlinetools-linux-6609375_latest.zip", 
#       sdkmanager & " --update " & sdk_root,
#       sdkmanager & " --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\" " & sdk_root]
#   for cmd in sdk_commands:
#     run_shell_command(cmd, code):
#       linecb line & "\n"
#       await sleepAsync(1)

template main_page() =
  box:
    update:
      gradient self.w / 2, self.h / 2, rgb(0, 145, 00), rgb(0, 100, 0)
      size parent.w, parent.h / 2 * 0.5
    text:
      color "#eeeeee"
      str "Android"
      update:
        fill parent
        halign UiCenter
        valign UiCenter
  text:
    str "Tap on your target platform"
    update:
      fill parent
      halign UiCenter
      valign UiCenter
  box:
    update:
      gradient self.w / 2, self.h / 2, rgb(0, 0, 200), rgb(0, 0, 155)
      size parent.w, parent.h / 2 * 0.5
      bottom parent.bottom
    text:
      color "#eeeeee"
      str "IOS"
      update:
        fill parent
        halign UiCenter
        valign UiCenter

template android_page() =
  stack:
    id androidstack
    update:
      fill parent
    row:
      id ndksetup
      update:
        h parent.h * 0.8
        vcenter parent
      box:
        update:
          w parent.w
          h parent.h / 2
        color rgb(11, 11, 11)
        opacity 0.8
      button:
        update:
          size 30, parent.w
        text:
          str "Cancel the install"
          update:
            center parent

    row:
      id ndkinstall
      update:
        size parent.w * 0.5, parent.h * 0.5
        center parent
      spacing 20
      text:
        str "AndroidNDK isn't installed!"
        update:
          hcenter parent
      button:
        update:
          size parent.w, 30
        text:
          str "Install it now"
          update:
            center parent
        pressed:
          androidstack.stack_switch(ndksetup):
            discard
    
    


when is_main_module:
  window:
    id app
    size 350, 550
    android_page()
    
  app.show() ## Causes all the node's in the stack to become incorrectly visible
  androidstack.stack_switch(ndkinstall):
    discard
  
  oui_main()