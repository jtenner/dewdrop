(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (struct))
  (type (;4;) (func (result (ref 3))))
  (type (;5;) (func (param (ref 3) eqref eqref) (result (ref 2))))
  (type (;6;) (func (param (ref 2)) (result i32)))
  (type (;7;) (func (param (ref 2)) (result i32)))
  (type (;8;) (func (param (ref 3) i32 i32) (result (ref 2))))
  (type (;9;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field eqref) (field (mut i32))))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32)))
  (type (;13;) (func (param (ref 11)) (result i32)))
  (type (;14;) (func (param eqref (ref 11)) (result (ref 12))))
  (type (;15;) (func (param eqref (ref 11) i32) (result (ref 12))))
  (type (;16;) (func (param (ref 12)) (result i32)))
  (type (;17;) (func (param (ref 12)) (result i32)))
  (type (;18;) (func (param (ref 12)) (result i32)))
  (type (;19;) (func (param (ref 12) eqref eqref) (result i32)))
  (type (;20;) (func))
  (type (;21;) (func (param (ref 12) i32)))
  (type (;22;) (func (param (ref 12) i32)))
  (type (;23;) (func (param (ref 12) eqref)))
  (type (;24;) (func (param (ref 12)) (result (ref 0))))
  (type (;25;) (func (param (ref 12)) (result (ref 0))))
  (type (;26;) (func (param (ref 12))))
  (type (;27;) (func (param (ref 12)) (result (ref 10))))
  (type (;28;) (func (param (ref 10)) (result eqref)))
  (type (;29;) (func (param (ref 12)) (result (ref 0))))
  (type (;30;) (func (param eqref (ref 11)) (result (ref 12))))
  (type (;31;) (func (param (ref 12)) (result i32)))
  (type (;32;) (func (param (ref 12)) (result (ref 0))))
  (type (;33;) (func (param (ref 12) eqref)))
  (type (;34;) (func (param (ref 12)) (result i32)))
  (type (;35;) (func (param eqref (ref 11) i32) (result (ref 12))))
  (type (;36;) (func (param eqref (ref 11)) (result (ref 12))))
  (type (;37;) (func (param (ref 12) eqref)))
  (type (;38;) (func (param (ref 12)) (result (ref 0))))
  (type (;39;) (func (param (ref 12)) (result (ref 10))))
  (type (;40;) (func (param (ref 10)) (result eqref)))
  (type (;41;) (func (param (ref 12)) (result i32)))
  (type (;42;) (func (param (ref 12))))
  (type (;43;) (func (param (ref 12) i32)))
  (type (;44;) (func (param (ref 12) i32)))
  (type (;45;) (func (param (ref 12) i32)))
  (type (;46;) (func (param (ref 12) i32)))
  (type (;47;) (func (param (ref 12) eqref eqref) (result i32)))
  (type (;48;) (func (param (ref 12) eqref eqref) (result i32)))
  (type (;49;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;50;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;51;) (struct (field (ref 12))))
  (type (;52;) (struct (field (ref 10))))
  (type (;53;) (func (param (ref 50) (ref 49) (ref 49)) (result (ref 2))))
  (type (;54;) (func (param eqref (ref 11)) (result (ref 51))))
  (type (;55;) (func (param eqref (ref 11) i32) (result (ref 51))))
  (type (;56;) (func (param (ref 51)) (result i32)))
  (type (;57;) (func (param (ref 51)) (result i32)))
  (type (;58;) (func (param (ref 51)) (result i32)))
  (type (;59;) (func (param (ref 51) eqref eqref)))
  (type (;60;) (func (param (ref 51)) (result (ref 0))))
  (type (;61;) (func (param (ref 51)) (result (ref 0))))
  (type (;62;) (func (param (ref 51))))
  (type (;63;) (func (param (ref 49)) (result eqref)))
  (type (;64;) (func (param (ref 49)) (result eqref)))
  (type (;65;) (func (param (ref 51)) (result (ref 52))))
  (type (;66;) (func (param (ref 52)) (result (ref 49))))
  (type (;67;) (func (param (ref 51)) (result (ref 0))))
  (type (;68;) (func (param (ref 49)) (result i32)))
  (type (;69;) (func (param eqref (ref 11)) (result (ref 51))))
  (type (;70;) (func (param (ref 51)) (result i32)))
  (type (;71;) (func (param (ref 51)) (result (ref 0))))
  (type (;72;) (func (param (ref 51) i32 i32)))
  (type (;73;) (func (param (ref 51)) (result i32)))
  (type (;74;) (func (param (ref 49)) (result i32)))
  (type (;75;) (func (param eqref (ref 11) i32) (result (ref 51))))
  (type (;76;) (func (param eqref (ref 11)) (result (ref 51))))
  (type (;77;) (func (param (ref 51) eqref i32)))
  (type (;78;) (func (param (ref 51)) (result (ref 0))))
  (type (;79;) (func (param (ref 49)) (result eqref)))
  (type (;80;) (func (param (ref 51)) (result (ref 52))))
  (type (;81;) (func (param (ref 52)) (result (ref 49))))
  (type (;82;) (func (param (ref 51)) (result i32)))
  (type (;83;) (func (param (ref 51))))
  (type (;84;) (func (param (ref 50) (ref 49) (ref 49)) (result (ref 2))))
  (type (;85;) (func (param (ref 50) (ref 49) (ref 49)) (result (ref 2))))
  (type (;86;) (struct (field i32)))
  (type (;87;) (func))
  (type (;88;) (func (param (ref 51)) (result i32)))
  (type (;89;) (func))
  (type (;90;) (array (mut v128)))
  (type (;91;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;92;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;93;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;94;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (type (;95;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (type (;96;) (array (mut i32)))
  (type (;97;) (array (mut i64)))
  (type (;98;) (array (mut f32)))
  (type (;99;) (array (mut f64)))
  (type (;100;) (array (mut v128)))
  (type (;101;) (array (mut eqref)))
  (export "main" (func 47))
  (func (;0;) (type 4) (result (ref 3))
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;1;) (type 6) (param (ref 2)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 2)
              struct.get 2 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 1
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;2;) (type 7) (param (ref 2)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 2)
              struct.get 2 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;3;) (type 8) (param (ref 3) i32 i32) (result (ref 2))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 2
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 2
      else
        i32.const 2
        struct.new 2
      end
    end
    ref.cast (ref 2)
  )
  (func (;4;) (type 13) (param (ref 11)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 11)
            struct.get 11 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;5;) (type 20))
  (func (;6;) (type 29) (param (ref 12)) (result (ref 0))
    (local i32 eqref eqref eqref i32 eqref eqref eqref)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      struct.get 12 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 101)
      local.get 5
      array.get 101
      local.set 2
      local.get 0
      struct.get 12 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 101)
      local.get 5
      array.get 101
      local.set 3
      local.get 0
      struct.get 12 0
      local.set 4
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 0
      else
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        array.get 101
        local.set 7
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        ref.null eq
        array.set 101
        local.get 4
        ref.cast (ref 9)
        local.get 5
        struct.set 9 1
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 7
        struct.new 1
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        struct.get 12 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        local.get 8
        array.set 101
        local.get 0
        ref.cast (ref 12)
        i32.const 0
        call 20
      else
        call 5
      end
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 2
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;7;) (type 30) (param eqref (ref 11)) (result (ref 12))
    i32.const 0
    array.new_default 101
    i32.const 0
    i32.const 0
    struct.new 9
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 11)
    call 4
    struct.new 12
    ref.cast (ref 12)
  )
  (func (;8;) (type 31) (param (ref 12)) (result i32)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
    i32.const 0
    i32.eq
  )
  (func (;9;) (type 32) (param (ref 12)) (result (ref 0))
    (local eqref i32 eqref)
    local.get 0
    struct.get 12 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 9)
    struct.get 9 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 1
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 101)
      local.get 2
      array.get 101
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    ref.cast (ref 0)
  )
  (func (;10;) (type 33) (param (ref 12) eqref)
    (local eqref i32 eqref eqref)
    local.get 0
    struct.get 12 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    local.get 2
    ref.cast (ref 9)
    struct.get 9 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 9)
      struct.get 9 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 9)
        struct.get 9 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 9)
      struct.get 9 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 101
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 9)
          struct.get 9 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 101)
          local.get 3
          local.get 2
          ref.cast (ref 9)
          struct.get 9 0
          ref.cast (ref 101)
          local.get 3
          array.get 101
          array.set 101
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 9)
      local.get 4
      struct.set 9 0
      local.get 2
      ref.cast (ref 9)
      local.get 4
      ref.cast (ref 101)
      array.len
      struct.set 9 2
    end
    local.get 2
    ref.cast (ref 9)
    struct.get 9 0
    ref.cast (ref 101)
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    local.get 5
    array.set 101
    local.get 2
    ref.cast (ref 9)
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    i32.const 1
    i32.add
    struct.set 9 1
    local.get 0
    ref.cast (ref 12)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
    i32.const 1
    i32.sub
    call 21
  )
  (func (;11;) (type 34) (param (ref 12)) (result i32)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
  )
  (func (;12;) (type 35) (param eqref (ref 11) i32) (result (ref 12))
    (local eqref i32 eqref)
    local.get 2
    local.set 4
    local.get 4
    array.new_default 101
    i32.const 0
    local.get 4
    struct.new 9
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 11)
    call 4
    struct.new 12
    ref.cast (ref 12)
  )
  (func (;13;) (type 36) (param eqref (ref 11)) (result (ref 12))
    i32.const 0
    array.new_default 101
    i32.const 0
    i32.const 0
    struct.new 9
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 11)
    call 4
    struct.new 12
    ref.cast (ref 12)
  )
  (func (;14;) (type 37) (param (ref 12) eqref)
    (local eqref i32 eqref eqref)
    local.get 0
    struct.get 12 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    local.get 2
    ref.cast (ref 9)
    struct.get 9 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 9)
      struct.get 9 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 9)
        struct.get 9 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 9)
      struct.get 9 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 101
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 9)
          struct.get 9 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 101)
          local.get 3
          local.get 2
          ref.cast (ref 9)
          struct.get 9 0
          ref.cast (ref 101)
          local.get 3
          array.get 101
          array.set 101
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 9)
      local.get 4
      struct.set 9 0
      local.get 2
      ref.cast (ref 9)
      local.get 4
      ref.cast (ref 101)
      array.len
      struct.set 9 2
    end
    local.get 2
    ref.cast (ref 9)
    struct.get 9 0
    ref.cast (ref 101)
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    local.get 5
    array.set 101
    local.get 2
    ref.cast (ref 9)
    local.get 2
    ref.cast (ref 9)
    struct.get 9 1
    i32.const 1
    i32.add
    struct.set 9 1
    local.get 0
    ref.cast (ref 12)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
    i32.const 1
    i32.sub
    call 22
  )
  (func (;15;) (type 38) (param (ref 12)) (result (ref 0))
    (local i32 eqref eqref eqref i32 eqref eqref eqref)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      struct.get 12 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 101)
      local.get 5
      array.get 101
      local.set 2
      local.get 0
      struct.get 12 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 101)
      local.get 5
      array.get 101
      local.set 3
      local.get 0
      struct.get 12 0
      local.set 4
      local.get 4
      ref.cast (ref 9)
      struct.get 9 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 0
      else
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        array.get 101
        local.set 7
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        ref.null eq
        array.set 101
        local.get 4
        ref.cast (ref 9)
        local.get 5
        struct.set 9 1
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 7
        struct.new 1
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        struct.get 12 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 5
        local.get 8
        array.set 101
        local.get 0
        ref.cast (ref 12)
        i32.const 0
        call 23
      else
        call 5
      end
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 2
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;16;) (type 39) (param (ref 12)) (result (ref 10))
    local.get 0
    struct.get 12 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;17;) (type 40) (param (ref 10)) (result eqref)
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 10)
    struct.get 10 1
    local.get 1
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 9)
    struct.get 9 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 1
    ref.cast (ref 10)
    struct.get 10 1
    local.set 2
    local.get 1
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 9)
    struct.get 9 0
    ref.cast (ref 101)
    local.get 2
    array.get 101
    local.get 1
    ref.cast (ref 10)
    local.get 2
    i32.const 1
    i32.add
    struct.set 10 1
  )
  (func (;18;) (type 41) (param (ref 12)) (result i32)
    local.get 0
    struct.get 12 0
    ref.cast (ref 9)
    struct.get 9 2
  )
  (func (;19;) (type 42) (param (ref 12))
    (local eqref i32 eqref)
    local.get 0
    struct.get 12 0
    local.set 1
    i32.const 0
    local.set 2
    block ;; label = @1
      loop ;; label = @2
        local.get 2
        local.get 1
        ref.cast (ref 9)
        struct.get 9 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 1
        ref.cast (ref 9)
        struct.get 9 0
        ref.cast (ref 101)
        local.get 2
        ref.null eq
        array.set 101
        local.get 2
        i32.const 1
        i32.add
        local.set 2
        br 0 (;@2;)
      end
    end
    local.get 1
    ref.cast (ref 9)
    i32.const 0
    struct.set 9 1
  )
  (func (;20;) (type 43) (param (ref 12) i32)
    (local i32 i32 i32 i32 i32 eqref eqref eqref i32 eqref eqref eqref i32)
    local.get 1
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 14
            local.set 2
            local.get 0
            struct.get 12 0
            ref.cast (ref 9)
            struct.get 9 1
            local.set 3
            local.get 2
            i32.const 2
            i32.mul
            i32.const 1
            i32.add
            local.set 4
            local.get 4
            local.get 3
            i32.ge_u
            if ;; label = @5
              call 5
              br 4 (;@1;)
            else
              local.get 4
              i32.const 1
              i32.add
              local.set 5
              local.get 5
              local.get 3
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 0
                ref.cast (ref 12)
                local.get 0
                struct.get 12 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                array.get 101
                local.get 0
                struct.get 12 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                array.get 101
                call 24
              else
                i32.const 0
              end
              if (result i32) ;; label = @6
                local.get 5
              else
                local.get 4
              end
              local.set 6
              local.get 0
              struct.get 12 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 10
              array.get 101
              local.set 7
              local.get 0
              struct.get 12 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 10
              array.get 101
              local.set 8
              local.get 0
              ref.cast (ref 12)
              local.get 8
              local.get 7
              call 24
              if ;; label = @6
                local.get 0
                struct.get 12 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                local.get 12
                array.set 101
                local.get 0
                struct.get 12 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                local.get 13
                array.set 101
                local.get 6
                local.set 14
                br 4 (;@2;)
              else
                call 5
                br 5 (;@1;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;21;) (type 44) (param (ref 12) i32)
    (local i32 i32 eqref eqref eqref i32 eqref eqref eqref i32)
    local.get 1
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 11
          i32.const 0
          i32.eq
          if ;; label = @4
            call 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 11
            local.set 2
            local.get 2
            i32.const 1
            i32.sub
            i32.const 2
            i32.div_u
            local.set 3
            local.get 0
            struct.get 12 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 9)
            struct.get 9 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 9)
            struct.get 9 0
            ref.cast (ref 101)
            local.get 7
            array.get 101
            local.set 4
            local.get 0
            struct.get 12 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 9)
            struct.get 9 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 9)
            struct.get 9 0
            ref.cast (ref 101)
            local.get 7
            array.get 101
            local.set 5
            local.get 0
            ref.cast (ref 12)
            local.get 4
            local.get 5
            call 24
            if ;; label = @5
              local.get 0
              struct.get 12 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 7
              local.get 9
              array.set 101
              local.get 0
              struct.get 12 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 7
              local.get 10
              array.set 101
              local.get 3
              local.set 11
              br 3 (;@2;)
            else
              call 5
              br 4 (;@1;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;22;) (type 45) (param (ref 12) i32)
    (local i32 i32 eqref eqref eqref i32 eqref eqref eqref i32)
    local.get 1
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 11
          i32.const 0
          i32.eq
          if ;; label = @4
            call 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 11
            local.set 2
            local.get 2
            i32.const 1
            i32.sub
            i32.const 2
            i32.div_u
            local.set 3
            local.get 0
            struct.get 12 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 9)
            struct.get 9 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 9)
            struct.get 9 0
            ref.cast (ref 101)
            local.get 7
            array.get 101
            local.set 4
            local.get 0
            struct.get 12 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 9)
            struct.get 9 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 9)
            struct.get 9 0
            ref.cast (ref 101)
            local.get 7
            array.get 101
            local.set 5
            local.get 0
            ref.cast (ref 12)
            local.get 4
            local.get 5
            call 25
            if ;; label = @5
              local.get 0
              struct.get 12 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 7
              local.get 9
              array.set 101
              local.get 0
              struct.get 12 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 7
              local.get 10
              array.set 101
              local.get 3
              local.set 11
              br 3 (;@2;)
            else
              call 5
              br 4 (;@1;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;23;) (type 46) (param (ref 12) i32)
    (local i32 i32 i32 i32 i32 eqref eqref eqref i32 eqref eqref eqref i32)
    local.get 1
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 14
            local.set 2
            local.get 0
            struct.get 12 0
            ref.cast (ref 9)
            struct.get 9 1
            local.set 3
            local.get 2
            i32.const 2
            i32.mul
            i32.const 1
            i32.add
            local.set 4
            local.get 4
            local.get 3
            i32.ge_u
            if ;; label = @5
              call 5
              br 4 (;@1;)
            else
              local.get 4
              i32.const 1
              i32.add
              local.set 5
              local.get 5
              local.get 3
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 0
                ref.cast (ref 12)
                local.get 0
                struct.get 12 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                array.get 101
                local.get 0
                struct.get 12 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                array.get 101
                call 25
              else
                i32.const 0
              end
              if (result i32) ;; label = @6
                local.get 5
              else
                local.get 4
              end
              local.set 6
              local.get 0
              struct.get 12 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 10
              array.get 101
              local.set 7
              local.get 0
              struct.get 12 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 9)
              struct.get 9 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 9)
              struct.get 9 0
              ref.cast (ref 101)
              local.get 10
              array.get 101
              local.set 8
              local.get 0
              ref.cast (ref 12)
              local.get 8
              local.get 7
              call 25
              if ;; label = @6
                local.get 0
                struct.get 12 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                local.get 12
                array.set 101
                local.get 0
                struct.get 12 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 9)
                struct.get 9 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 9)
                struct.get 9 0
                ref.cast (ref 101)
                local.get 10
                local.get 13
                array.set 101
                local.get 6
                local.set 14
                br 4 (;@2;)
              else
                call 5
                br 5 (;@1;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;24;) (type 47) (param (ref 12) eqref eqref) (result i32)
    (local eqref)
    local.get 0
    struct.get 12 6
    ref.cast (ref 50)
    local.get 1
    ref.cast (ref 49)
    local.get 2
    ref.cast (ref 49)
    call 43
    local.set 3
    local.get 0
    struct.get 12 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 2)
      call 2
    else
      local.get 3
      ref.cast (ref 2)
      call 1
    end
  )
  (func (;25;) (type 48) (param (ref 12) eqref eqref) (result i32)
    (local eqref)
    local.get 0
    struct.get 12 6
    ref.cast (ref 50)
    local.get 1
    ref.cast (ref 49)
    local.get 2
    ref.cast (ref 49)
    call 44
    local.set 3
    local.get 0
    struct.get 12 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 2)
      call 2
    else
      local.get 3
      ref.cast (ref 2)
      call 1
    end
  )
  (func (;26;) (type 67) (param (ref 51)) (result (ref 0))
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 6
    ref.cast (ref 0)
  )
  (func (;27;) (type 68) (param (ref 49)) (result i32)
    local.get 0
    struct.get 49 0
  )
  (func (;28;) (type 69) (param eqref (ref 11)) (result (ref 51))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 50
    local.get 1
    ref.cast (ref 11)
    call 7
    struct.new 51
    ref.cast (ref 51)
  )
  (func (;29;) (type 70) (param (ref 51)) (result i32)
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 8
  )
  (func (;30;) (type 71) (param (ref 51)) (result (ref 0))
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 9
    ref.cast (ref 0)
  )
  (func (;31;) (type 72) (param (ref 51) i32 i32)
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    local.get 1
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 49
    call 10
  )
  (func (;32;) (type 73) (param (ref 51)) (result i32)
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 11
  )
  (func (;33;) (type 74) (param (ref 49)) (result i32)
    local.get 0
    struct.get 49 6
  )
  (func (;34;) (type 75) (param eqref (ref 11) i32) (result (ref 51))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 50
    local.get 1
    ref.cast (ref 11)
    local.get 2
    call 12
    struct.new 51
    ref.cast (ref 51)
  )
  (func (;35;) (type 76) (param eqref (ref 11)) (result (ref 51))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 50
    local.get 1
    ref.cast (ref 11)
    call 13
    struct.new 51
    ref.cast (ref 51)
  )
  (func (;36;) (type 77) (param (ref 51) eqref i32)
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 1
    local.get 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 49
    call 14
  )
  (func (;37;) (type 78) (param (ref 51)) (result (ref 0))
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 15
    ref.cast (ref 0)
  )
  (func (;38;) (type 79) (param (ref 49)) (result eqref)
    local.get 0
    struct.get 49 5
  )
  (func (;39;) (type 80) (param (ref 51)) (result (ref 52))
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 16
    struct.new 52
    ref.cast (ref 52)
  )
  (func (;40;) (type 81) (param (ref 52)) (result (ref 49))
    local.get 0
    struct.get 52 0
    ref.cast (ref 10)
    call 17
    ref.cast (ref 49)
  )
  (func (;41;) (type 82) (param (ref 51)) (result i32)
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 18
  )
  (func (;42;) (type 83) (param (ref 51))
    local.get 0
    struct.get 51 0
    ref.cast (ref 12)
    call 19
  )
  (func (;43;) (type 84) (param (ref 50) (ref 49) (ref 49)) (result (ref 2))
    local.get 0
    struct.get 50 5
    ref.cast (ref 3)
    local.get 1
    struct.get 49 6
    local.get 2
    struct.get 49 6
    call 3
    ref.cast (ref 2)
  )
  (func (;44;) (type 85) (param (ref 50) (ref 49) (ref 49)) (result (ref 2))
    local.get 0
    struct.get 50 5
    ref.cast (ref 3)
    local.get 1
    struct.get 49 6
    local.get 2
    struct.get 49 6
    call 3
    ref.cast (ref 2)
  )
  (func (;45;) (type 87))
  (func (;46;) (type 88) (param (ref 51)) (result i32)
    (local eqref eqref i32)
    local.get 0
    ref.cast (ref 51)
    call 26
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 1)
        struct.get 1 6
        local.set 1
        local.get 1
        ref.cast (ref 49)
        call 27
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;47;) (type 89)
    (local eqref eqref i32 i32 eqref eqref eqref eqref eqref i32 i32 i32 eqref i32 eqref i32 eqref eqref i32)
    call 0
    i32.const 0
    struct.new 11
    call 28
    local.set 0
    local.get 0
    ref.cast (ref 51)
    call 29
    v128.const i32x4 0x2077656e 0x75657571 0x6d652065 0x00797470
    array.new_fixed 90 1
    i32.const 0
    i32.const 15
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 30
    local.set 12
    block ;; label = @1
      local.get 12
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 13
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 13
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 13
    v128.const i32x4 0x74706d65 0x65702079 0x00006b65 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 10
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 26
    local.set 14
    block ;; label = @1
      local.get 14
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 15
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 15
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 15
    v128.const i32x4 0x74706d65 0x65642079 0x75657571 0x00000065
    array.new_fixed 90 1
    i32.const 0
    i32.const 13
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    i32.const 50
    i32.const 5
    call 31
    local.get 0
    ref.cast (ref 51)
    i32.const 10
    i32.const 1
    call 31
    local.get 0
    ref.cast (ref 51)
    i32.const 30
    i32.const 3
    call 31
    local.get 0
    ref.cast (ref 51)
    i32.const 31
    i32.const 3
    call 31
    local.get 0
    ref.cast (ref 51)
    i32.const 20
    i32.const 2
    call 31
    local.get 0
    ref.cast (ref 51)
    call 32
    i32.const 5
    i32.eq
    v128.const i32x4 0x61696c61 0x756d2073 0x69746174 0x00006e6f
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 30
    local.set 16
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 16
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x6b656570 0x73696d20 0x676e6973 0x00000000
          array.new_fixed 90 1
          i32.const 0
          i32.const 12
          struct.new 91
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 16
        ref.cast (ref 1)
        struct.get 1 6
        local.set 1
        local.get 1
        ref.cast (ref 49)
        call 27
        i32.const 10
        i32.eq
        v128.const i32x4 0x6b656570 0x6c617620 0x00006575 0x00000000
        array.new_fixed 90 1
        i32.const 0
        i32.const 10
        struct.new 91
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        local.get 1
        ref.cast (ref 49)
        call 33
        i32.const 1
        i32.eq
        v128.const i32x4 0x6b656570 0x69727020 0x7469726f 0x00000079
        array.new_fixed 90 1
        i32.const 0
        i32.const 13
        struct.new 91
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 32
    i32.const 5
    i32.eq
    v128.const i32x4 0x6b656570 0x6e6f6e20 0x74756d2d 0x6e697461
    v128.const i32x4 0x00000067 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 17
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 46
    i32.const 10
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x73726966 0x00000074
    array.new_fixed 90 1
    i32.const 0
    i32.const 13
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 46
    i32.const 20
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x6f636573 0x0000646e
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 46
    local.set 2
    local.get 0
    ref.cast (ref 51)
    call 46
    local.set 3
    local.get 2
    i32.const 30
    i32.eq
    if (result i32) ;; label = @1
      local.get 3
      i32.const 31
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      i32.const 31
      i32.eq
      if (result i32) ;; label = @2
        local.get 3
        i32.const 30
        i32.eq
      else
        i32.const 0
      end
    end
    v128.const i32x4 0x61757165 0x7270206c 0x69726f69 0x73656974
    v128.const i32x4 0x746f6220 0x65722068 0x6e696174 0x00006465
    array.new_fixed 90 2
    i32.const 0
    i32.const 30
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 51)
    call 46
    i32.const 50
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x7473616c 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    i32.const 1
    struct.new 11
    i32.const 2
    call 34
    local.set 4
    local.get 4
    ref.cast (ref 51)
    i32.const 1
    i32.const 1
    call 31
    local.get 4
    ref.cast (ref 51)
    i32.const 9
    i32.const 9
    call 31
    local.get 4
    ref.cast (ref 51)
    i32.const 4
    i32.const 4
    call 31
    local.get 4
    ref.cast (ref 51)
    call 46
    i32.const 9
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x73726966 0x00000074
    array.new_fixed 90 1
    i32.const 0
    i32.const 13
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 51)
    call 46
    i32.const 4
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x6f636573 0x0000646e
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 51)
    call 46
    i32.const 1
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x7473616c 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    i32.const 0
    struct.new 11
    call 35
    local.set 5
    local.get 5
    ref.cast (ref 51)
    i32.const 2
    struct.new 86
    i32.const 2
    call 36
    local.get 5
    ref.cast (ref 51)
    i32.const 1
    struct.new 86
    i32.const 1
    call 36
    local.get 5
    ref.cast (ref 51)
    call 37
    local.set 17
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 17
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x20626f6a 0x7373696d 0x00676e69 0x00000000
          array.new_fixed 90 1
          i32.const 0
          i32.const 11
          struct.new 91
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 17
        ref.cast (ref 1)
        struct.get 1 6
        local.set 6
        local.get 6
        ref.cast (ref 49)
        call 38
        ref.cast (ref 86)
        struct.get 86 0
        i32.const 1
        i32.eq
        v128.const i32x4 0x65666572 0x636e6572 0x61762065 0x0065756c
        array.new_fixed 90 1
        i32.const 0
        i32.const 15
        struct.new 91
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    call 0
    i32.const 0
    struct.new 11
    call 28
    local.set 7
    local.get 7
    ref.cast (ref 51)
    i32.const 4
    i32.const 4
    call 31
    local.get 7
    ref.cast (ref 51)
    i32.const 1
    i32.const 1
    call 31
    local.get 7
    ref.cast (ref 51)
    i32.const 3
    i32.const 3
    call 31
    local.get 7
    ref.cast (ref 51)
    call 39
    local.set 8
    i32.const 0
    local.set 9
    i32.const 0
    local.set 18
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 18
            local.set 10
            local.get 10
            local.get 7
            ref.cast (ref 51)
            call 32
            i32.lt_u
            if ;; label = @5
              local.get 9
              local.get 8
              ref.cast (ref 52)
              call 40
              call 27
              i32.add
              local.set 9
              local.get 10
              i32.const 1
              i32.add
              local.set 18
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 45
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    i32.const 8
    i32.eq
    v128.const i32x4 0x6f79616c 0x69207475 0x61726574 0x00726f74
    array.new_fixed 90 1
    i32.const 0
    i32.const 15
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 51)
    call 41
    local.set 11
    local.get 7
    ref.cast (ref 51)
    call 42
    local.get 7
    ref.cast (ref 51)
    call 29
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 11
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 51)
    call 41
    local.get 11
    i32.eq
    v128.const i32x4 0x61656c63 0x61632072 0x69636170 0x00007974
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
