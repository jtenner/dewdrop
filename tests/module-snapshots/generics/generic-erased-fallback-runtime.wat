(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (func (param (ref 0)) (result (ref 0))))
  (type (;3;) (func (param eqref) (result eqref)))
  (type (;4;) (func (param eqref (ref 0)) (result (ref 0))))
  (type (;5;) (func (param eqref eqref) (result eqref)))
  (type (;6;) (func (result eqref)))
  (type (;7;) (func))
  (type (;8;) (func (param eqref) (result eqref)))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 1))
  (export "identity" (func 2))
  (export "__dew_init" (func 4))
  (elem (;0;) declare func 3)
  (func (;0;) (type 6) (result eqref)
    global.get 0
  )
  (func (;1;) (type 7)
    (local eqref eqref eqref)
    call 0
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 2)
    if (result eqref) ;; label = @1
      i32.const 42
      struct.new 0
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      i32.const 42
      struct.new 0
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    end
    ref.cast (ref 0)
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x73617265 0x67206465 0x72656e65 0x72206369
    v128.const i32x4 0x72656665 0x65636e65 0x6c616620 0x6361626c
    v128.const i32x4 0x0000006b 0x00000000 0x00000000 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 33
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 8) (param eqref) (result eqref)
    local.get 0
  )
  (func (;3;) (type 2) (param (ref 0)) (result (ref 0))
    local.get 0
    call 2
    ref.cast (ref 0)
  )
  (func (;4;) (type 9)
    ref.func 3
    struct.new 1
    global.set 0
  )
)
