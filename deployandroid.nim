import oui

import nanovg

import osproc, os, threadpool, streams, json
import testmyway

when defined linux:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui/androidndk"
when defined windows:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui\\androidndk"

var settings: JsonNode

proc exec_terminal(cmd: string) =
  discard exec_cmd_ex("gnome-terminal -- /bin/bash -c '" & cmd &
    ";echo Exit by pressing enter;read line'",
    {poEvalCommand})

proc curl_cmdline_tools_and_jdk(loc: string) =
  when defined windows:
    var
      commands = @["curl -O https://dl.google.com/android/repository/android-ndk-r21e-windows-x86_64.zip",
        "Powershell.exe -Command \"Expand-Archive -Path android-ndk-r21e-windows-x86_64.zip\"",
        "rm -r android-ndk-r21e-windows-x86_64.zip"]
  var
    commands = @["curl -O https://d l.google.com/android/repository/commandlinetools-linux-6609375_latest.zip",
      "unzip commandlinetools-linux-6609375_latest.zip -d cmdline-tools && rm commandlinetools-linux-6609375_latest.zip",
      "curl -O https://builds.openlogic.com/downloadJDK/openlogic-openjdk/11.0.8%2B10/openlogic-openjdk-11.0.8%2B10-linux-x64.tar.gz",
      "tar -xvzf openlogic-openjdk-11.0.8%2B10-linux-x64.tar.gz --one-top-level=jdk --strip-components 1 && rm openlogic-openjdk-11.0.8%2B10-linux-x64.tar.gz"]
  for command in commands:
    echo "> " & command
    var process = start_process(command, "", [], nil, {poUsePath, poDaemon,
        poStdErrToStdOut, poEvalCommand})
    for line in process.lines:
      if line.len <= 0:
        continue
      oui_debug line
    process.close()

var installing_ndk: bool = false

proc install_android_sdk(location: string, cb: proc(l: string)) {.thread.} =
  if installing_ndk:
    oui_error "already installing android ndk"
    cb("bad")
    return
  if dir_exists(location):
    oui_error "delete '" & location & "' and try again"
    cb("bad")
    return

  installing_ndk = true
  create_dir(location)
  set_current_dir(location)
  curl_cmdline_tools_and_jdk(location)
  put_env("JAVA_HOME", location & "/jdk")
  var sdkmanager = "cmdline-tools/tools/bin/sdkmanager --sdk_root=sdk --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\""
  discard exec_cmd_ex("gnome-terminal -- " & sdkmanager, {poEvalCommand})
  oui_debug "done installing ndk"
  cb("good")
  installing_ndk = false

proc start_compiling(file, args: string, cb: proc(l: string)) {.thread.} =
  {.gcsafe.}:
    let
      target = "arm-linux-androideabi"
      toolchainpath = ANDROID_SDK_LOCATION &
          "/sdk/ndk-bundle/toolchains/llvm/prebuilt/" & settings{
              "host"}.get_str()
      clangpath = "--arm.android.clang.path=\"" & toolchainpath & "/bin" & "\""
      clangldexe = "--arm.android.clang.exe=\"clang\" --arm.android.clang.linkerexe=\"ld\" " & clangpath
      passc = "--passC=\"--target=" & target & $settings{"sdk_version"}.get_int() & "\""
      passl = "--passL=\"-L" & toolchainpath & "/sysroot/usr/lib/" & target &
          "/" & $settings{"sdk_version"}.get_int() & "\""
      nimcmd = "nim c " & clangldexe & " " & passc & " " & passl & " --threads:on --cpu:arm --os:android -d:androidNDK --noMain:on --cc:clang "
    echo "> " & nimcmd & args & file

#  nim c --arm.android.clang.exe="clang" --arm.android.clang.linkerexe="ld" --arm.android.clang.path="/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin" --passC="--target=arm-linux-androideabi29" --passL="-L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/29 -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -lgcc -llog -lm -lc -lEGL -lGLESv2"  --app:lib --cpu:arm --os:android -d:androidNDK --noMain:on --cc:clang demo
#  nim c --arm.android.clang.exe="clang" --arm.android.clang.linkerexe="ld" --arm.android.clang.path="/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin" --passC="--target=arm-linux-androideabi29" --passL="-L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/29 -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi -L/home/trey-c/.oui/androidndk/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x -lgcc -llog -lm -lc -lEGL -lGLESv2 -landroid"  -d:nvgGLES --app:lib --cpu:arm --os:android -d:androidNDK --noMain:on -f --cc:clang demo

# https://dl.google.com/android/repository/commandlinetools-win-7302050_latest.zip
#   "./cmdline-tools/tools/bin/sdkmanager --sdk_root=sdk --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\""
# ./sdkmanager --sdk_root=tools --install "platform-tools" "platforms;android-29" "build-tools;29.0.2" "ndk-bundle" "extras;google;usb_driver"
# ./sdkmanager --licenses
# ./adb devices -l
# ./adb logcat *:F

proc deploy_settings(file: string): JsonNode =
  discard exists_or_create_dir(".deployandroid/")
  set_current_dir(".deployandroid/")
  if file_exists(file):
    result = parse_json(read_file(file))
    echo result.pretty()
    echo result{"host"}.get_str()
  else:
    result = %* {
      "appname": "Example Oui App",
      "module": "path.nim",
      "host": "linux-x86_64",
      "abi": "armeabi",
      "sdk_version": 29
    }
    write_file(file, result.pretty())

template compiling(inner: untyped) =
  block:
    row:
      var latestlog = "asdfasdfsadf"
      text:
        update:
          str latestlog
      button:
        id btn
        text:
          str "Compile"
          update:
            center parent
        update:
          w parent.w
          h self[0].h
        pressed:
          spawn start_compiling("demo", "", proc(l: string) {.closure.} =
            echo "fuck"
          )
      inner


template android_page(inner: untyped) =
  block:
    row:
      var latestcmd = "asdfasdfsadf"
      text:
        update:
          str latestcmd
      button:
        id btn
        text:
          str "Setup android sdk"
          update:
            center parent
        update:
          w parent.w
          h self[0].h
        pressed:
          spawn install_android_sdk(ANDROID_SDK_LOCATION, proc(l: string) {.closure.} =
            latestcmd = l
            btn.window.queue_redraw(false)
          )
      inner

test_my_way "deploy mobile":
  settings = deploy_settings("settings.json")
  test "compiling":
    compiling():
      size 600, 600
      self.show()
  # test "android_page":
  #   android_page():
  #     size 600, 200
  #     self.show()



when is_main_module and not defined(testmyway):
  window:
    id app
    size 350, 550
    android_page():
      discard

    self.show()
