import tables, os, strutils, terminal, osproc, macros

template testaid*(inner: untyped): untyped =
  when is_main_module and defined(testaid):
    import unittest
    let fpath {.compiletime.} = instantiationInfo()
    suite (fpath.filename):
      `inner`

proc grab_sources(matches: string): TableRef[string, int] =
  result = new_table[string, int]()
  for file in walk_dir_rec(get_current_dir()):
    if file.contains(".nim"):
      if file.contains("/private/") or file.contains(".nimble"):
        continue
      if file.contains(matches):
        result[file] = 1

proc print_test_results(sources: TableRef[string, int], successful,
    failed: var int) =
  var
    length = sources.len
    i = 1
  styled_echo fgWhite, "\ntestaid: has finished running " & $length & " test(s)"
  for source, code in sources.mpairs:
    if code == 0:
      styled_echo fgWhite, $i & ". " & source, resetStyle, fgGreen, " successful"
    else:
      styled_echo fgWhite, $i & ". " & source, resetStyle, fgRed, " failed"
    i.inc
  styled_echo fgGreen, "\n" & $successful & "/" & $length &
      " test(s) were successful\n", fgRed, $failed & "/" & $length & " test(s) failed"

proc run_tests(sources: TableRef[string, int], extraflags: string, successful,
    failed: var int) =
  for source, code in sources.mpairs:
    let cmd = "nim c -d:testaid --hints:off --warnings:off " & extraflags &
        " -r " & source
    var exitcode = exec_shell_cmd(cmd)
    if exitcode == 0:
      successful.inc
      code = 0
    else:
      failed.inc
      code = exitcode

when is_main_module:
  proc main() =
    if param_count() == 0:
      styled_echo fgRed, "\ntestaid: <matches> \"specific test category\" <extra-compiler-flags>"
      return
    var
      matches = param_str(1)
      sources = grab_sources(matches)
    if sources.len == 0:
      styled_echo fgRed, "testaid: no nim files matching '" &
        matches & "' found"
      return
    var
      extraflags = ""
      failed = 0
      successful = 0
    if param_count() >= 2:
      for i in 2..param_count():
        extraflags.add(param_str(i))
    sources.run_tests(extraflags, successful, failed)
    sources.print_test_results(successful, failed)
  main()
