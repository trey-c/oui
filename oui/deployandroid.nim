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

var ANDROID_DL_URLS = (%* {
  "cmdlinetools-win": "https://dl.google.com/android/repository/commandlinetools-win-7302050_latest.zip",
  "cmdlinetools-linux": "https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip",
  "jdk-windows": "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-windows-x64.zip",
  "jdk-linux": "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u262-b10/openlogic-openjdk-8u262-b10-linux-x64.tar.gz"
})

var ANDROID_PATHS = (%* {
  "sdk": ANDROID_SDK_LOCATION & "/sdk",
  "jdk": ANDROID_SDK_LOCATION & "/jdk",
  "cmdline-tools": ANDROID_SDK_LOCATION & "/cmdline-tools"
})

var ANDROID_TARGETS = (%* {
  "armeabi": "arm-linux-androideabi"
})

proc exec_terminal(cmd: string): int =
  oui_log "> " & cmd
  result = execShellCmd(cmd)

proc curl_cmdline_tools_and_jdk(loc: string) =
  var 
    sdk = normalized_path(ANDROID_PATHS["sdk"].get_str())
    jdk = normalized_path(ANDROID_PATHS["jdk"].get_str())
  when defined windows:
    var
      cmdlinetools = ANDROID_DL_URLS["cmdlinetools-win"].get_str()
      toolnames = cmdlinetools.split('/')
      jdkwindows = ANDROID_DL_URLS["jdk-windows"].get_str()
      jdknames = jdkwindows.split('/')
      commands = @[
        "curl -O " & cmdlinetools,
        """Powershell.exe -Command Expand-Archive "$1" "$2"""" % 
        [toolnames[toolnames.high], ANDROID_SDK_LOCATION],
        "curl -O " & jdkwindows,
        """Powershell.exe -Command Expand-Archive "$1" "$2"""" %
        [jdknames[jdknames.high], jdk]
      ]
  when defined linux:
    var
      cmdlinetools = ANDROID_DL_URLS["cmdlinetools-linux"].get_str()
      toolnames = cmdlinetools.split('/')
      jdklinux = ANDROID_DL_URLS["jdk-linux"].get_str()
      jdknames = jdklinux.split('/')
      commands = @[
        "curl -O " & cmdlinetools,
        "unzip $1 -d $2 && rm $1" % [toolnames[toolnames.high], ANDROID_PATHS["cmdline-tools"].get_str()],
        "curl -O " & jdklinux,
        """tar -xvzf $1 --one-top-level=$2 --strip-components 1 && rm $1""" % 
        [jdknames[jdknames.high], jdk]
      ]
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
    remove_dir(location)
    oui_warning "deleting '" & location & "' and wil try again"

  installing_ndk = true
  create_dir(location)
  set_current_dir(location)
  {.cast(gcsafe).}:
    curl_cmdline_tools_and_jdk(location)
    when defined windows:
      put_env("JAVA_HOME", normalized_path(ANDROID_PATHS["jdk"].get_str() & "/openlogic-openjdk-8u262-b10-win-64"))
      var managerpath = normalized_path(ANDROID_PATHS["cmdline-tools"].get_str() & "/bin/sdkmanager.bat")
    when defined linux:
      put_env("JAVA_HOME", normalized_path(ANDROID_PATHS["jdk"].get_str()))
      var managerpath = normalized_path(ANDROID_PATHS["cmdline-tools"].get_str() & "/tools/bin/sdkmanager")
    var sdkmanager = managerpath & " --sdk_root=" & normalized_path(ANDROID_PATHS["sdk"].get_str()) & " --install \"platform-tools\" \"platforms;android-29\" \"build-tools;29.0.2\" \"ndk-bundle\""

  discard exec_terminal(sdkmanager)
  oui_log "done installing ndk"
  installing_ndk = false

proc buildlib(toolchain, target, file, output: string): int =
  let
    clangpath = "--arm.android.clang.path=\"" & normalized_path(toolchain &
        "/bin\"")
    clangldexe = "--arm.android.clang.exe=\"clang\" --arm.android.clang.linkerexe=\"ld\" " & clangpath
    passc = "--passC=\"--target=arm-linux-androideabi29" & "\""
    passl = "--passL=\"-L" & normalized_path(toolchain & "/lib/gcc/" &
        target & "/4.9.x") & " -L" & normalized_path(toolchain &
                "/sysroot/usr/lib/arm-linux-androideabi/29") & " -L" &
                    normalized_path(toolchain &
                        "/sysroot/usr/lib/arm-linux-androideabi") & " -lgcc -llog -lm -lc -lEGL -lGLESv2 -landroid\""
    nimcmd = "nim c " & clangldexe & " " & passc & " " & passl & " --app:lib --cpu:arm --os:android -d:androidNDK -d:nvgGLES2 --noMain:on --cc:clang -o:" & normalized_path(output) & " " & file
  oui_log "> " & nimcmd
  result = exec_terminal(nimcmd)

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
  var back = getCurrentDir()
  set_current_dir(output)
  for folder in @["net", "net/ouiapp", "res", "res/values", "assets", "gen", "obj"]:
    discard exists_or_create_dir(normalized_path(folder))
  write_file("AndroidManifest.xml", ANDROID_MANIFEST_XML)
  write_file(normalized_path("res/values/strings.xml"), RES_VALUE_STRINGS_XML)
  write_file(normalized_path("net/ouiapp/OuiActivity.java"),
    NET_OUIAPP_OUI_ACTIVITY_JAVA)
  copy_dir(get_home_dir() & ".oui/fonts", "assets/font")
  set_current_dir(back)

proc zip_and_sign_apk(jdk, platform, build_tools,
  androidjar, keystore_loc, output, assets: string) =
  copy_dir(assets, output & "/assets")

  var back = getCurrentDir()
  set_current_dir(output)
  let
    zip_apk_cmds = @[
      normalized_path(build_tools & "/aapt2$1") &
          " compile --dir res -o resources.zip",
      normalized_path(build_tools & "/aapt2$1") &
          " link -o output.apk resources.zip -I " & androidjar &
      "--manifest AndroidManifest.xml -A assets -v",
      "zip output.apk " & normalized_path("./lib/armeabi/libouiapp.so"),
      normalized_path(jdk & "/bin/javac$1") & " -bootclasspath " & jdk & normalized_path("/jre/lib/rt.jar") &
        " -classpath " & androidjar & " -d obj -sourcepath java:gen " &
      normalized_path("net/ouiapp/OuiActivity.java") &
                " -source 1.7 -target 1.7",
      normalized_path(build_tools & "/dx$2") &
          " --dex --output=classes.dex obj",
      normalized_path(build_tools & "/aapt$1") & " a output.apk classes.dex",
      normalized_path(build_tools & "/zipalign$1") & " 4 output.apk output-aligned.apk"
    ]
  for cmd in zip_apk_cmds:
    when defined windows:
      if exec_terminal(cmd % [".exe", ".bat"]) != 0: break
    when defined linux:
      if exec_terminal(cmd % ["", ""]) != 0: break
  if not file_exists(keystore_loc):
    if exec_terminal(normalized_path(jdk & "/bin/keytool") & " -genkey -v -keystore " & keystore_loc &
        " -alias androiddebugkey -storepass android -keypass android -keyalg RSA -validity 14000") != 1:
      return
  discard exec_terminal( normalized_path(build_tools & "/apksigner") &
      " sign --ks " & keystore_loc & " --ks-pass pass:android --out final-output.apk output-aligned.apk")
  set_current_dir(back)

proc buildapk(jdk, build_tools, platform, ndk, output, assets: string) =
  put_env("JAVA_HOME", normalized_path(jdk))
  put_env("PATH", get_env("PATH") & ":" & normalized_path(jdk & "/bin"))
  let
    androidjar = normalized_path(platform & "/android.jar ")
    keystore_loc = normalized_path(get_home_dir() & ".android/debug.keystore")
  zip_and_sign_apk(jdk, platform, build_tools, androidjar, keystore_loc, output, assets)
  remove_dir("gen")
  remove_dir("obj")
  remove_file("output-aligned.apk")
  remove_file("output.apk")

proc build(sdk, output: string, args: JsonNode, apk: bool) =
  generate_output_structure(output)
  when defined windows:
    let host = "windows-x86_64"
    let jdk = ANDROID_PATHS["jdk"].get_str() & "/openlogic-openjdk-8u262-b10-win-64"
  when defined linux:
    let host = "linux-x86_64"
    let jdk = ANDROID_PATHS["jdk"].get_str()
  let
    ndk = sdk & "/sdk/ndk-bundle"
    platform =  ANDROID_PATHS["sdk"].get_str() & "/platforms/android-29"
    toolchain = ndk & "/toolchains/llvm/prebuilt/" & host
    build_tools = sdk & "/sdk/build-tools/29.0.2"
    target = ANDROID_TARGETS[args["abi"].get_str()].get_str()
    nimfile = args["nimfile"].get_str()
    assets = args["assets"].get_str()
  discard buildlib(toolchain, target, nimfile, output & "/lib/armeabi/libouiapp.so")
  if apk:
    buildapk(jdk, build_tools, platform, ndk,
      output, assets)

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
