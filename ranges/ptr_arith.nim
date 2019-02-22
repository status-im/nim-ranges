proc baseAddr*[T](x: openarray[T]): pointer = cast[pointer](x)

proc shift*(p: pointer, delta: int): pointer {.inline.} =
  cast[pointer](cast[int](p) + delta)

proc distance*(a, b: pointer): int {.inline.} =
  cast[int](b) - cast[int](a)

proc shift*[T](p: ptr T, delta: int): ptr T {.inline.} =
  cast[ptr T](shift(cast[pointer](p), delta * sizeof(T)))

template makeOpenArray*(p: pointer, T: type, len: int): auto =
  cast[ptr UncheckedArray[T]](p).toOpenArray(0, len - 1)

