(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func (result (ref 0))))
  (type (;5;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;6;) (func))
  (type (;7;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;8;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;9;) (struct (field i32)))
  (type (;10;) (func))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 2))
  (export "identity_box" (func 3))
  (export "identity_box$dew$i32" (func 5))
  (export "__dew_init" (func 6))
  (elem (;0;) declare func 0)
  (func (;0;) (type 2) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 4) (result (ref 0))
    global.get 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;2;) (type 6)
    (local eqref)
    call 1
    i32.const 1
    call 4
    local.set 0
    i32.const 1
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x6c616320 0x6361626c 0x6761206b 0x67657267
    v128.const i32x4 0x00657461 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 3
    i32.const 0
    i32.const 35
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 7) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;4;) (type 8) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;5;) (type 8) (param (ref 0) i32) (result (ref 0))
    local.get 0
    local.get 1
    call 3
  )
  (func (;6;) (type 10)
    ref.func 0
    struct.new 1
    global.set 0
  )
)
