proc alloca(n: int): pointer {.importc, header: "<alloca.h>".}

type
  StackArray*[T] = ptr object
    bufferLen: int
    buffer: UncheckedArray[T]

template `[]`*(a: StackArray, i: int): auto =
  if i < 0 or i >= a.len: raise newException(RangeError, "index out of range")
  a.buffer[i]

proc `[]=`*(a: StackArray, i: int, val: a.T) =
  if i < 0 or i >= a.len: raise newException(RangeError, "index out of range")
  a.buffer[i] = val

proc len*(a: StackArray): int {.inline.} =
  a.bufferLen

template high*(a: StackArray): int =
  a.bufferLen - 1

template low*(a: StackArray): int =
  0

iterator items*(a: StackArray): a.T =
  for i in 0 .. a.high:
    yield a.buffer[i]

iterator mitems*(a: var StackArray): var a.T =
  for i in 0 .. a.high:
    yield a.buffer[i]

iterator pairs*(a: StackArray): a.T =
  for i in 0 .. a.high:
    yield (i, a.buffer[i])

iterator mpairs*(a: var StackArray): (int, var a.T) =
  for i in 0 .. a.high:
    yield (i, a.buffer[i])

template allocStackArray*(T: typedesc, size: int): auto =
  if size < 0: raise newException(RangeError, "allocation with a negative size")
  # XXX: is it possible to perform a stack size check before
  # calling `alloca`? Nim has a stackBottom pointer in the
  # system module.
  var
    bufferSize = size * sizeof(T)
    totalSize = sizeof(int) + bufferSize
    arr = cast[StackArray[T]](alloca(totalSize))
  zeroMem(addr arr.buffer[0], bufferSize)
  arr.bufferLen = size
  arr

template toOpenArray*(a: StackArray): auto =
  toOpenArray(a.buffer, 0, a.high)

