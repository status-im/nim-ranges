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

  test "subrange":
    var a = newRange[int](5)
    let b = toRange(@[1, 2, 3])
    a[1 .. 3] = b
    check a.toSeq == @[0, 1, 2, 3, 0]

  test "equality operator":
    var x = toRange(@[0, 1, 2, 3, 4, 5])
    var y = x[1 .. ^2]
    var z = toRange(@[1, 2, 3, 4])
    check y == z
    check x != z

  test "concat operation":
    var a = toRange(@[1,2,3])
    var b = toRange(@[4,5,6])
    var c = toRange(@[7,8,9])
    var d = @[1,2,3,4,5,6,7,8,9]
    var e = @[1,2,3,4,5,6]
    var f = @[4,5,6,7,8,9]
    var x = concat(a, b, c)
    var y = a & b
    check x == d
    check y == e
    var z = concat(b, @[7,8,9])
    check z == f

    let u = toRange(newSeq[int](0))
    let v = toRange(@[3])
    check concat(u, v) == @[3]
    check (v & u) == @[3]

  test "complex types concat operation":
    type
      Jaeger = object
        name: string
        weight: int

    var A = Jaeger(name: "Gipsy Avenger", weight: 2004)
    var B = Jaeger(name: "Striker Eureka", weight: 1850)
    var C = Jaeger(name: "Saber Athena", weight: 1628)
    var D = Jaeger(name: "Cherno Alpha", weight: 2412)

    var k = toRange(@[A, B])
    var m = toRange(@[C, D])
    var n = concat(k, m)
    check n == @[A, B, C ,D]
    check n != @[A, B, C ,C]

  test "shallowness":
    var s = @[1, 2, 3]
    var r = s.toRange()
    var r2 = r
    s[0] = 5
    # check(r[0] == 5) # XXX: Uncomment once nim bug #8044 is fixed
    r[1] = 10
    check(r2[1] == 10)
