mode = ScriptMode.Verbose

packageName   = "ranges"
version       = "0.0.1"
author        = "Status Research & Development GmbH"
description   = "Exploration of various implementations of memory range types"
license       = "Apache License 2.0"
skipDirs      = @["tests"]

requires "nim >= 0.17.0"

proc configForTests() =
  --hints: off
  --debuginfo
  --path: "."
  --run
  --threads: on

task test, "run CPU tests":
  configForTests()
  setCommand "c", "tests/all.nim"

