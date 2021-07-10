import oui

import nanovg

import osproc, os, threadpool, streams, json, strutils
import testmyway

when defined linux:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui/androidndk"
when defined windows:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui\\androidndk"

var settings: JsonNode

proc exec_terminal(cmd: string): int =
  oui_log "> " & cmd
  result = execShellCmd(cmd)

proc curl_cmdline_tools_and_jdk(loc: string) =
  when defined windows:
    var
      commands = @["curl -O https://dl.google.com/android/repository/android-ndk-r21e-windows-x86_64.zip",
        "Powershell.exe -Command \"Expand-Archive -Path android-ndk-r21e-windows-x86_64.zip\"",
        "rm -r android-ndk-r21e-windows-x86_64.zip"]
  var
    commands = @["curl -O https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip",
      "unzip commandlinetools-linux-6609375_latest.zip -d cmdline-tools && rm commandlinetools-linux-6609375_latest.zip",
      "curl -O https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz",
      "tar -xvzf openlogic-openjdk-8u262-b10-linux-x64.tar.gz --one-top-level=jdk --strip-components 1 && rm openlogic-openjdk-8u262-b10-linux-x64.tar.gz"]
  for command in commands:
    echo "> " & command
    var process = start_process(command, "", [], nil, {poUsePath, poDaemon,
        poStdErrToStdOut, poEvalCommand})
    for line in process.lines:
      if line.len <= 0:
        continue
      oui_log line
    process.close()

var installing_ndk: bool = false

proc install_android_sdk(location: string) {.thread.} =
  if installing_ndk:
    oui_error "already installing android ndk"
    return
  if dir_exists(location):
    oui_error "delete '" & location & "' and try again"
    return

  installing_ndk = true
  create_dir(location)
  set_current_dir(location)
  curl_cmdline_tools_and_jdk(location)
  put_env("JAVA_HOME", location & "/jdk")
  var sdkmanager = "cmdline-tools/tools/bin/sdkmanager --sdk_root=sdk --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\""
  discard exec_cmd_ex("gnome-terminal -- " & sdkmanager, {poEvalCommand})
  oui_log "done installing ndk"
  installing_ndk = false

proc start_compiling(file, args: string): int =
  let
    target = "arm-linux-androideabi"
    toolchainpath = ANDROID_SDK_LOCATION &
        "/sdk/ndk-bundle/toolchains/llvm/prebuilt/" & settings{
            "host"}.get_str()
    clangpath = "--arm.android.clang.path=\"" & toolchainpath & "/bin" & "\""
    clangldexe = "--arm.android.clang.exe=\"clang\" --arm.android.clang.linkerexe=\"ld\" " & clangpath
    passc = "--passC=\"--target=" & target & $settings{"sdk_version"}.get_int() & "\""
    passl = "--passL=\"-L" & toolchainpath & "/sysroot/usr/lib/" & target &
        "/" & $settings{"sdk_version"}.get_int() & " -L" & toolchainpath &
            "/lib/gcc/" & target &
            "/4.9.x " & "-L" & toolchainpath & "/sysroot/usr/lib/" & target & " -lgcc -llog -lm -lc -lEGL -lGLESv2 -landroid\""
    nimcmd = "nim c " & clangldexe & " " & passc & " " & passl & " --app:lib --cpu:arm --os:android -d:androidNDK -d:nvgGLES2 --noMain:on --cc:clang "
  oui_log "> " & nimcmd & args & " " & file
  result = exec_terminal(nimcmd & args & file)

proc deploy_settings(file: string): JsonNode =
  if file_exists(file):
    result = parse_json(read_file(file))
    echo result.pretty()
    echo result{"host"}.get_str()
  else:
    result = %* {
      "appname": "Example Oui App",
      "module": "/home/trey/projects/oui/demo/demo.nim",
      "host": "linux-x86_64",
      "abi": "armeabi",
      "sdk_version": 29
    }
    write_file(file, result.pretty())

proc try_verifying_androidsdk(location: string): string =
  var sdk_requirements = @[
    @["cmdline-tools/", "cmdline-tools/tools/", "cmdline-tools/tools/bin/",
        "cmdline-tools/tools/bin/sdkmanager"],
    @["jdk/", "jdk/bin/", "jdk/lib/"],
    @["sdk/", "sdk/platform-tools/", "sdk/platform-tools/adb", "sdk/ndk-bundle/"]
  ]
  var fails: seq[string] = @[]
  for requirement in sdk_requirements:
    for dirorfile in requirement:
      if dirorfile[dirorfile.high] == '/':
        if not dir_exists(location & "/" & dirorfile):
          fails.add dirorfile
      else:
        if not file_exists(location & "/" & dirorfile):
          fails.add dirorfile
  if fails.len > 0:
    result = "the following androidsdk components couldn't be found:"
    for f in fails:
      result.add("\n" & ANDROID_SDK_LOCATION & " | " & f)
    result.add("\n..running the setup again will clear what was downloaded last time @" & ANDROID_SDK_LOCATION)
    oui_log result
  else:
    result = ""
    oui_log "enough androidsdk components were found to attempt building your app"

template verifying_page(inner: untyped) =
  var msg {.inject.} = ""
  block:
    row:
      button:
        update:
          w parent.w
          h 40
        pressed:
          spawn install_android_sdk(ANDROID_SDK_LOCATION)
        text:
          str "START SETUP"
          update:
            center parent
      text:
        update:
          str msg
          w parent.w
      inner

const ANDROID_MANIFEST_XML = """
<?xml version="1.0" encoding="utf-8"?>
<!-- BEGIN_INCLUDE(manifest) -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="net.ouiapp"
          android:versionCode="1"
          android:versionName="1.0"
          android:label="ouiapp"
        android:supportsRtl="true">

  <application android:allowBackup="false" 
    android:fullBackupContent="false"
     android:hasCode="true"
     android:label="ouiapp">
  
    <activity android:name="android.app.NativeActivity">
      <meta-data android:name="android.app.lib_name"
             android:value="ouiapp"/>
      <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>

      <intent-filter>
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <action android:name="android.intent.action.SEND" />
            <action android:name="android.intent.action.SENDTO" />

            <data android:scheme="sms" />
            <data android:scheme="smsto" />
            <data android:scheme="mms" />
            <data android:scheme="mmsto" />
      </intent-filter>

    </activity>
  </application>

</manifest>"""

const RES_VALUE_STRINGS_XML = """
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">OuiApp</string>
</resources>
"""

const NET_OUIAPP_OUI_ACTIVITY_JAVA = """
package net.ouiapp;
import android.app.Activity;
import android.os.Bundle;
/**
* android.app.NativeActivity is actually being used not this. apk builder
* needs this.
*/
public class OuiActivity extends Activity {
    static { System.loadLibrary("ouiapp"); }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
"""

proc create_apk2() =
  # Super helpful: https://stackoverflow.com/questions/59504840/create-jni-ndk-apk-only-command-line-without-gradle-ant-or-cmake
  let
    build_tools = ANDROID_SDK_LOCATION & "/sdk/build-tools/29.0.2"
    platform = ANDROID_SDK_LOCATION & "/sdk/platforms/android-" & $settings[
        "sdk_version"].get_int()
    ndk = ANDROID_SDK_LOCATION & "/sdk/ndk-bundle"
    cc = ndk & "toolchains/llvm/prebuilt/" & settings{"host"}.get_str() &
        "/bin/" & settings["abi"].get_str() & "-linux-androideabi-" & $settings[
            "sdk_version"].get_int() & "-clang"
    androidjar = platform & "/android.jar "
    aapt = build_tools & "/aapt "
    aapt2 = build_tools & "/aapt2 "
    dx = build_tools & "/dx "
    zipalign = build_tools & "/zipalign "
    apksigner = build_tools & "/apksigner "
    keystore_loc = get_home_dir() & ".android/debug.keystore"

  let output = "output"
  discard exists_or_create_dir(output)
  set_current_dir(output)

  for folder in @["net", "net/ouiapp", "res", "res/values", "assets", "gen", "obj"]:
    discard exists_or_create_dir(folder)

  write_file("AndroidManifest.xml", ANDROID_MANIFEST_XML)
  write_file("res/values/strings.xml", RES_VALUE_STRINGS_XML)
  write_file("net/ouiapp/OuiActivity.java", NET_OUIAPP_OUI_ACTIVITY_JAVA)

  copy_dir(get_home_dir() & ".oui/fonts", "assets/font")
  discard start_compiling(settings["module"].get_str(), "-o:lib/" &
      settings["abi"].get_str() & "/libouiapp.so ")

  put_env("JAVA_HOME", ANDROID_SDK_LOCATION & "/jdk/jre")
  put_env("PATH", get_env("PATH") & ":" & ANDROID_SDK_LOCATION & "/jdk/bin")
  let
    cmds = [
      aapt2 & "compile --dir res -o resources.zip",
      aapt2 & "link -o output.apk resources.zip -I " & androidjar &
      "--manifest AndroidManifest.xml -A assets -v",
      "zip output.apk lib/armeabi/libouiapp.so",
      "javac -bootclasspath " & ANDROID_SDK_LOCATION &
      "/jdk/jre/lib/rt.jar -classpath " & platform &
      "/android.jar -d obj -sourcepath java:gen net/ouiapp/OuiActivity.java -source 1.7 -target 1.7",
      dx & "--dex --output=classes.dex obj",
      aapt & "a output.apk classes.dex",
      zipalign & "4 output.apk output-aligned.apk",
      # "keytool -genkey -v -keystore " & keystore_loc &
        # " -alias androiddebugkey -storepass android -keypass android -keyalg RSA -validity 14000",
      apksigner & "sign --ks " & keystore_loc &
      " --ks-pass pass:android --out final-output.apk output-aligned.apk",
      "rm -rf resources.zip gen obj classes.dex",
    ]
  for cmd in cmds:
    if exec_terminal(cmd) != 0:
      break

test_my_way "deploy mobile":
  discard exists_or_create_dir(".deployandroid/")
  set_current_dir(".deployandroid/")
  var error_msg = try_verifying_androidsdk(ANDROID_SDK_LOCATION)
  settings = deploy_settings("settings.json")
  # test "setup and verifing":
  #   discard
  #   window:
  #     size 100, 100
  #     stack:
  #       update:
  #         fill parent
  #       verifying_page:
  #         discard
  #     self.show()

  #       compiling:
  #         visible error_msg.len == 0
  # # test "compiling":
  # #   compiling():
  # #     size 600, 600
  # #     self.show()
  # test "android_page":
  #   android_page():
  #     size 600, 200
  # self.show()
  testmyway "make_apk":
    remove_dir("output")
    create_apk2()
    discard
do:
  discard



when is_main_module and not defined(testmyway):
  window:
    id app
    size 600, 300
    resizable false
  # resizable false
  #   android_page():
  #     discard

  #   self.show()
