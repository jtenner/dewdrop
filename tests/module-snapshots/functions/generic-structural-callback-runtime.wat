(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param eqref) (result eqref)))
  (type (;3;) (func (param eqref eqref) (result eqref)))
  (type (;4;) (func (param eqref i32) (result i32)))
  (type (;5;) (func (param eqref eqref eqref) (result eqref)))
  (type (;6;) (func (param eqref eqref i32) (result i32)))
  (type (;7;) (func (param eqref eqref i32) (result eqref)))
  (type (;8;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;9;) (func (param eqref i32) (result eqref)))
  (type (;10;) (func))
  (type (;11;) (func (param eqref eqref i32) (result eqref)))
  (type (;12;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;13;) (func (param eqref i32) (result eqref)))
  (type (;14;) (func (param eqref i32 i32) (result i32)))
  (type (;15;) (func (param eqref eqref i32 i32) (result i32)))
  (type (;16;) (func (param eqref i32) (result eqref)))
  (type (;17;) (struct (field i32)))
  (type (;18;) (func))
  (type (;19;) (array (mut v128)))
  (type (;20;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;23;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (type (;24;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (type (;25;) (sub final 0 (struct (field funcref) (field eqref))))
  (type (;26;) (sub final 0 (struct (field funcref) (field eqref))))
  (type (;27;) (sub final 0 (struct (field funcref) (field eqref))))
  (type (;28;) (sub final 0 (struct (field funcref) (field eqref))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 2))
  (export "invoke" (func 3))
  (export "invoke_nested" (func 4))
  (export "round_trip" (func 5))
  (export "invoke$dew$i32" (func 9))
  (export "invoke_nested$dew$i32" (func 10))
  (export "round_trip$dew$i32" (func 11))
  (export "__dew_init" (func 12))
  (elem (;0;) declare func 0 1 13 14 15 16 17 18 19 20)
  (func (;0;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 4) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
  )
  (func (;2;) (type 10)
    (local eqref)
    global.get 0
    i32.const 41
    i32.const 1
    call 6
    i32.const 42
    i32.eq
    v128.const i32x4 0x75727473 0x72757463 0x63206c61 0x626c6c61
    v128.const i32x4 0x206b6361 0x75677261 0x746e656d 0x00000000
    array.new_fixed 19 2
    i32.const 0
    i32.const 28
    struct.new 20
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 1
    global.get 0
    i32.const 41
    i32.const 1
    call 7
    i32.const 42
    i32.eq
    v128.const i32x4 0x7473656e 0x63206465 0x626c6c61 0x206b6361
    v128.const i32x4 0x75677261 0x746e656d 0x00000000 0x00000000
    array.new_fixed 19 2
    i32.const 0
    i32.const 24
    struct.new 20
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 0
    i32.const 1
    call 8
    local.set 0
  )
  (func (;3;) (type 11) (param eqref eqref i32) (result eqref)
    (local eqref eqref)
    local.get 2
    if (result eqref) ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 2)
      if (result eqref) ;; label = @2
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
        ref.cast (ref 3)
        call_ref 3
      end
    else
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 2)
      if (result eqref) ;; label = @2
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
        ref.cast (ref 3)
        call_ref 3
      end
    end
  )
  (func (;4;) (type 12) (param eqref eqref eqref i32) (result eqref)
    (local eqref eqref)
    local.get 3
    if (result eqref) ;; label = @1
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 3)
      if (result eqref) ;; label = @2
        local.get 1
        local.get 2
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 3)
        call_ref 3
      else
        local.get 4
        local.get 1
        local.get 2
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 5)
        call_ref 5
      end
    else
      local.get 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 3)
      if (result eqref) ;; label = @2
        local.get 1
        local.get 2
        local.get 5
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 3)
        call_ref 3
      else
        local.get 5
        local.get 1
        local.get 2
        local.get 5
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 5)
        call_ref 5
      end
    end
  )
  (func (;5;) (type 13) (param eqref i32) (result eqref)
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
  )
  (func (;6;) (type 14) (param eqref i32 i32) (result i32)
    (local eqref eqref)
    local.get 2
    if (result i32) ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 1)
      if (result i32) ;; label = @2
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
        ref.cast (ref 4)
        call_ref 4
      end
    else
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 1)
      if (result i32) ;; label = @2
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
        ref.cast (ref 4)
        call_ref 4
      end
    end
  )
  (func (;7;) (type 15) (param eqref eqref i32 i32) (result i32)
    (local eqref eqref)
    local.get 3
    if (result i32) ;; label = @1
      local.get 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 4)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 4)
        call_ref 4
      else
        local.get 4
        local.get 1
        local.get 2
        local.get 4
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 6)
        call_ref 6
      end
    else
      local.get 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      struct.get 0 0
      ref.test (ref 4)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        local.get 5
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 4)
        call_ref 4
      else
        local.get 5
        local.get 1
        local.get 2
        local.get 5
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 6)
        call_ref 6
      end
    end
  )
  (func (;8;) (type 16) (param eqref i32) (result eqref)
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
  )
  (func (;9;) (type 14) (param eqref i32 i32) (result i32)
    ref.func 13
    local.get 0
    struct.new 25
    local.get 1
    struct.new 17
    local.get 2
    call 3
    ref.cast (ref 17)
    struct.get 17 0
  )
  (func (;10;) (type 15) (param eqref eqref i32 i32) (result i32)
    ref.func 15
    local.get 0
    struct.new 26
    ref.func 17
    local.get 1
    struct.new 27
    local.get 2
    struct.new 17
    local.get 3
    call 4
    ref.cast (ref 17)
    struct.get 17 0
  )
  (func (;11;) (type 16) (param eqref i32) (result eqref)
    (local eqref)
    ref.func 19
    local.get 0
    struct.new 28
    local.get 1
    call 5
    local.set 2
    ref.func 20
    local.get 2
    struct.new 28
  )
  (func (;12;) (type 18)
    ref.func 0
    struct.new 0
    global.set 0
    ref.func 1
    struct.new 0
    global.set 1
  )
  (func (;13;) (type 3) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
    struct.new 17
  )
  (func (;14;) (type 4) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    end
    ref.cast (ref 17)
    struct.get 17 0
  )
  (func (;15;) (type 5) (param eqref eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 26)
    struct.get 26 1
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 4)
    if (result i32) ;; label = @1
      ref.func 18
      local.get 1
      struct.new 27
      local.get 2
      ref.cast (ref 17)
      struct.get 17 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 3
      ref.func 18
      local.get 1
      struct.new 27
      local.get 2
      ref.cast (ref 17)
      struct.get 17 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 6)
      call_ref 6
    end
    struct.new 17
  )
  (func (;16;) (type 6) (param eqref eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 26)
    struct.get 26 1
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 3)
    if (result eqref) ;; label = @1
      ref.func 17
      local.get 1
      struct.new 27
      local.get 2
      struct.new 17
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    else
      local.get 3
      ref.func 17
      local.get 1
      struct.new 27
      local.get 2
      struct.new 17
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 5)
      call_ref 5
    end
    ref.cast (ref 17)
    struct.get 17 0
  )
  (func (;17;) (type 3) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 27)
    struct.get 27 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
    struct.new 17
  )
  (func (;18;) (type 4) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 27)
    struct.get 27 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    end
    ref.cast (ref 17)
    struct.get 17 0
  )
  (func (;19;) (type 3) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 28)
    struct.get 28 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      ref.cast (ref 17)
      struct.get 17 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
    struct.new 17
  )
  (func (;20;) (type 4) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 28)
    struct.get 28 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      struct.new 17
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    end
    ref.cast (ref 17)
    struct.get 17 0
  )
)
