import oui

import nanovg

import osproc, os, threadpool, streams, json, strutils
import testaid

when defined linux:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui/androidndk"
when defined windows:
  const ANDROID_SDK_LOCATION = get_home_dir() & ".oui\\androidndk"

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

proc buildlib(toolchain, target, file: string): int =
  let
    clangpath = "--arm.android.clang.path=\"" & toolchain & "/bin" & "\""
    clangldexe = "--arm.android.clang.exe=\"clang\" --arm.android.clang.linkerexe=\"ld\" " & clangpath
    passc = "--passC=\"--target=" & target & $settings{"sdk_version"}.get_int() & "\""
    passl = "--passL=\"-L" & toolchain & "/sysroot/usr/lib/" & target &
        "/" & $settings{"sdk_version"}.get_int() & " -L" & toolchain &
            "/lib/gcc/" & target &
            "/4.9.x " & "-L" & toolchain & "/sysroot/usr/lib/" & target & " -lgcc -llog -lm -lc -lEGL -lGLESv2 -landroid\""
    nimcmd = "nim c " & clangldexe & " " & passc & " " & passl & " --app:lib --cpu:arm --os:android -d:androidNDK -d:nvgGLES2 --noMain:on --cc:clang "
  oui_log "> " & nimcmd & file
  result = exec_terminal(nimcmd & file)

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
        if not dir_exists(normalized_path(location & "/" & dirorfile)):
          fails.add dirorfile
      else:
        if not file_exists(normalized_path(location & "/" & dirorfile)):
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

proc generate_output_structure(output: string) =
  if dir_exists(output):
    remove_dir(output)
  discard exists_or_create_dir(output)
  set_current_dir(output)
  for folder in @["net", "net/ouiapp", "res", "res/values", "assets", "gen", "obj"]:
    discard exists_or_create_dir(normalized_path(folder))
  write_file("AndroidManifest.xml", ANDROID_MANIFEST_XML)
  write_file(normalized_path("res/values/strings.xml"), RES_VALUE_STRINGS_XML)
  write_file(normalized_path("net/ouiapp/OuiActivity.java"), NET_OUIAPP_OUI_ACTIVITY_JAVA)

proc zip_and_sign_apk(jdk, platform, build_tools,
  androidjar, keystore_loc: string) =
  let
    zip_apk_cmds = @[
      build_tools & normalized_path("/aapt2") &
          " compile --dir res -o resources.zip",
      build_tools & normalized_path("/aapt2") &
          " -o output.apk resources.zip -I " & androidjar &
      "--manifest AndroidManifest.xml -A assets -v",
      "zip output.apk " & normalized_path("lib/armeabi/libouiapp.so"),
      "javac -bootclasspath " & jdk & normalized_path("/jre/lib/rt.jar") &
        " -classpath " & androidjar & " -d obj -sourcepath java:gen " &
            normalized_path("net/ouiapp/OuiActivity.java") &
                " -source 1.7 -target 1.7",
      build_tools & normalized_path("/dx") & " --dex --output=classes.dex obj",
      build_tools & normalized_path("/aapt") & " a output.apk classes.dex",
      build_tools & normalized_path("/zipalign") & " 4 output.apk output-aligned.apk"
    ]
  for cmd in zip_apk_cmds:
    if exec_terminal(cmd) != 0:
      break
  if not file_exists(keystore_loc):
    if exec_terminal("keytool -genkey -v -keystore " & keystore_loc &
        " -alias androiddebugkey -storepass android -keypass android -keyalg RSA -validity 14000") != 1:
      return
  discard exec_terminal(build_tools & normalized_path("/apksigner") &
      " sign --ks " & keystore_loc & " --ks-pass pass:android --out final-output.apk output-aligned.apk")

proc buildapk(jdk, build_tools, platform, ndk, output: string) =
  put_env("JAVA_HOME", jdk & "/jre")
  put_env("PATH", get_env("PATH") & ":" & jdk & "/bin")
  let
    androidjar = normalized_path(platform & "/android.jar ")
    keystore_loc = normalized_path(get_home_dir() & ".android/debug.keystore")
  zip_and_sign_apk(jdk, platform, build_tools, androidjar, keystore_loc)
  remove_dir("gen")
  remove_dir("obj")
  remove_file("output-aligned.apk")
  remove_file("output.apk")

proc build(sdk, output: string, args: JsonNode, apk: bool) =
  generate_output_structure(output)
  let
    ndk = normalized_path(sdk & "/sdk/ndk-bundle")
    platform = normalized_path(sdk & "/sdk/platforms/android-" & $settings[
        "sdk_version"].get_int())
    toolchain = normalized_path(ndk & "/toolchains/llvm/prebuilt/" & settings{
            "host"}.get_str())
    jdk = normalized_path(sdk & "/jdk")
    build_tools = normalized_path(sdk & "sdk/build-tools/29.0.2")
    target = args["abi"].get_str()
    nimfile = args["nimfile"].get_str()
  discard buildlib(toolchain, target, nimfile)
  if apk:
    buildapk(jdk, build_tools, platform, ndk,
      ".generated")

proc grab_args(): JsonNode =
  result = parseJson("{}")
  if param_count() >= 2:
    for i in 2..param_count():
      var param = param_str(i).split(':')
      result[param[0]] = new_j_string(param[1])

when is_main_module and not defined(testaid):
  proc main() =
    if param_count() == 0:
      styled_echo fgRed,
        "[setup | verify | buildlib | buildapk | installapk | logcat | clean]"
      return
    var args = grab_args()
    case param_str(1):
    of "setup":
      install_android_sdk(ANDROID_SDK_LOCATION)
    of "verify":
      discard try_verifying_androidsdk(ANDROID_SDK_LOCATION)
    of "buildlib":
      build(ANDROID_SDK_LOCATION, ".generated", args, false)
    of "buildapk":
      build(ANDROID_SDK_LOCATION, ".generated", args, true)
    of "installapk":
      discard
    of "logcat":
      discard
    of "clean":
      discard
    else:
      styled_echo fgRed, "'" & param_str(1) & "' is not a command"
  main()
# oui/deployandroid setup sdk:29 jdk:8
# oui/deployandroid buildlib abi:armeabi nimfile:/home/trey/projects/mplsa/mplsa.nim
