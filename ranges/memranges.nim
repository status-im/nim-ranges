import
  ptr_arith

type
  MemRange* = object
    start: pointer
    size: csize

template len*(mr: MemRange): int = mr.size
template `[]`*(mr: MemRange, idx: int): byte = (cast[ptr byte](shift(mr.start, idx)))[]
proc baseAddr*(mr: MemRange): pointer = mr.start

proc makeMemRange*(start: pointer, size: csize): MemRange =
  result.start = start
  result.size = size

proc toMemRange*(x: string): MemRange =
  result.start = x.cstring.pointer
  result.size = x.len

proc toMemRange*[T](x: openarray[T]): MemRange =
  result.start = cast[pointer](x)
  result.size = x.len * T.sizeof

