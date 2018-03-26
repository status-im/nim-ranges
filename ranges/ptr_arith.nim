proc baseAddr*[T](x: openarray[T]): pointer = cast[pointer](x)

proc shift*(p: pointer, delta: int): pointer {.inline.} =
  cast[pointer](cast[int](p) + delta)

proc shift*[T](p: ptr T, delta: int): ptr T {.inline.} =
  cast[ptr T](shift(cast[pointer](p), delta * sizeof(T)))
