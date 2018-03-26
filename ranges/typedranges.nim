import ./ptr_arith

const rangesGCHoldEnabled = not defined(rangesDisableGCHold)
const unsafeAPIEnabled = defined(rangesEnableUnsafeAPI)

type
  # A view into immutable array
  Range* {.shallow.} [T] = object
    when rangesGCHoldEnabled:
      gcHold: seq[T]
    start: ptr T
    mLen: int32

  # A view into mutable array
  MutRange*[T] = distinct Range[T]

proc toImmutableRange[T](a: seq[T]): Range[T] =
  if a.len != 0:
    when rangesGCHoldEnabled:
      result.gcHold = a
    result.start = unsafeAddr a[0]
    result.mLen = int32(a.len)

when unsafeAPIEnabled:
  proc toImmutableRangeNoGCHold[T](a: openarray[T]): Range[T] =
    if a.len != 0:
      result.start = unsafeAddr a[0]
      result.mLen = int32(a.len)

  proc toImmutableRange[T](a: openarray[T]): Range[T] {.inline.} =
    toImmutableRangeNoGCHold(a)

proc toRange*[T](a: var seq[T]): MutRange[T] {.inline.} =
  MutRange[T](toImmutableRange(a))

when unsafeAPIEnabled:
  proc toRange*[T](a: var openarray[T]): MutRange[T] {.inline.} =
    MutRange[T](toImmutableRange(a))

  template initStackRange*[T](sz: static[int]): MutRange[T] =
    var data: array[sz, T]
    data.toRange()

  proc toRange*[T](a: openarray[T]): Range[T] {.inline.} = toImmutableRange(a)

proc newRange*[T](sz: int): MutRange[T] {.inline.} =
  MutRange[T](toImmutableRange(newSeq[T](sz)))

proc toRange*[T](a: seq[T]): Range[T] {.inline.} = toImmutableRange(a)

converter toImmutableRange*[T](a: MutRange[T]): Range[T] {.inline.} = Range[T](a)

proc len*(r: Range): int {.inline.} = int(r.mLen)

proc high*(r: Range): int {.inline.} = r.len - 1
proc low*(r: Range): int {.inline.} = 0

proc elemAt[T](r: MutRange[T], idx: int): var T {.inline.} =
  assert(idx < r.len)
  Range[T](r).start.shift(idx)[]

proc `[]=`*[T](r: MutRange[T], idx: int, v: T) {.inline.} = r.elemAt(idx) = v
proc `[]`*[T](r: MutRange[T], i: int): var T = r.elemAt(i)

proc `[]`*[T](r: Range[T], idx: int): T {.inline.} =
  assert(idx < r.len)
  r.start.shift(idx)[]

iterator ptrs[T](r: Range[T]): (int, ptr T) =
  var p = r.start
  var i = 0
  let e = r.len
  while i != e:
    yield (i, p)
    p = p.shift(1)
    inc i

iterator items*[T](r: Range[T]): T =
  for _, v in ptrs(r): yield v[]

iterator pairs*[T](r: Range[T]): (int, T) =
  for i, v in ptrs(r): yield (i, v[])

iterator mitems*[T](r: MutRange[T]): var T =
  for _, v in ptrs(r): yield v[]

iterator mpairs*[T](r: MutRange[T]): (int, var T) =
  for i, v in ptrs(r): yield (i, v[])

proc toSeq*[T](r: Range[T]): seq[T] =
  result = newSeqOfCap[T](r.len)
  for i in r: result.add(i)

proc `$`*(r: Range): string =
  result = "R["
  for i, v in r:
    if i != 0:
      result &= ", "
    result &= $v
  result &= "]"

proc sliceNormalized[T](r: Range[T], ibegin, iend: int): Range[T] =
  assert(ibegin >= 0 and ibegin < r.len and iend >= ibegin and iend < r.len)
  when rangesGCHoldEnabled:
    result.gcHold = r.gcHold
  result.start = r.start.shift(ibegin)
  result.mLen = int32(iend - ibegin + 1)

proc slice*[T](r: Range[T], ibegin = 0, iend = -1): Range[T] =
  let e = if iend < 0: r.len + iend
          else: iend
  sliceNormalized(r, ibegin, e)

proc slice*[T](r: MutRange[T], ibegin = 0, iend = -1): MutRange[T] {.inline.} =
  MutRange[T](Range[T](r).slice(ibegin, iend))

template `^^`(s, i: untyped): untyped =
  (when i is BackwardsIndex: s.len - int(i) else: int(i))

proc `[]`*[T, U, V](r: Range[T], s: HSlice[U, V]): Range[T] {.inline.} =
  sliceNormalized(r, r ^^ s.a, r ^^ s.b)

proc `[]`*[T, U, V](r: MutRange[T], s: HSlice[U, V]): MutRange[T] {.inline.} =
  MutRange[T](sliceNormalized(r, r ^^ s.a, r ^^ s.b))

proc `[]=`*[T, U, V](r: MutRange[T], s: HSlice[U, V], v: openarray[T]) =
  let a = r ^^ s.a
  let b = r ^^ s.b
  let L = b - a + 1
  if L == v.len:
    for i in 0..<L: r[i + a] = v[i]
  else:
    raise newException(RangeError, "different lengths for slice assignment")

proc `[]=`*[T, U, V](r: MutRange[T], s: HSlice[U, V], v: Range[T]) {.inline.} =
  r[s] = toOpenArray(v)

proc baseAddr*[T](r: Range[T]): ptr T {.inline.} = r.start

template toOpenArray*[T](r: Range[T]): auto =
  toOpenArray(cast[ptr array[10000000, T]](r.start)[], 0, r.high)
