proc baseAddr*[T](x: openarray[T]): pointer = cast[pointer](x)

proc shift*(p: pointer, delta: int): pointer {.inline.} =
  cast[pointer](cast[int](p) + delta)

proc distance*(a, b: pointer): int {.inline.} =
  cast[int](b) - cast[int](a)

proc shift*[T](p: ptr T, delta: int): ptr T {.inline.} =
  cast[ptr T](shift(cast[pointer](p), delta * sizeof(T)))

when (NimMajor,NimMinor,NimPatch) >= (0,19,9):
  template makeOpenArray*(p: pointer, T: type, len: int): auto =
    toOpenArray(cast[ptr UncheckedArray[T]](p), 0, len - 1)
else:
  template makeOpenArray*(p: pointer, T: type, len: int): auto =
    # TODO: This is a fallback until we upgrade to 0.19.9
    var s = newSeq[T](len)
    copyMem(addr s[0], p, len * sizeof(T))
    s

