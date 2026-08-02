(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (struct (field (mut i32))))
  (type (;2;) (struct (field (mut f32))))
  (type (;3;) (struct (field (mut f64))))
  (type (;4;) (struct (field (mut v128))))
  (type (;5;) (struct (field (mut eqref))))
  (type (;6;) (sub (struct (field funcref))))
  (type (;7;) (sub final 6 (struct (field funcref) (field eqref))))
  (type (;8;) (sub final 6 (struct (field funcref) (field eqref))))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32)))
  (type (;12;) (func (result eqref)))
  (type (;13;) (func (result f32)))
  (type (;14;) (func (result f64)))
  (type (;15;) (func (param eqref) (result i32)))
  (type (;16;) (func (param eqref i32) (result i32)))
  (type (;17;) (func (param eqref i32)))
  (type (;18;) (func (param eqref) (result eqref)))
  (type (;19;) (func (param eqref) (result f32)))
  (type (;20;) (func (param eqref) (result f64)))
  (type (;21;) (func (param i32) (result eqref)))
  (type (;22;) (func))
  (type (;23;) (func))
  (type (;24;) (array (mut v128)))
  (type (;25;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;26;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;27;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;28;) (struct (field (mut (ref 24))) (field (mut i32)) (field (mut i32))))
  (type (;29;) (struct (field (mut (ref 24))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 3))
  (export "__dew_init" (func 15))
  (elem (;0;) declare func 0 1 4 14)
  (func (;0;) (type 10) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 10) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.sub
  )
  (func (;2;) (type 21) (param i32) (result eqref)
    (local eqref)
    local.get 0
    struct.new 1
    local.set 1
    ref.func 4
    local.get 1
    struct.new 7
  )
  (func (;3;) (type 22)
    (local i32 i32 i32 eqref i32 eqref eqref eqref eqref eqref eqref i64 eqref eqref eqref eqref eqref eqref eqref)
    i32.const 40
    local.set 0
    local.get 0
    i32.const 2
    i32.add
    local.set 0
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x61636e75 0x72757470 0x6d206465 0x62617475
    v128.const i32x4 0x6c20656c 0x6c61636f 0x00000000 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 24
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 42
    i32.eq
    if ;; label = @1
      i32.const 43
      local.set 0
    else
      i32.const 0
      local.set 0
    end
    local.get 0
    i32.const 1
    i32.sub
    local.set 0
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x6174756d 0x20656c62 0x61636f6c 0x6e69206c
    v128.const i32x4 0x73656e20 0x20646574 0x746e6f63 0x206c6f72
    v128.const i32x4 0x776f6c66 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 36
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 1
    i32.const 1
    if ;; label = @1
      i32.const 2
      local.set 2
      i32.const 3
      local.set 2
      local.get 2
      i32.const 3
      i32.eq
      v128.const i32x4 0x656e6e69 0x756d2072 0x6c626174 0x68732065
      v128.const i32x4 0x776f6461 0x00000000 0x00000000 0x00000000
      array.new_fixed 24 2
      i32.const 0
      i32.const 20
      struct.new 25
      drop
      i32.eqz
      if ;; label = @2
        unreachable
      end
    else
    end
    local.get 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x6574756f 0x756d2072 0x6c626174 0x68732065
    v128.const i32x4 0x776f6461 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 20
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    struct.new 1
    local.set 3
    i32.const 0
    local.set 4
    local.get 3
    call 5
    local.set 4
    local.get 4
    i32.const 42
    i32.eq
    v128.const i32x4 0x69737361 0x656d6e67 0x7320746e 0x65726f74
    v128.const i32x4 0x69722073 0x2d746867 0x646e6168 0x64697320
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 33
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x69737361 0x656d6e67 0x6520746e 0x756c6176
    v128.const i32x4 0x73657461 0x67697220 0x682d7468 0x20646e61
    v128.const i32x4 0x65646973 0x636e6f20 0x00000065 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 41
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 10
    struct.new 1
    local.set 5
    local.get 5
    call 6
    i32.const 10
    i32.eq
    v128.const i32x4 0x74706163 0x64657275 0x74756d20 0x656c6261
    v128.const i32x4 0x696e6920 0x6c616974 0x6c617620 0x00006575
    array.new_fixed 24 2
    i32.const 0
    i32.const 30
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    i32.const 41
    call 7
    local.get 5
    call 6
    i32.const 41
    i32.eq
    v128.const i32x4 0x6c626973 0x20676e69 0x736f6c63 0x73657275
    v128.const i32x4 0x61687320 0x6d206572 0x62617475 0x6320656c
    v128.const i32x4 0x006c6c65 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 35
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 1)
    i32.const 42
    struct.set 1 0
    local.get 5
    call 6
    i32.const 42
    i32.eq
    v128.const i32x4 0x6c636564 0x6e697261 0x6f622067 0x73207964
    v128.const i32x4 0x65726168 0x756d2073 0x6c626174 0x65632065
    v128.const i32x4 0x00006c6c 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 34
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 40
    call 2
    local.set 6
    local.get 6
    local.set 15
    local.get 15
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 9)
    if (result i32) ;; label = @1
      local.get 15
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 9)
      call_ref 9
    else
      local.get 15
      local.get 15
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 15)
      call_ref 15
    end
    i32.const 41
    i32.eq
    v128.const i32x4 0x75746572 0x64656e72 0x6f6c6320 0x65727573
    v128.const i32x4 0x72696620 0x6d207473 0x74617475 0x006e6f69
    array.new_fixed 24 2
    i32.const 0
    i32.const 31
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    local.set 16
    local.get 16
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 9)
    if (result i32) ;; label = @1
      local.get 16
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 9)
      call_ref 9
    else
      local.get 16
      local.get 16
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 15)
      call_ref 15
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x75746572 0x64656e72 0x6f6c6320 0x65727573
    v128.const i32x4 0x74657220 0x736e6961 0x74756d20 0x6f697461
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 33
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 0
    struct.new 5
    local.set 7
    local.get 7
    ref.cast (ref 5)
    global.get 1
    struct.set 5 0
    local.get 7
    i32.const 43
    call 8
    i32.const 42
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x6c61762d 0x20646575
    v128.const i32x4 0x6174756d 0x20656c62 0x74706163 0x00657275
    array.new_fixed 24 2
    i32.const 0
    i32.const 31
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 40
    struct.new 0
    struct.new 5
    local.set 8
    local.get 8
    ref.cast (ref 5)
    i32.const 42
    struct.new 0
    struct.set 5 0
    local.get 8
    call 9
    i32.const 42
    i32.eq
    v128.const i32x4 0x696d6f6e 0x206c616e 0x6174756d 0x20656c62
    v128.const i32x4 0x74706163 0x00657275 0x00000000 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 23
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 40
    struct.new 1
    local.set 9
    local.get 9
    call 10
    local.set 10
    local.get 10
    local.set 17
    local.get 17
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 9)
    if (result i32) ;; label = @1
      local.get 17
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 9)
      call_ref 9
    else
      local.get 17
      local.get 17
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 15)
      call_ref 15
    end
    i32.const 41
    i32.eq
    v128.const i32x4 0x6e617274 0x69746973 0x6d206576 0x62617475
    v128.const i32x4 0x6320656c 0x75747061 0x66206572 0x74737269
    v128.const i32x4 0x69727720 0x00006574 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 38
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 10
    local.set 18
    local.get 18
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 9)
    if (result i32) ;; label = @1
      local.get 18
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 9)
      call_ref 9
    else
      local.get 18
      local.get 18
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 15)
      call_ref 15
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x6e617274 0x69746973 0x6d206576 0x62617475
    v128.const i32x4 0x6320656c 0x75747061 0x72206572 0x69617465
    v128.const i32x4 0x2064656e 0x74697277 0x00000065 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 41
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 40
    local.set 11
    local.get 11
    i64.const 2
    i64.add
    local.set 11
    local.get 11
    i64.const 42
    i64.eq
    v128.const i32x4 0x6f626e75 0x20646578 0x20343669 0x6174756d
    v128.const i32x4 0x20656c62 0x61636f6c 0x0000006c 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 25
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f32.const 0x1.4p+5 (;=40;)
    struct.new 2
    local.set 12
    local.get 12
    ref.cast (ref 2)
    f32.const 0x1.5p+5 (;=42;)
    struct.set 2 0
    local.get 12
    call 11
    f32.const 0x1.5p+5 (;=42;)
    f32.eq
    v128.const i32x4 0x74706163 0x64657275 0x32336620 0x74756d20
    v128.const i32x4 0x656c6261 0x636f6c20 0x00006c61 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 26
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f64.const 0x1.4p+5 (;=40;)
    struct.new 3
    local.set 13
    local.get 13
    ref.cast (ref 3)
    f64.const 0x1.5p+5 (;=42;)
    struct.set 3 0
    local.get 13
    call 12
    f64.const 0x1.5p+5 (;=42;)
    f64.eq
    v128.const i32x4 0x74706163 0x64657275 0x34366620 0x74756d20
    v128.const i32x4 0x656c6261 0x636f6c20 0x00006c61 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 26
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f32.const 0x1.4p+5 (;=40;)
    f32x4.splat
    struct.new 4
    local.set 14
    local.get 14
    ref.cast (ref 4)
    f32.const 0x1.5p+5 (;=42;)
    f32x4.splat
    struct.set 4 0
    local.get 14
    call 13
    f32.const 0x1.5p+5 (;=42;)
    f32.eq
    v128.const i32x4 0x74706163 0x64657275 0x32317620 0x756d2038
    v128.const i32x4 0x6c626174 0x6f6c2065 0x006c6163 0x00000000
    array.new_fixed 24 2
    i32.const 0
    i32.const 27
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;4;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    ref.cast (ref 1)
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 1
    i32.add
    struct.set 1 0
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    ref.cast (ref 1)
    struct.get 1 0
  )
  (func (;5;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 1)
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 1
    i32.add
    struct.set 1 0
    i32.const 42
  )
  (func (;6;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
  )
  (func (;7;) (type 17) (param eqref i32)
    local.get 0
    ref.cast (ref 1)
    local.get 1
    struct.set 1 0
  )
  (func (;8;) (type 16) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 0
    local.set 2
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 10)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 10)
      call_ref 10
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 16)
      call_ref 16
    end
  )
  (func (;9;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 0
    ref.cast (ref 0)
    struct.get 0 0
  )
  (func (;10;) (type 18) (param eqref) (result eqref)
    ref.func 14
    local.get 0
    struct.new 8
  )
  (func (;11;) (type 19) (param eqref) (result f32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
  )
  (func (;12;) (type 20) (param eqref) (result f64)
    local.get 0
    ref.cast (ref 3)
    struct.get 3 0
  )
  (func (;13;) (type 19) (param eqref) (result f32)
    local.get 0
    ref.cast (ref 4)
    struct.get 4 0
    f32x4.extract_lane 0
  )
  (func (;14;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    ref.cast (ref 1)
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 1
    i32.add
    struct.set 1 0
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    ref.cast (ref 1)
    struct.get 1 0
  )
  (func (;15;) (type 23)
    ref.func 0
    struct.new 6
    global.set 0
    ref.func 1
    struct.new 6
    global.set 1
  )
)
