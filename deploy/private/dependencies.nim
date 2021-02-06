# Copyright © 2020 Trey Cutter <treycutter@protonmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import tables, osproc, os, strutils

type 
  DepsList* = OrderedTable[string, tuple[clone: string, compile: seq[string]]]
  DepsArgs* = tuple[prefix, sys_root, cc, cxx, ar, ld, ass, strip, ranlib, cross_compile: string]

const 
  builddir = "buildoui"
  crosscompileout = "cross_compile.out.txt"
  crosscompilein = """
[properties]
needs_exe_wrapper = true
sys_root = '$1'
build_rpath = '/home/trey/Projects/oui/deploy/.deploy/usr/lib'
install_rpath = '/home/trey/Projects/oui/deploy/.deploy/usr/lib'
link_args = '-L/home/trey/Projects/oui/deploy/.deploy/usr/lib'
include_directories = '/home/trey/Projects/oui/deploy/.deploy/usr/include'
[binaries]
c = '$2'
cpp = '$3'
ar = '$4'
as = '$5'
ld = '$6'
strip = '$7'
ranlib = '$8'
pkgconfig = '/usr/bin/pkg-config'
"""

var
  meson = "meson " & builddir & " -Dprefix=$1 --cross-file $3"
  ninja = "ninja install -C " & builddir
  configure = "./configure --prefix=$1 --host=$2"
  autogen = "./autogen.sh --prefix=$1 --host=$2"
  deps = {

    "libpng": (clone: "git clone https://github.com/glennrp/libpng",
              compile: @[configure, "make", "make install"]),
    "cairo": (clone: "git clone https://gitlab.freedesktop.org/cairo/cairo.git",
              compile: @[meson & " -Dgl-backend=glesv3", ninja]),
    "pango-1.45.1": (clone: "wget -O - https://gitlab.gnome.org/GNOME/pango/-/archive/1.45.1/pango-1.45.1.tar.gz | tar xz",
              compile: @[meson & " -Dfreetype=disabled && meson configure --clearcache", ninja]),
  }.to_ordered_table()

proc setup_cross_compilation*(dir: string, args: DepsArgs) =
  put_env("CC", args.cc)
  put_env("CXX", args.cxx)
  put_env("LD", args.ld)
  put_env("AS", args.ass)
  put_env("STRIP", args.strip)
  put_env("RANLIB", args.ranlib)
  put_env("PKG_CONFIG_PATH", "/home/trey/Projects/oui/.deploy/usr/lib/pkgconfig")
  put_env("LD_LIBRARY_PATH", "/home/trey/Projects/oui/.deploy/usr/lib")
  put_env("PKG_CONFIG_LIBDIR", "/home/trey/Projects/oui/.deploy/usr/lib/pkgconfig")
  put_env("PKG_CONFIG_SYSROOT_DIR", "/home/trey/Projects/oui/.deploy/")
  var cross_compile_in = crosscompilein % [args.sys_root, args.cc, args.cxx, args.ar, args.ass, args.ld, args.strip, args.ranlib]
  write_file(dir & crosscompileout, args.cross_compile % [cross_compile_in])

proc exec_shell*(command, input: string = ""): bool =
  echo "\e[36m> " & command & "\x1B[0m"
  let (output, code) = exec_cmd_ex(command, {poStdErrToStdOut, poUsePath}, nil, "", input)
  if code == 0:
    echo output
    result = true
  else:
    for line in output.split_lines():
      echo "\e[36m" & command & " | " & "\x1B[0m" & line
    result = false

proc compile_dep(dir: string, commands: var seq[string]): bool =
  for command in commands:
    var 
      c = command % [dir & "usr", "x86_64-linux-android", dir & crosscompileout]
    if exec_shell(c) == false:
      return false
  true

proc clean_deps*(dir, specific: string = "") =
  for dep in deps.keys:
    if specific.len > 0:
      if specific != dep:
        continue
    discard exec_shell("rm -rf " & dir & "src/" & dep)
    discard exec_shell("rm -rf " & dir & "var/" & dep)
    if specific.len > 0:
      break

proc setup_deps*(dir, specific: string = "") =
  echo "setting up the dependencies"
  set_current_dir(dir)
  if dir_exists("src") == false:
    discard exec_shell("mkdir src")

  for dep in deps.keys:
    if specific.len > 0:
      if specific != dep:
        continue

    var src = dir & "src/"
    echo "cloning " & dep
    var cloned = false
    if dir_exists(src & dep):
      echo dep & " is using its existing src"
      cloned = true
    else:
      set_current_dir(src)
      if exec_shell(deps[dep].clone):
        echo "cloned " & dep
        cloned = true
      else:
        echo "failed to clone " & dep
    if cloned:
      echo "building " & dep
      set_current_dir(src & dep)
      if compile_dep(dir, deps[dep].compile):
        echo "built " & dep
        continue
      echo "failed to build " & dep
      continue
    if specific.len > 0:
      break
  echo "the dependencies are done being setup"

