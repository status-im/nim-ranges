import
  unittest, math,
  ../ranges/[stackarrays, ptr_arith]

suite "Stack arrays":
  test "Basic operations work as expected":
    var arr = allocStackArray(int, 10)
    check:
      type(arr[0]) is int
      arr.len == 10

    # all items should be initially zero
    for i in arr: check i == 0
    for i in 0 .. arr.high: check arr[i] == 0

    arr[0] = 3
    arr[5] = 10
    arr[9] = 6

    check:
      sum(arr.toOpenArray) == 19
      arr[5] == 10
      arr[^1] == 6
      cast[ptr int](shift(addr arr[0], 5))[] == 10

  test "Allocating with a negative size throws a RangeError":
    expect RangeError:
      var arr = allocStackArray(string, -1)

  test "The array access is bounds-checked":
    var arr = allocStackArray(string, 3)
    arr[2] = "test"
    check arr[2] == "test"
    expect RangeError:
      arr[3] = "another test"

  test "proof of stack allocation":
    proc fun() =
      # NOTE: has to be inside a proc otherwise x1 not allocated on stack.
      var x1 = 0
      var arr = allocStackArray(int, 3)
      var x2 = 0
      let p_addr = cast[int](addr arr)
      let p_x1 = cast[int](addr x1)
      let p_x2 = cast[int](addr x2)
      check:
        # stack can go either up or down
        p_addr > min(p_x1, p_x2) and p_addr < max(p_x1, p_x2)
    fun()

  test "skip initialization":
    proc fun():auto =
      let n = 3
      var arr = allocStackArray(int, n, initialized = false)
      check arr.len == n
      # should contain random garbage from stack
      return $(arr.toOpenArray)
    let a0=fun()
    let a1=fun()
    check a0 == a1
