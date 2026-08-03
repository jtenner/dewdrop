(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field eqref))))
  (type (;3;) (sub final 1 (struct (field i32) (field eqref))))
  (type (;4;) (sub (struct (field funcref))))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (param i32)))
  (type (;8;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;9;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;10;) (func))
  (type (;11;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;12;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;13;) (func (param (ref 0) i32) (result (ref 0))))
  (type (;14;) (func (param (ref 1) i32) (result (ref 1))))
  (type (;15;) (struct (field i32)))
  (type (;16;) (func))
  (type (;17;) (array (mut v128)))
  (type (;18;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;21;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (param eqref eqref) (result eqref)))
  (type (;25;) (sub final 4 (struct (field funcref) (field eqref))))
  (type (;26;) (sub final 4 (struct (field funcref) (field eqref))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 2))
  (export "identity_box" (func 3))
  (export "identity_choice" (func 4))
  (export "identity_box$dew$i32" (func 7))
  (export "identity_choice$dew$i32" (func 8))
  (export "__dew_init" (func 9))
  (elem (;0;) declare func 0 10 11 12 13)
  (func (;0;) (type 5) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 7) (param i32)
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x72676761 0x74616765 0x61632065 0x61626c6c
    v128.const i32x4 0x72206b63 0x6c757365 0x00000074 0x00000000
    array.new_fixed 17 2
    i32.const 0
    i32.const 25
    struct.new 18
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 10)
    (local (ref 0) (ref 1) (ref 1) eqref eqref eqref eqref eqref eqref i32 eqref eqref i32)
    global.get 0
    struct.new 0
    i32.const 1
    call 5
    local.set 0
    i32.const 0
    global.get 0
    struct.new 2
    i32.const 1
    call 6
    local.set 1
    i32.const 1
    global.get 0
    struct.new 3
    i32.const 0
    call 6
    local.set 2
    local.get 0
    struct.get 0 0
    local.set 3
    local.get 3
    local.set 6
    local.get 6
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 6
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 6
      i32.const 41
      local.get 6
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 6)
      call_ref 6
    end
    call 1
    local.get 1
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 0
      i32.eq
      if ;; label = @2
        local.get 8
        ref.cast (ref 2)
        struct.get 2 1
        local.set 4
        local.get 4
        local.set 7
        local.get 7
        ref.cast (ref 4)
        struct.get 4 0
        ref.test (ref 5)
        if (result i32) ;; label = @3
          i32.const 41
          local.get 7
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 5)
          call_ref 5
        else
          local.get 7
          i32.const 41
          local.get 7
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 6)
          call_ref 6
        end
        local.set 9
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    call 1
    local.get 2
    local.set 11
    block ;; label = @1
      local.get 11
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 11
        ref.cast (ref 3)
        struct.get 3 1
        local.set 5
        local.get 5
        local.set 10
        local.get 10
        ref.cast (ref 4)
        struct.get 4 0
        ref.test (ref 5)
        if (result i32) ;; label = @3
          i32.const 41
          local.get 10
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 5)
          call_ref 5
        else
          local.get 10
          i32.const 41
          local.get 10
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 6)
          call_ref 6
        end
        local.set 12
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 12
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 12
    call 1
  )
  (func (;3;) (type 11) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;4;) (type 12) (param (ref 1) i32) (result (ref 1))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 1)
  )
  (func (;5;) (type 13) (param (ref 0) i32) (result (ref 0))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 0)
  )
  (func (;6;) (type 14) (param (ref 1) i32) (result (ref 1))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 1)
  )
  (func (;7;) (type 13) (param (ref 0) i32) (result (ref 0))
    (local eqref eqref eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    ref.func 10
    local.get 2
    struct.new 25
    struct.new 0
    local.get 1
    call 3
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    local.set 4
    ref.func 11
    local.get 4
    struct.new 25
    struct.new 0
  )
  (func (;8;) (type 14) (param (ref 1) i32) (result (ref 1))
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
      ref.func 12
      local.get 3
      struct.new 26
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
        ref.func 12
        local.get 2
        struct.new 26
        struct.new 3
      else
        unreachable
      end
    end
    ref.cast (ref 1)
    local.get 1
    call 4
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
      ref.func 13
      local.get 6
      struct.new 26
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
        ref.func 13
        local.get 5
        struct.new 26
        struct.new 3
      else
        unreachable
      end
    end
    ref.cast (ref 1)
  )
  (func (;9;) (type 16)
    ref.func 0
    struct.new 4
    global.set 0
  )
  (func (;10;) (type 24) (param eqref eqref) (result eqref)
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
      ref.cast (ref 15)
      struct.get 15 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 2
      local.get 1
      ref.cast (ref 15)
      struct.get 15 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 6)
      call_ref 6
    end
    struct.new 15
  )
  (func (;11;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 23)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 15
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 23)
      call_ref 23
    else
      local.get 2
      local.get 1
      struct.new 15
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 24)
      call_ref 24
    end
    ref.cast (ref 15)
    struct.get 15 0
  )
  (func (;12;) (type 24) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    ref.cast (ref 26)
    struct.get 26 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 15)
      struct.get 15 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 2
      local.get 1
      ref.cast (ref 15)
      struct.get 15 0
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 6)
      call_ref 6
    end
    struct.new 15
  )
  (func (;13;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 26)
    struct.get 26 1
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.test (ref 23)
    if (result eqref) ;; label = @1
      local.get 1
      struct.new 15
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 23)
      call_ref 23
    else
      local.get 2
      local.get 1
      struct.new 15
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 24)
      call_ref 24
    end
    ref.cast (ref 15)
    struct.get 15 0
  )
)
