import
  ptr_arith

type
  MemRange* = object
    start: pointer
    size: csize

template len*(mr: MemRange): int = mr.size
template `[]`*(mr: MemRange, idx: int): byte = (cast[ptr byte](shift(mr.start, idx)))[]
proc baseAddr*(mr: MemRange): pointer = mr.start

when false:
  # XXX: Alternative definition that crashes the compiler. Investigate
  type
    MemRange* = distinct (pointer, csize)

  template len*(mr: MemRange): int = mr[1]
  template `[]`*(mr: MemRange, idx: int): byte = (cast[ptr byte](shift(mr[0], idx)))[]
  proc baseAddr*(mr: MemRange): pointer = mr[0]

proc makeMemRange*(start: pointer, size: csize): MemRange =
  result.start = start
  result.size = size

