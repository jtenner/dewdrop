(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (func (param eqref) (result i32)))
  (type (;3;) (struct (field (ref null 2))))
  (type (;4;) (struct (field eqref) (field (ref 3))))
  (type (;5;) (func (param eqref) (result i32)))
  (type (;6;) (struct (field (ref null 5))))
  (type (;7;) (struct (field eqref) (field (ref 6))))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param (ref 0)) (result i32)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param eqref i32) (result i32)))
  (type (;12;) (func (param eqref (ref 0)) (result i32)))
  (type (;13;) (func (param eqref eqref) (result i32)))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param (ref 0)) (result i32)))
  (type (;18;) (func (result eqref)))
  (type (;19;) (func (result eqref)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (result i32)))
  (type (;24;) (func (param eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result eqref)))
  (type (;26;) (func (result eqref)))
  (type (;27;) (func (result eqref)))
  (type (;28;) (func (result eqref)))
  (type (;29;) (func (result eqref)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param eqref eqref eqref) (result i32)))
  (type (;32;) (func (param i32) (result i32)))
  (type (;33;) (func (param i32) (result i32)))
  (type (;34;) (func (param eqref) (result i32)))
  (type (;35;) (func (param i32) (result i32)))
  (type (;36;) (struct (field i32)))
  (type (;37;) (func))
  (type (;38;) (array (mut v128)))
  (type (;39;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;41;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;42;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (type (;43;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (type (;44;) (sub final 1 (struct (field funcref) (field eqref))))
  (type (;45;) (sub final 1 (struct (field funcref) (field eqref) (field eqref))))
  (type (;46;) (sub final 1 (struct (field funcref))))
  (type (;47;) (sub final 1 (struct (field funcref))))
  (type (;48;) (sub final 1 (struct (field funcref))))
  (type (;49;) (sub final 1 (struct (field funcref))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 7))
  (export "reader" (func 8))
  (export "paired_reader" (func 9))
  (export "__dew_init" (func 20))
  (elem (;0;) declare func 14 15 21 22 23 24 25 26)
  (func (;0;) (type 14) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 15) (param i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 1
    else
      i32.const 0
    end
  )
  (func (;2;) (type 16) (param i32) (result i32)
    local.get 0
  )
  (func (;3;) (type 17) (param (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
  )
  (func (;4;) (type 20) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 8)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    else
      local.get 1
      i32.const 42
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      call_ref 11
    end
  )
  (func (;5;) (type 21) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 9)
    if (result i32) ;; label = @1
      i32.const 42
      struct.new 0
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 9)
      call_ref 9
    else
      local.get 1
      i32.const 42
      struct.new 0
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 12)
      call_ref 12
    end
  )
  (func (;6;) (type 22) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 8)
    if (result i32) ;; label = @1
      i32.const 1
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    else
      local.get 1
      i32.const 1
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      call_ref 11
    end
  )
  (func (;7;) (type 23) (result i32)
    (local i32 i32 i32 i32)
    call 10
    call 4
    local.set 0
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x74706163 0x64657275 0x6e757220 0x656d6974
    v128.const i32x4 0x69766520 0x636e6564 0x61632065 0x61626c6c
    v128.const i32x4 0x72206b63 0x6c757365 0x00000074 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 41
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 11
    call 4
    local.set 1
    local.get 1
    i32.const 84
    i32.eq
    v128.const i32x4 0x6564726f 0x20646572 0x746c756d 0x6f622d69
    v128.const i32x4 0x20646e75 0x74706163 0x64657275 0x6c616320
    v128.const i32x4 0x6361626c 0x6572206b 0x746c7573 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 44
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 12
    call 5
    local.set 2
    local.get 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x696d6f6e 0x206c616e 0x64697665 0x65636e65
    v128.const i32x4 0x6177612d 0x63206572 0x626c6c61 0x206b6361
    v128.const i32x4 0x75736572 0x0000746c 0x00000000 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 38
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 13
    call 6
    local.set 3
    local.get 3
    i32.const 1
    i32.eq
    v128.const i32x4 0x656d6173 0x7261632d 0x72656972 0x69766520
    v128.const i32x4 0x636e6564 0x77612d65 0x20657261 0x6c6c6163
    v128.const i32x4 0x6b636162 0x73657220 0x00746c75 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 43
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.get 1
    i32.add
    local.get 2
    i32.add
    local.get 3
    i32.add
  )
  (func (;8;) (type 24) (param eqref) (result eqref)
    ref.func 21
    local.get 0
    struct.new 44
  )
  (func (;9;) (type 25) (param eqref eqref) (result eqref)
    ref.func 22
    local.get 0
    local.get 1
    struct.new 45
  )
  (func (;10;) (type 26) (result eqref)
    ref.func 23
    struct.new 46
  )
  (func (;11;) (type 27) (result eqref)
    ref.func 24
    struct.new 47
  )
  (func (;12;) (type 28) (result eqref)
    ref.func 25
    struct.new 48
  )
  (func (;13;) (type 29) (result eqref)
    ref.func 26
    struct.new 49
  )
  (func (;14;) (type 30) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    call_ref 2
  )
  (func (;15;) (type 31) (param eqref eqref eqref) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    call_ref 2
    local.get 0
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    call_ref 5
    i32.add
  )
  (func (;16;) (type 32) (param i32) (result i32)
    local.get 0
    call 0
  )
  (func (;17;) (type 33) (param i32) (result i32)
    local.get 0
    call 0
    local.get 0
    call 2
    i32.add
  )
  (func (;18;) (type 34) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 0)
    call 3
  )
  (func (;19;) (type 35) (param i32) (result i32)
    local.get 0
    call 1
  )
  (func (;20;) (type 37)
    ref.func 14
    struct.new 1
    global.set 0
    ref.func 15
    struct.new 1
    global.set 1
  )
  (func (;21;) (type 12) (param eqref (ref 0)) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 44)
    struct.get 44 1
    call 14
  )
  (func (;22;) (type 12) (param eqref (ref 0)) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    local.get 0
    ref.cast (ref 45)
    struct.get 45 2
    call 15
  )
  (func (;23;) (type 11) (param eqref i32) (result i32)
    local.get 1
    call 16
  )
  (func (;24;) (type 11) (param eqref i32) (result i32)
    local.get 1
    call 17
  )
  (func (;25;) (type 12) (param eqref (ref 0)) (result i32)
    local.get 1
    call 18
  )
  (func (;26;) (type 11) (param eqref i32) (result i32)
    local.get 1
    call 19
  )
)
