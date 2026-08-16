(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;10;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field eqref) (field (mut i32))))
  (type (;12;) (sub (struct (field funcref))))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (func (param eqref i32) (result eqref)))
  (type (;15;) (func (param eqref) (result (ref 10))))
  (type (;16;) (func (param eqref eqref) (result eqref)))
  (type (;17;) (func (param eqref)))
  (type (;18;) (func (param eqref i32)))
  (type (;19;) (func (param eqref) (result i32)))
  (type (;20;) (func (param eqref i32) (result i32)))
  (type (;21;) (func (param eqref eqref i32) (result eqref)))
  (type (;22;) (func (param eqref eqref) (result (ref 10))))
  (type (;23;) (func (param eqref eqref eqref) (result eqref)))
  (type (;24;) (func (param eqref eqref)))
  (type (;25;) (func (param eqref eqref i32)))
  (type (;26;) (func (param eqref eqref) (result i32)))
  (type (;27;) (func (param eqref eqref i32) (result i32)))
  (type (;28;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;29;) (sub (struct (field i32))))
  (type (;30;) (struct))
  (type (;31;) (func (result (ref 30))))
  (type (;32;) (func (param (ref 30) eqref eqref) (result (ref 29))))
  (type (;33;) (func (param (ref 29)) (result i32)))
  (type (;34;) (func (param (ref 29)) (result i32)))
  (type (;35;) (func (param (ref 30) i32 i32) (result (ref 29))))
  (type (;36;) (sub (struct (field i32))))
  (type (;37;) (struct (field (ref 10)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32)))
  (type (;38;) (func (param (ref 36)) (result i32)))
  (type (;39;) (func (param eqref (ref 36)) (result (ref 37))))
  (type (;40;) (func (param eqref (ref 36) i32) (result (ref 37))))
  (type (;41;) (func (param (ref 37)) (result i32)))
  (type (;42;) (func (param (ref 37)) (result i32)))
  (type (;43;) (func (param (ref 37)) (result i32)))
  (type (;44;) (func (param (ref 37) eqref eqref) (result i32)))
  (type (;45;) (func))
  (type (;46;) (func (param (ref 37) i32)))
  (type (;47;) (func (param (ref 37) i32)))
  (type (;48;) (func (param (ref 37) eqref)))
  (type (;49;) (func (param (ref 37)) (result (ref 8))))
  (type (;50;) (func (param (ref 37)) (result (ref 8))))
  (type (;51;) (func (param (ref 37))))
  (type (;52;) (func (param (ref 37)) (result (ref 11))))
  (type (;53;) (func (param (ref 11)) (result eqref)))
  (type (;54;) (func (param eqref (ref 36) (ref 10)) (result (ref 37))))
  (type (;55;) (func (param (ref 37)) (result (ref 8))))
  (type (;56;) (func (param eqref (ref 36)) (result (ref 37))))
  (type (;57;) (func (param (ref 37)) (result i32)))
  (type (;58;) (func (param (ref 37)) (result i32)))
  (type (;59;) (func (param (ref 37)) (result (ref 8))))
  (type (;60;) (func (param (ref 37) i32)))
  (type (;61;) (func (param (ref 37)) (result i32)))
  (type (;62;) (func (param eqref (ref 36) i32) (result (ref 37))))
  (type (;63;) (func (param eqref (ref 36) (ref 10)) (result (ref 37))))
  (type (;64;) (func (param eqref (ref 36)) (result (ref 37))))
  (type (;65;) (func (param (ref 37) i32)))
  (type (;66;) (func (param (ref 37)) (result (ref 8))))
  (type (;67;) (func (param eqref (ref 36)) (result (ref 37))))
  (type (;68;) (func (param (ref 37) eqref)))
  (type (;69;) (func (param (ref 37)) (result (ref 8))))
  (type (;70;) (func (param (ref 37)) (result (ref 11))))
  (type (;71;) (func (param (ref 11)) (result i32)))
  (type (;72;) (func (param (ref 37))))
  (type (;73;) (func (param (ref 37) i32)))
  (type (;74;) (func (param (ref 37) i32)))
  (type (;75;) (func (param (ref 37) i32)))
  (type (;76;) (func (param (ref 37) i32)))
  (type (;77;) (func (param (ref 37) i32)))
  (type (;78;) (func (param (ref 37) i32)))
  (type (;79;) (func (param (ref 37) i32 i32) (result i32)))
  (type (;80;) (func (param (ref 37) i32 i32) (result i32)))
  (type (;81;) (func (param (ref 37) eqref eqref) (result i32)))
  (type (;82;) (struct))
  (type (;83;) (struct (field i32) (field i32)))
  (type (;84;) (struct))
  (type (;85;) (func (param (ref 82) i32 i32) (result (ref 29))))
  (type (;86;) (func (param (ref 84) (ref 83) (ref 83)) (result (ref 29))))
  (type (;87;) (func))
  (type (;88;) (func (param (ref 37)) (result i32)))
  (type (;89;) (func))
  (type (;90;) (array (mut v128)))
  (type (;91;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;92;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;93;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;94;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (type (;95;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 37))
  (func (;0;) (type 31) (result (ref 30))
    struct.new 30
    ref.cast (ref 30)
  )
  (func (;1;) (type 33) (param (ref 29)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 29)
              struct.get 29 0
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
  (func (;2;) (type 34) (param (ref 29)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 29)
              struct.get 29 0
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
  (func (;3;) (type 35) (param (ref 30) i32 i32) (result (ref 29))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 29
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 29
      else
        i32.const 2
        struct.new 29
      end
    end
    ref.cast (ref 29)
  )
  (func (;4;) (type 38) (param (ref 36)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 36)
            struct.get 36 0
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
  (func (;5;) (type 45))
  (func (;6;) (type 55) (param (ref 37)) (result (ref 8))
    (local i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      struct.get 37 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 2
      local.get 0
      struct.get 37 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 3
      local.get 0
      struct.get 37 0
      local.set 4
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 8
      else
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 5
        array.get 0
        local.set 7
        local.get 4
        ref.cast (ref 10)
        local.get 5
        struct.set 10 1
        i32.const 1
        local.get 7
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 9
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        struct.get 37 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 5
        local.get 8
        array.set 0
        local.get 0
        ref.cast (ref 37)
        i32.const 0
        call 24
      else
        call 5
      end
      i32.const 1
      local.get 2
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;7;) (type 56) (param eqref (ref 36)) (result (ref 37))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 36)
    call 4
    struct.new 37
    ref.cast (ref 37)
  )
  (func (;8;) (type 57) (param (ref 37)) (result i32)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 0
    i32.eq
  )
  (func (;9;) (type 58) (param (ref 37)) (result i32)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 2
  )
  (func (;10;) (type 59) (param (ref 37)) (result (ref 8))
    (local eqref i32 eqref)
    local.get 0
    struct.get 37 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 1
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      array.get 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    ref.cast (ref 8)
    ref.cast (ref 8)
  )
  (func (;11;) (type 60) (param (ref 37) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 37 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 10)
      local.get 4
      struct.set 10 0
      local.get 2
      ref.cast (ref 10)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 10)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 0
    ref.cast (ref 37)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.sub
    call 25
  )
  (func (;12;) (type 61) (param (ref 37)) (result i32)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
  )
  (func (;13;) (type 62) (param eqref (ref 36) i32) (result (ref 37))
    (local eqref i32 eqref)
    local.get 2
    local.set 4
    local.get 4
    array.new_default 0
    i32.const 0
    local.get 4
    struct.new 10
    ref.cast (ref 10)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 36)
    call 4
    struct.new 37
    ref.cast (ref 37)
  )
  (func (;14;) (type 63) (param eqref (ref 36) (ref 10)) (result (ref 37))
    (local i32 (ref 37) i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.set 3
    local.get 0
    local.get 1
    ref.cast (ref 36)
    local.get 3
    call 13
    local.set 4
    i32.const 0
    local.set 13
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 13
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 4
              struct.get 37 0
              local.get 2
              local.get 5
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 10
              array.get 0
              local.set 12
              local.set 9
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              local.get 9
              ref.cast (ref 10)
              struct.get 10 2
              i32.eq
              if ;; label = @6
                local.get 9
                ref.cast (ref 10)
                struct.get 10 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 9
                  ref.cast (ref 10)
                  struct.get 10 2
                  i32.const 2
                  i32.mul
                end
                local.set 10
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 2
                i32.le_u
                if ;; label = @7
                  unreachable
                end
                local.get 10
                array.new_default 0
                local.set 11
                local.get 11
                ref.cast (ref 0)
                i32.const 0
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                i32.const 0
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                array.copy 0 0
                local.get 9
                ref.cast (ref 10)
                local.get 11
                struct.set 10 0
                local.get 9
                ref.cast (ref 10)
                local.get 11
                ref.cast (ref 0)
                array.len
                struct.set 10 2
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              local.get 12
              array.set 0
              local.get 9
              ref.cast (ref 10)
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.const 1
              i32.add
              struct.set 10 1
              local.get 5
              i32.const 1
              i32.add
              local.set 13
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 3
    i32.const 1
    i32.gt_u
    if ;; label = @1
      local.get 3
      i32.const 2
      i32.div_u
      local.set 6
      local.get 6
      local.set 14
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 14
            i32.const 0
            i32.eq
            if ;; label = @5
              call 5
              br 3 (;@2;)
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              local.get 14
              local.set 7
              local.get 7
              i32.const 1
              i32.sub
              local.set 8
              local.get 4
              ref.cast (ref 37)
              local.get 8
              call 24
              local.get 8
              local.set 14
              br 2 (;@3;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
    else
      call 5
    end
    local.get 4
    ref.cast (ref 37)
  )
  (func (;15;) (type 64) (param eqref (ref 36)) (result (ref 37))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 36)
    call 4
    struct.new 37
    ref.cast (ref 37)
  )
  (func (;16;) (type 65) (param (ref 37) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 37 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 10)
      local.get 4
      struct.set 10 0
      local.get 2
      ref.cast (ref 10)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 10)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 0
    ref.cast (ref 37)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.sub
    call 26
  )
  (func (;17;) (type 66) (param (ref 37)) (result (ref 8))
    (local i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      struct.get 37 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 2
      local.get 0
      struct.get 37 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 3
      local.get 0
      struct.get 37 0
      local.set 4
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 8
      else
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 5
        array.get 0
        local.set 7
        local.get 4
        ref.cast (ref 10)
        local.get 5
        struct.set 10 1
        i32.const 1
        local.get 7
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 9
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        struct.get 37 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 5
        local.get 8
        array.set 0
        local.get 0
        ref.cast (ref 37)
        i32.const 0
        call 27
      else
        call 5
      end
      i32.const 1
      local.get 2
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;18;) (type 67) (param eqref (ref 36)) (result (ref 37))
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 36)
    call 4
    struct.new 37
    ref.cast (ref 37)
  )
  (func (;19;) (type 68) (param (ref 37) eqref)
    (local eqref i32 eqref eqref)
    local.get 0
    struct.get 37 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 5
      local.set 4
      local.get 4
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 5 5
      local.get 2
      ref.cast (ref 10)
      local.get 4
      struct.set 10 0
      local.get 2
      ref.cast (ref 10)
      local.get 4
      ref.cast (ref 5)
      array.len
      struct.set 10 2
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 5)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 5
    array.set 5
    local.get 2
    ref.cast (ref 10)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 0
    ref.cast (ref 37)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.sub
    call 28
  )
  (func (;20;) (type 69) (param (ref 37)) (result (ref 8))
    (local i32 eqref eqref eqref i32 eqref eqref eqref)
    local.get 0
    struct.get 37 0
    ref.cast (ref 10)
    struct.get 10 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      struct.get 37 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 2
      local.get 0
      struct.get 37 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 3
      local.get 0
      struct.get 37 0
      local.set 4
      local.get 4
      ref.cast (ref 10)
      struct.get 10 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 8
      else
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 5)
        local.get 5
        array.get 5
        local.set 7
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 5)
        local.get 5
        ref.null eq
        array.set 5
        local.get 4
        ref.cast (ref 10)
        local.get 5
        struct.set 10 1
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 7
        struct.new 9
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        struct.get 37 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 10)
        struct.get 10 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 5)
        local.get 5
        local.get 8
        array.set 5
        local.get 0
        ref.cast (ref 37)
        i32.const 0
        call 29
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
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;21;) (type 70) (param (ref 37)) (result (ref 11))
    local.get 0
    struct.get 37 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;22;) (type 71) (param (ref 11)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    local.get 1
    ref.cast (ref 11)
    local.get 2
    i32.const 1
    i32.add
    struct.set 11 1
  )
  (func (;23;) (type 72) (param (ref 37))
    (local eqref i32 eqref)
    local.get 0
    struct.get 37 0
    local.set 1
    local.get 1
    ref.cast (ref 10)
    i32.const 0
    struct.set 10 1
  )
  (func (;24;) (type 73) (param (ref 37) i32)
    (local i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
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
            struct.get 37 0
            ref.cast (ref 10)
            struct.get 10 1
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
                ref.cast (ref 37)
                local.get 0
                struct.get 37 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                array.get 0
                local.get 0
                struct.get 37 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                array.get 0
                call 30
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
              struct.get 37 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 10
              array.get 0
              local.set 7
              local.get 0
              struct.get 37 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 10
              array.get 0
              local.set 8
              local.get 0
              ref.cast (ref 37)
              local.get 8
              local.get 7
              call 30
              if ;; label = @6
                local.get 0
                struct.get 37 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                local.get 12
                array.set 0
                local.get 0
                struct.get 37 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                local.get 13
                array.set 0
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
  (func (;25;) (type 74) (param (ref 37) i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
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
            struct.get 37 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 7
            array.get 0
            local.set 4
            local.get 0
            struct.get 37 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 7
            array.get 0
            local.set 5
            local.get 0
            ref.cast (ref 37)
            local.get 4
            local.get 5
            call 30
            if ;; label = @5
              local.get 0
              struct.get 37 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 7
              local.get 9
              array.set 0
              local.get 0
              struct.get 37 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 7
              local.get 10
              array.set 0
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
  (func (;26;) (type 75) (param (ref 37) i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
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
            struct.get 37 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 7
            array.get 0
            local.set 4
            local.get 0
            struct.get 37 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 7
            array.get 0
            local.set 5
            local.get 0
            ref.cast (ref 37)
            local.get 4
            local.get 5
            call 31
            if ;; label = @5
              local.get 0
              struct.get 37 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 7
              local.get 9
              array.set 0
              local.get 0
              struct.get 37 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 7
              local.get 10
              array.set 0
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
  (func (;27;) (type 76) (param (ref 37) i32)
    (local i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
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
            struct.get 37 0
            ref.cast (ref 10)
            struct.get 10 1
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
                ref.cast (ref 37)
                local.get 0
                struct.get 37 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                array.get 0
                local.get 0
                struct.get 37 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                array.get 0
                call 31
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
              struct.get 37 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 10
              array.get 0
              local.set 7
              local.get 0
              struct.get 37 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 0)
              local.get 10
              array.get 0
              local.set 8
              local.get 0
              ref.cast (ref 37)
              local.get 8
              local.get 7
              call 31
              if ;; label = @6
                local.get 0
                struct.get 37 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                local.get 12
                array.set 0
                local.get 0
                struct.get 37 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 0)
                local.get 10
                local.get 13
                array.set 0
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
  (func (;28;) (type 77) (param (ref 37) i32)
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
            struct.get 37 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 4
            local.get 0
            struct.get 37 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 5
            local.get 0
            ref.cast (ref 37)
            local.get 4
            local.get 5
            call 32
            if ;; label = @5
              local.get 0
              struct.get 37 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 5)
              local.get 7
              local.get 9
              array.set 5
              local.get 0
              struct.get 37 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 5)
              local.get 7
              local.get 10
              array.set 5
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
  (func (;29;) (type 78) (param (ref 37) i32)
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
            struct.get 37 0
            ref.cast (ref 10)
            struct.get 10 1
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
                ref.cast (ref 37)
                local.get 0
                struct.get 37 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
                local.get 0
                struct.get 37 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
                call 32
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
              struct.get 37 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 7
              local.get 0
              struct.get 37 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 8
              local.get 0
              ref.cast (ref 37)
              local.get 8
              local.get 7
              call 32
              if ;; label = @6
                local.get 0
                struct.get 37 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 5)
                local.get 10
                local.get 12
                array.set 5
                local.get 0
                struct.get 37 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 10)
                struct.get 10 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 10)
                struct.get 10 0
                ref.cast (ref 5)
                local.get 10
                local.get 13
                array.set 5
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
  (func (;30;) (type 79) (param (ref 37) i32 i32) (result i32)
    (local eqref)
    local.get 0
    struct.get 37 6
    ref.cast (ref 30)
    local.get 1
    local.get 2
    call 3
    local.set 3
    local.get 0
    struct.get 37 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 29)
      call 2
    else
      local.get 3
      ref.cast (ref 29)
      call 1
    end
  )
  (func (;31;) (type 80) (param (ref 37) i32 i32) (result i32)
    (local eqref)
    local.get 0
    struct.get 37 6
    ref.cast (ref 82)
    local.get 1
    local.get 2
    call 33
    local.set 3
    local.get 0
    struct.get 37 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 29)
      call 2
    else
      local.get 3
      ref.cast (ref 29)
      call 1
    end
  )
  (func (;32;) (type 81) (param (ref 37) eqref eqref) (result i32)
    (local eqref)
    local.get 0
    struct.get 37 6
    ref.cast (ref 84)
    local.get 1
    ref.cast (ref 83)
    local.get 2
    ref.cast (ref 83)
    call 34
    local.set 3
    local.get 0
    struct.get 37 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 29)
      call 2
    else
      local.get 3
      ref.cast (ref 29)
      call 1
    end
  )
  (func (;33;) (type 85) (param (ref 82) i32 i32) (result (ref 29))
    (local i32 i32)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
      local.get 1
      i32.sub
    else
      local.get 1
    end
    local.set 3
    local.get 2
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
      local.get 2
      i32.sub
    else
      local.get 2
    end
    local.set 4
    local.get 3
    local.get 4
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 29
    else
      local.get 3
      local.get 4
      i32.gt_s
      if (result eqref) ;; label = @2
        i32.const 2
        struct.new 29
      else
        call 0
        local.get 1
        local.get 2
        call 3
      end
    end
    ref.cast (ref 29)
  )
  (func (;34;) (type 86) (param (ref 84) (ref 83) (ref 83)) (result (ref 29))
    call 0
    local.get 1
    struct.get 83 0
    local.get 2
    struct.get 83 0
    call 3
    ref.cast (ref 29)
  )
  (func (;35;) (type 87))
  (func (;36;) (type 88) (param (ref 37)) (result i32)
    (local i32 eqref i32)
    local.get 0
    ref.cast (ref 37)
    call 6
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -999
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;37;) (type 89)
    (local eqref eqref i32 eqref eqref eqref eqref i32 eqref (ref 83) eqref eqref i32 i32 i32 eqref i32 eqref i32 eqref eqref i32 eqref i32 i32 i32 i32 i32 eqref eqref i32)
    call 0
    i32.const 0
    struct.new 36
    call 7
    local.set 0
    local.get 0
    ref.cast (ref 37)
    call 8
    v128.const i32x4 0x2077656e 0x70616568 0x706d6520 0x00007974
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
    ref.cast (ref 37)
    call 9
    i32.const 0
    i32.eq
    v128.const i32x4 0x6f72657a 0x696e6920 0x6c616974 0x70616320
    v128.const i32x4 0x74696361 0x00000079 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 21
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 10
    local.set 15
    block ;; label = @1
      local.get 15
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 16
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 16
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 16
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
    ref.cast (ref 37)
    call 6
    local.set 17
    block ;; label = @1
      local.get 17
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 18
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 18
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 18
    v128.const i32x4 0x74706d65 0x6f702079 0x00000070 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    i32.const 5
    call 11
    local.get 0
    ref.cast (ref 37)
    i32.const 1
    call 11
    local.get 0
    ref.cast (ref 37)
    i32.const 3
    call 11
    local.get 0
    ref.cast (ref 37)
    i32.const 1
    call 11
    local.get 0
    ref.cast (ref 37)
    i32.const 8
    call 11
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 37)
    i32.const 2
    call 11
    local.get 0
    ref.cast (ref 37)
    call 12
    i32.const 6
    i32.eq
    v128.const i32x4 0x61696c61 0x756d2073 0x69746174 0x76206e6f
    v128.const i32x4 0x62697369 0x0000656c 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 22
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 10
    local.set 19
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 19
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x696e696d 0x206d756d 0x7373696d 0x00676e69
          array.new_fixed 90 1
          i32.const 0
          i32.const 15
          struct.new 91
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 19
        ref.cast (ref 9)
        struct.get 9 1
        local.set 2
        local.get 2
        i32.const 1
        i32.eq
        v128.const i32x4 0x696e696d 0x206d756d 0x6b656570 0x00000000
        array.new_fixed 90 1
        i32.const 0
        i32.const 12
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
    ref.cast (ref 37)
    call 36
    i32.const 1
    i32.eq
    v128.const i32x4 0x206e696d 0x73726966 0x00000074 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 36
    i32.const 1
    i32.eq
    v128.const i32x4 0x206e696d 0x6c707564 0x74616369 0x00000065
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
    ref.cast (ref 37)
    call 36
    i32.const 2
    i32.eq
    v128.const i32x4 0x206e696d 0x6f636573 0x0000646e 0x00000000
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
    ref.cast (ref 37)
    call 36
    i32.const 3
    i32.eq
    v128.const i32x4 0x206e696d 0x72696874 0x00000064 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 36
    i32.const 5
    i32.eq
    v128.const i32x4 0x206e696d 0x74666966 0x00000068 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 36
    i32.const 8
    i32.eq
    v128.const i32x4 0x206e696d 0x7473616c 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 8
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 37)
    call 8
    v128.const i32x4 0x696e696d 0x206d756d 0x69617264 0x0064656e
    array.new_fixed 90 1
    i32.const 0
    i32.const 15
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    i32.const 1
    struct.new 36
    i32.const 2
    call 13
    local.set 3
    local.get 3
    ref.cast (ref 37)
    i32.const 4
    call 11
    local.get 3
    ref.cast (ref 37)
    i32.const 9
    call 11
    local.get 3
    ref.cast (ref 37)
    i32.const 2
    call 11
    local.get 3
    ref.cast (ref 37)
    i32.const 7
    call 11
    local.get 3
    ref.cast (ref 37)
    call 36
    i32.const 9
    i32.eq
    v128.const i32x4 0x2078616d 0x73726966 0x00000074 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 37)
    call 36
    i32.const 7
    i32.eq
    v128.const i32x4 0x2078616d 0x6f636573 0x0000646e 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 10
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 37)
    call 36
    i32.const 4
    i32.eq
    v128.const i32x4 0x2078616d 0x72696874 0x00000064 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 37)
    call 36
    i32.const 2
    i32.eq
    v128.const i32x4 0x2078616d 0x7473616c 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 8
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 10
    local.set 4
    local.get 4
    i32.const 6
    local.set 23
    local.set 20
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 20
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 20
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 21
      local.get 21
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 21
      array.new_default 0
      local.set 22
      local.get 22
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      struct.set 10 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 20
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 23
    array.set 0
    local.get 20
    ref.cast (ref 10)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 4
    i32.const 2
    local.set 24
    local.set 20
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 20
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 20
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 21
      local.get 21
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 21
      array.new_default 0
      local.set 22
      local.get 22
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      struct.set 10 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 20
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 24
    array.set 0
    local.get 20
    ref.cast (ref 10)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 4
    i32.const 7
    local.set 25
    local.set 20
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 20
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 20
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 21
      local.get 21
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 21
      array.new_default 0
      local.set 22
      local.get 22
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      struct.set 10 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 20
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 25
    array.set 0
    local.get 20
    ref.cast (ref 10)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 4
    i32.const 1
    local.set 26
    local.set 20
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 20
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 20
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 21
      local.get 21
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 21
      array.new_default 0
      local.set 22
      local.get 22
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      struct.set 10 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 20
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 26
    array.set 0
    local.get 20
    ref.cast (ref 10)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    local.get 4
    i32.const 5
    local.set 27
    local.set 20
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 20
    ref.cast (ref 10)
    struct.get 10 2
    i32.eq
    if ;; label = @1
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 20
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2
        i32.mul
      end
      local.set 21
      local.get 21
      local.get 20
      ref.cast (ref 10)
      struct.get 10 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 21
      array.new_default 0
      local.set 22
      local.get 22
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      i32.const 0
      local.get 20
      ref.cast (ref 10)
      struct.get 10 1
      array.copy 0 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      struct.set 10 0
      local.get 20
      ref.cast (ref 10)
      local.get 22
      ref.cast (ref 0)
      array.len
      struct.set 10 2
    end
    local.get 20
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    local.get 27
    array.set 0
    local.get 20
    ref.cast (ref 10)
    local.get 20
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 1
    i32.add
    struct.set 10 1
    call 0
    i32.const 0
    struct.new 36
    local.get 4
    ref.cast (ref 10)
    call 14
    local.set 5
    local.get 4
    ref.cast (ref 10)
    struct.get 10 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x70616568 0x20796669 0x69706f63 0x73207365
    v128.const i32x4 0x6372756f 0x00000065 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 21
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 37)
    call 36
    i32.const 1
    i32.eq
    v128.const i32x4 0x796f6c46 0x69662064 0x00747372 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 11
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 37)
    call 36
    i32.const 2
    i32.eq
    v128.const i32x4 0x796f6c46 0x65732064 0x646e6f63 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 37)
    call 36
    i32.const 5
    i32.eq
    v128.const i32x4 0x796f6c46 0x68742064 0x00647269 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 11
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 37)
    call 36
    i32.const 6
    i32.eq
    v128.const i32x4 0x796f6c46 0x6f662064 0x68747275 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 37)
    call 36
    i32.const 7
    i32.eq
    v128.const i32x4 0x796f6c46 0x69662064 0x00687466 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 11
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    struct.new 82
    i32.const 0
    struct.new 36
    call 15
    local.set 6
    local.get 6
    ref.cast (ref 37)
    i32.const -9
    call 16
    local.get 6
    ref.cast (ref 37)
    i32.const 2
    call 16
    local.get 6
    ref.cast (ref 37)
    i32.const -1
    call 16
    local.get 6
    ref.cast (ref 37)
    call 17
    local.set 28
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 28
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x74737563 0x63206d6f 0x61706d6f 0x6f746172
          v128.const i32x4 0x696d2072 0x6e697373 0x00000067 0x00000000
          array.new_fixed 90 2
          i32.const 0
          i32.const 25
          struct.new 91
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 28
        ref.cast (ref 9)
        struct.get 9 1
        local.set 7
        local.get 7
        i32.const -1
        i32.eq
        v128.const i32x4 0x74737563 0x63206d6f 0x61706d6f 0x6f746172
        v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
        array.new_fixed 90 2
        i32.const 0
        i32.const 17
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
    struct.new 84
    i32.const 0
    struct.new 36
    call 18
    local.set 8
    local.get 8
    ref.cast (ref 37)
    i32.const 3
    i32.const 30
    struct.new 83
    call 19
    local.get 8
    ref.cast (ref 37)
    i32.const 1
    i32.const 10
    struct.new 83
    call 19
    local.get 8
    ref.cast (ref 37)
    i32.const 2
    i32.const 20
    struct.new 83
    call 19
    local.get 8
    ref.cast (ref 37)
    call 20
    local.set 29
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 29
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x72746e65 0x696d2079 0x6e697373 0x00000067
          array.new_fixed 90 1
          i32.const 0
          i32.const 13
          struct.new 91
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 29
        ref.cast (ref 9)
        struct.get 9 6
        ref.cast (ref 83)
        local.set 9
        local.get 9
        ref.cast (ref 83)
        struct.get 83 1
        i32.const 10
        i32.eq
        v128.const i32x4 0x65666572 0x636e6572 0x61632065 0x65697272
        v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
        array.new_fixed 90 2
        i32.const 0
        i32.const 17
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
    struct.new 36
    call 7
    local.set 10
    local.get 10
    ref.cast (ref 37)
    i32.const 4
    call 11
    local.get 10
    ref.cast (ref 37)
    i32.const 1
    call 11
    local.get 10
    ref.cast (ref 37)
    i32.const 3
    call 11
    local.get 10
    ref.cast (ref 37)
    call 21
    local.set 11
    i32.const 0
    local.set 12
    i32.const 0
    local.set 30
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 30
            local.set 13
            local.get 13
            local.get 10
            ref.cast (ref 37)
            call 12
            i32.lt_u
            if ;; label = @5
              local.get 12
              local.get 11
              ref.cast (ref 11)
              call 22
              i32.add
              local.set 12
              local.get 13
              i32.const 1
              i32.add
              local.set 30
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 35
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 12
    i32.const 8
    i32.eq
    v128.const i32x4 0x6f79616c 0x69207475 0x61726574 0x20726f74
    v128.const i32x4 0x6c656979 0x65207364 0x79726576 0x656c6520
    v128.const i32x4 0x746e656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 3
    i32.const 0
    i32.const 36
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 37)
    call 9
    local.set 14
    local.get 10
    ref.cast (ref 37)
    call 23
    local.get 10
    ref.cast (ref 37)
    call 8
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
    local.get 10
    ref.cast (ref 37)
    call 9
    local.get 14
    i32.eq
    v128.const i32x4 0x61656c63 0x72702072 0x72657365 0x20736576
    v128.const i32x4 0x61706163 0x79746963 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 24
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
