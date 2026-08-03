(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param eqref) (result eqref)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param eqref eqref) (result eqref)))
  (type (;4;) (func (param eqref i32) (result i32)))
  (type (;5;) (func (param eqref eqref i32) (result eqref)))
  (type (;6;) (func))
  (type (;7;) (func (param eqref eqref i32) (result eqref)))
  (type (;8;) (func (param eqref i32 i32) (result i32)))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 1))
  (export "invoke" (func 2))
  (export "__dew_init" (func 4))
  (elem (;0;) declare func 0)
  (func (;0;) (type 2) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 6)
    global.get 0
    i32.const 41
    i32.const 1
    call 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x75727473 0x72757463 0x63206c61 0x626c6c61
    v128.const i32x4 0x206b6361 0x616d6564 0x0000646e 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 26
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 7) (param eqref eqref i32) (result eqref)
    (local eqref eqref)
    local.get 2
    if (result eqref) ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 1)
      if (result eqref) ;; label = @2
        local.get 1
        local.get 3
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 1)
        call_ref 1
      else
        local.get 3
        local.get 1
        local.get 3
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 3)
        call_ref 3
      end
    else
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 1)
      if (result eqref) ;; label = @2
        local.get 1
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 1)
        call_ref 1
      else
        local.get 4
        local.get 1
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 3)
        call_ref 3
      end
    end
  )
  (func (;3;) (type 8) (param eqref i32 i32) (result i32)
    (local eqref eqref)
    local.get 2
    if (result i32) ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 2)
      if (result i32) ;; label = @2
        local.get 1
        local.get 3
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 2)
        call_ref 2
      else
        local.get 3
        local.get 1
        local.get 3
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 4)
        call_ref 4
      end
    else
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 2)
      if (result i32) ;; label = @2
        local.get 1
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 2)
        call_ref 2
      else
        local.get 4
        local.get 1
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 4)
        call_ref 4
      end
    end
  )
  (func (;4;) (type 9)
    ref.func 0
    struct.new 0
    global.set 0
  )
)
