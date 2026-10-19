///|
fn memory_golden_case(
  opcode : String,
  args : Array[Value],
  expected : Value,
  expected_memory : Bytes,
) -> Unit raise {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\n", true,
  )
  let memory = FixedArray::makei(65536, fn(i) {
    if i < 32 {
      ((i * 37 + 129) % 256).to_byte()
    } else {
      b'\x00'
    }
  })
  machine.memory = Some(memory)
  let value = machine.memory_instruction(memory_opcode(opcode).unwrap(), args)
  match (value, expected) {
    (Unit, Unit) => ()
    (Number(a, ak), Number(b, bk)) | (Floating(a, ak), Floating(b, bk)) => {
      assert_eq(a, b)
      assert_eq(ak, bk)
    }
    (Vector(al, ah), Vector(bl, bh)) => {
      assert_eq(al, bl)
      assert_eq(ah, bh)
    }
    _ => fail("memory golden result carrier differs: " + opcode)
  }
  for i in 0..<expected_memory.length() {
    assert_eq(memory[i], expected_memory[i])
  }
}

///|
test "all catalog memory operations match fixed byte goldens" {
  memory_golden_case(
    "i32.load",
    [Number(3UL, "U32")],
    Number(1597642224UL, "I32"),
    b"",
  )
  memory_golden_case(
    "i32.load8_s",
    [Number(3UL, "U32")],
    Number(4294967280UL, "I32"),
    b"",
  )
  memory_golden_case(
    "i32.load8_u",
    [Number(3UL, "U32")],
    Number(240UL, "I32"),
    b"",
  )
  memory_golden_case(
    "i32.load16_s",
    [Number(3UL, "U32")],
    Number(5616UL, "I32"),
    b"",
  )
  memory_golden_case(
    "i32.load16_u",
    [Number(3UL, "U32")],
    Number(5616UL, "I32"),
    b"",
  )
  memory_golden_case(
    "i64.load",
    [Number(3UL, "U32")],
    Number(17568165582417303024UL, "I64"),
    b"",
  )
  memory_golden_case(
    "f32.load",
    [Number(3UL, "U32")],
    Floating(1597642224UL, "F32"),
    b"",
  )
  memory_golden_case(
    "f64.load",
    [Number(3UL, "U32")],
    Floating(17568165582417303024UL, "F64"),
    b"",
  )
  memory_golden_case(
    "i32.store",
    [Number(3UL, "U32"), Number(4275843713UL, "I32")],
    Unit,
    b"\x81\xa6\xcb\x81\x32\xdc\xfe\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "i32.store8",
    [Number(3UL, "U32"), Number(4275843713UL, "I32")],
    Unit,
    b"\x81\xa6\xcb\x81\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "i32.store16",
    [Number(3UL, "U32"), Number(4275843713UL, "I32")],
    Unit,
    b"\x81\xa6\xcb\x81\x32\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "i64.store",
    [Number(3UL, "U32"), Number(18364758544493064833UL, "I64")],
    Unit,
    b"\x81\xa6\xcb\x81\x32\x54\x76\x98\xba\xdc\xfe\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "f32.store",
    [Number(3UL, "U32"), Floating(2147483648UL, "F32")],
    Unit,
    b"\x81\xa6\xcb\x00\x00\x00\x80\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "f64.store",
    [Number(3UL, "U32"), Floating(9221120237041090561UL, "F64")],
    Unit,
    b"\x81\xa6\xcb\x01\x00\x00\x00\x00\x00\xf8\x7f\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load",
    [Number(3UL, "U32")],
    Vector(17568165582417303024UL, 2015028422230818072UL),
    b"",
  )
  memory_golden_case(
    "v128.store",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_splat",
    [Number(3UL, "U32")],
    Vector(17361641481138401520UL, 17361641481138401520UL),
    b"",
  )
  memory_golden_case(
    "v128.load8_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307440UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x01\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752368129UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x02\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695767839233UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x03\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437699711730177UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x04\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 4",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578438705069621761UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 4",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x05\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 5",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578694981473206785UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 5",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x06\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 6",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(644021365325890049UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 6",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x07\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 7",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(17295799512551588353UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 7",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x08\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 8",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159078456920816UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 8",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x09\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 9",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159078456979465UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 9",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0a\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 10",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159078471928329UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 10",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0b\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 11",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159082282125833UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 11",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0c\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 12",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157160053414496777UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 12",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0d\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 13",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157407568084797961UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 13",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0e\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 14",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1220490948216818185UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 14",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0f\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8_lane 15",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 17298060142952778249UL),
    b"",
  )
  memory_golden_case(
    "v128.store8_lane 15",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x10\x15\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_splat",
    [Number(3UL, "U32")],
    Vector(1580787590111434224UL, 1580787590111434224UL),
    b"",
  )
  memory_golden_case(
    "v128.load16_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752312304UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x01\x02\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437696053051905UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x03\x04\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578455197744038401UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x05\x06\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(1580770087818953217UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x07\x08\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 4",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159078456923632UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 4",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x09\x0a\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 5",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159078622923273UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 5",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0b\x0c\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 6",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157167749995891209UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 6",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0d\x0e\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load16_lane 7",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1580778918406457865UL),
    b"",
  )
  memory_golden_case(
    "v128.store16_lane 7",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0f\x10\x3a\x5f\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load32_splat",
    [Number(3UL, "U32")],
    Vector(6861821104386348528UL, 6861821104386348528UL),
    b"",
  )
  memory_golden_case(
    "v128.load32_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437697282643440UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store32_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x01\x02\x03\x04\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load32_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(6861821102856012289UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store32_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x05\x06\x07\x08\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load32_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 1157159079852512752UL),
    b"",
  )
  memory_golden_case(
    "v128.store32_lane 2",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x09\x0a\x0b\x0c\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load32_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 6861821102990756361UL),
    b"",
  )
  memory_golden_case(
    "v128.store32_lane 3",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x0d\x0e\x0f\x10\x84\xa9\xce\xf3\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load64_splat",
    [Number(3UL, "U32")],
    Vector(17568165582417303024UL, 17568165582417303024UL),
    b"",
  )
  memory_golden_case(
    "v128.load64_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(17568165582417303024UL, 1157159078456920585UL),
    b"",
  )
  memory_golden_case(
    "v128.store64_lane 0",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x01\x02\x03\x04\x05\x06\x07\x08\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load64_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Vector(578437695752307201UL, 17568165582417303024UL),
    b"",
  )
  memory_golden_case(
    "v128.store64_lane 1",
    [Number(3UL, "U32"), Vector(578437695752307201UL, 1157159078456920585UL)],
    Unit,
    b"\x81\xa6\xcb\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x18\x3d\x62\x87\xac\xd1\xf6\x1b\x40\x65\x8a\xaf\xd4\xf9\x1e\x43\x68\x8d\xb2\xd7\xfc",
  )
  memory_golden_case(
    "v128.load8x8_s",
    [Number(3UL, "U32")],
    Vector(26740371897057264UL, 18443366163529990020UL),
    b"",
  )
  memory_golden_case(
    "v128.load8x8_u",
    [Number(3UL, "U32")],
    Vector(26740371896991984UL, 68399304115028100UL),
    b"",
  )
  memory_golden_case(
    "v128.load16x4_s",
    [Number(3UL, "U32")],
    Vector(104702712747504UL, 18446730669116598660UL),
    b"",
  )
  memory_golden_case(
    "v128.load16x4_u",
    [Number(3UL, "U32")],
    Vector(104702712747504UL, 268066088855940UL),
    b"",
  )
  memory_golden_case(
    "v128.load32x2_s",
    [Number(3UL, "U32")],
    Vector(1597642224UL, 18446744073504991620UL),
    b"",
  )
  memory_golden_case(
    "v128.load32x2_u",
    [Number(3UL, "U32")],
    Vector(1597642224UL, 4090407300UL),
    b"",
  )
  memory_golden_case(
    "v128.load32_zero",
    [Number(3UL, "U32")],
    Vector(1597642224UL, 0UL),
    b"",
  )
  memory_golden_case(
    "v128.load64_zero",
    [Number(3UL, "U32")],
    Vector(17568165582417303024UL, 0UL),
    b"",
  )
}
