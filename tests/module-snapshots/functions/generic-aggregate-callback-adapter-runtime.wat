(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field eqref))))
  (type (;3;) (sub final 1 (struct (field i32) (field eqref))))
  (type (;4;) (sub (struct (field funcref))))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;8;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;9;) (func))
  (type (;10;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;11;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;12;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;13;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;14;) (struct (field i32)))
  (type (;15;) (func))
  (type (;16;) (array (mut v128)))
  (type (;17;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;20;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;21;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result eqref)))
  (type (;24;) (sub final 4 (struct (field funcref) (field eqref))))
  (type (;25;) (sub final 4 (struct (field funcref) (field eqref))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 1))
  (export "identity_box" (func 2))
  (export "identity_choice" (func 3))
  (export "identity_box$dew$i32" (func 6))
  (export "identity_choice$dew$i32" (func 7))
  (export "__dew_init" (func 8))
  (elem (;0;) declare func 0 9 10 11 12)
  (func (;0;) (type 5) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 9)
    (local (ref 0) (ref 1) (ref 1))
    global.get 0
    struct.new 0
    i32.const 1
    call 4
    local.set 0
    i32.const 0
    global.get 0
    struct.new 2
    i32.const 1
    call 5
    local.set 1
    i32.const 1
    global.get 0
    struct.new 3
    i32.const 0
    call 5
    local.set 2
    i32.const 1
    v128.const i32x4 0x72676761 0x74616765 0x61632065 0x61626c6c
    v128.const i32x4 0x61206b63 0x74706164 0x63207265 0x74736e6f
    v128.const i32x4 0x74637572 0x006e6f69 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 39
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 10) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;3;) (type 11) (param (ref 1) i32) (result (ref 1))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 1)
  )
  (func (;4;) (type 12) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;5;) (type 13) (param (ref 1) i32) (result (ref 1))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 1)
  )
  (func (;6;) (type 12) (param (ref 0) i32) (result (ref 0))
    (local eqref eqref eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    ref.func 9
    local.get 2
    struct.new 24
    struct.new 0
    local.get 1
    call 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    local.set 4
    ref.func 10
    local.get 4
    struct.new 24
    struct.new 0
  )
  (func (;7;) (type 13) (param (ref 1) i32) (result (ref 1))
    (local eqref eqref eqref eqref eqref)
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      local.get 0
      ref.cast (ref 2)
      struct.get 2 1
      local.set 3
      ref.func 11
      local.get 3
      struct.new 25
      struct.new 2
    else
      local.get 0
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 0
        ref.cast (ref 3)
        struct.get 3 1
        local.set 2
        ref.func 11
        local.get 2
        struct.new 25
        struct.new 3
      else
        unreachable
      end
    end
    ref.cast (ref 1)
    local.get 1
    call 3
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      local.get 4
      ref.cast (ref 2)
      struct.get 2 1
      local.set 6
      ref.func 12
      local.get 6
      struct.new 25
      struct.new 2
    else
      local.get 4
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 4
        ref.cast (ref 3)
        struct.get 3 1
        local.set 5
        ref.func 12
        local.get 5
        struct.new 25
        struct.new 3
      else
        unreachable
      end
    end
    ref.cast (ref 1)
  )
  (func (;8;) (type 15)
    ref.func 0
    struct.new 4
    global.set 0
  )
  (func (;9;) (type 23) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 24)
    struct.get 24 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 14)
      struct.get 14 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 2
      local.get 1
      ref.cast (ref 14)
      struct.get 14 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 6)
      call_ref 6
    end
    struct.new 14
  )
  (func (;10;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 24)
    struct.get 24 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 22)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 14
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 22)
      call_ref 22
    else
      local.get 2
      local.get 1
      struct.new 14
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 23)
      call_ref 23
    end
    ref.cast (ref 14)
    struct.get 14 0
  )
  (func (;11;) (type 23) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 14)
      struct.get 14 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 2
      local.get 1
      ref.cast (ref 14)
      struct.get 14 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 6)
      call_ref 6
    end
    struct.new 14
  )
  (func (;12;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 22)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 14
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 22)
      call_ref 22
    else
      local.get 2
      local.get 1
      struct.new 14
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 23)
      call_ref 23
    end
    ref.cast (ref 14)
    struct.get 14 0
  )
)
