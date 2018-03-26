import
  unittest,
  ../ranges/typedranges

suite "Typed ranges":
  test "basic stuff":
    var r = newRange[int](5)
    r[0] = 1
    r[1 .. ^1] = [2, 3, 4, 5]

    check $r == "R[1, 2, 3, 4, 5]"

    var s = newSeq[int]()
    for a in r: s.add(a)
    check s == @[1, 2, 3, 4, 5]
