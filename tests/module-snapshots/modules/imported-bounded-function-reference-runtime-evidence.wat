(module
  (rec
    (type (;0;) (func (param eqref) (result i32)))
  )
  (rec
    (type (;1;) (struct (field (ref null 0))))
  )
  (rec
    (type (;2;) (struct (field eqref) (field (ref 1))))
  )
  (rec
    (type (;3;) (sub (struct (field funcref))))
  )
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param eqref eqref) (result i32)))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param eqref i32) (result i32)))
  (type (;10;) (func (param eqref eqref) (result i32)))
  (type (;11;) (func (result eqref)))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (result i32)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (result eqref)))
  (type (;16;) (struct (field i32)))
  (type (;17;) (func))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;24;) (sub final 3 (struct (field funcref) (field eqref))))
  (type (;25;) (sub final 3 (struct (field funcref))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 4))
  (export "reader" (func 5))
  (export "__dew_init" (func 7))
  (elem (;0;) declare func 1 8 9)
  (func (;0;) (type 5) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 6) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    call_ref 0
  )
  (func (;2;) (type 7) (param i32) (result i32)
    local.get 0
    call 0
  )
  (func (;3;) (type 12) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.test (ref 8)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 8)
      call_ref 8
    else
      local.get 1
      i32.const 42
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 9)
      call_ref 9
    end
  )
  (func (;4;) (type 13) (result i32)
    (local i32)
    call 6
    call 3
    local.set 0
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x70616320 0x65727574
    v128.const i32x4 0x61632064 0x61626c6c 0x72206b63 0x6c757365
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 18 3
    i32.const 0
    i32.const 33
    struct.new 19
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
  )
  (func (;5;) (type 14) (param eqref) (result eqref)
    ref.func 8
    local.get 0
    struct.new 24
  )
  (func (;6;) (type 15) (result eqref)
    ref.func 9
    struct.new 25
  )
  (func (;7;) (type 17)
    ref.func 1
    struct.new 3
    global.set 0
  )
  (func (;8;) (type 6) (param eqref eqref) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 24)
    struct.get 24 1
    call 1
  )
  (func (;9;) (type 9) (param eqref i32) (result i32)
    local.get 1
    call 2
  )
)
