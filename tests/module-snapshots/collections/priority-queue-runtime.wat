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
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (struct))
  (type (;13;) (func (result (ref 12))))
  (type (;14;) (func (param (ref 12) eqref eqref) (result (ref 11))))
  (type (;15;) (func (param (ref 11)) (result i32)))
  (type (;16;) (func (param (ref 11)) (result i32)))
  (type (;17;) (func (param (ref 12) i32 i32) (result (ref 11))))
  (type (;18;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;19;) (struct (field eqref) (field (mut i32))))
  (type (;20;) (sub (struct (field funcref))))
  (type (;21;) (func (param eqref) (result eqref)))
  (type (;22;) (func (param eqref i32) (result eqref)))
  (type (;23;) (func (param eqref) (result (ref 18))))
  (type (;24;) (func (param eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref)))
  (type (;26;) (func (param eqref i32)))
  (type (;27;) (func (param eqref) (result i32)))
  (type (;28;) (func (param eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref i32) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result (ref 18))))
  (type (;31;) (func (param eqref eqref eqref) (result eqref)))
  (type (;32;) (func (param eqref eqref)))
  (type (;33;) (func (param eqref eqref i32)))
  (type (;34;) (func (param eqref eqref) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result i32)))
  (type (;36;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;37;) (sub (struct (field i32))))
  (type (;38;) (struct (field (ref 18)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32)))
  (type (;39;) (func (param (ref 37)) (result i32)))
  (type (;40;) (func (param eqref (ref 37)) (result (ref 38))))
  (type (;41;) (func (param eqref (ref 37) i32) (result (ref 38))))
  (type (;42;) (func (param (ref 38)) (result i32)))
  (type (;43;) (func (param (ref 38)) (result i32)))
  (type (;44;) (func (param (ref 38)) (result i32)))
  (type (;45;) (func (param (ref 38) eqref eqref) (result i32)))
  (type (;46;) (func))
  (type (;47;) (func (param (ref 38) i32)))
  (type (;48;) (func (param (ref 38) i32)))
  (type (;49;) (func (param (ref 38) eqref)))
  (type (;50;) (func (param (ref 38)) (result (ref 8))))
  (type (;51;) (func (param (ref 38)) (result (ref 8))))
  (type (;52;) (func (param (ref 38))))
  (type (;53;) (func (param (ref 38)) (result (ref 19))))
  (type (;54;) (func (param (ref 19)) (result eqref)))
  (type (;55;) (func (param (ref 38)) (result (ref 8))))
  (type (;56;) (func (param eqref (ref 37)) (result (ref 38))))
  (type (;57;) (func (param (ref 38)) (result i32)))
  (type (;58;) (func (param (ref 38)) (result (ref 8))))
  (type (;59;) (func (param (ref 38) eqref)))
  (type (;60;) (func (param (ref 38)) (result i32)))
  (type (;61;) (func (param eqref (ref 37) i32) (result (ref 38))))
  (type (;62;) (func (param eqref (ref 37)) (result (ref 38))))
  (type (;63;) (func (param (ref 38) eqref)))
  (type (;64;) (func (param (ref 38)) (result (ref 8))))
  (type (;65;) (func (param (ref 38)) (result (ref 19))))
  (type (;66;) (func (param (ref 19)) (result eqref)))
  (type (;67;) (func (param (ref 38)) (result i32)))
  (type (;68;) (func (param (ref 38))))
  (type (;69;) (func (param (ref 38) i32)))
  (type (;70;) (func (param (ref 38) i32)))
  (type (;71;) (func (param (ref 38) i32)))
  (type (;72;) (func (param (ref 38) i32)))
  (type (;73;) (func (param (ref 38) eqref eqref) (result i32)))
  (type (;74;) (func (param (ref 38) eqref eqref) (result i32)))
  (type (;75;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;76;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;77;) (struct (field (ref 38))))
  (type (;78;) (struct (field (ref 19))))
  (type (;79;) (func (param (ref 76) (ref 75) (ref 75)) (result (ref 11))))
  (type (;80;) (func (param eqref (ref 37)) (result (ref 77))))
  (type (;81;) (func (param eqref (ref 37) i32) (result (ref 77))))
  (type (;82;) (func (param (ref 77)) (result i32)))
  (type (;83;) (func (param (ref 77)) (result i32)))
  (type (;84;) (func (param (ref 77)) (result i32)))
  (type (;85;) (func (param (ref 77) eqref eqref)))
  (type (;86;) (func (param (ref 77)) (result (ref 8))))
  (type (;87;) (func (param (ref 77)) (result (ref 8))))
  (type (;88;) (func (param (ref 77))))
  (type (;89;) (func (param (ref 75)) (result eqref)))
  (type (;90;) (func (param (ref 75)) (result eqref)))
  (type (;91;) (func (param (ref 77)) (result (ref 78))))
  (type (;92;) (func (param (ref 78)) (result (ref 75))))
  (type (;93;) (func (param (ref 77)) (result (ref 8))))
  (type (;94;) (func (param (ref 75)) (result i32)))
  (type (;95;) (func (param eqref (ref 37)) (result (ref 77))))
  (type (;96;) (func (param (ref 77)) (result i32)))
  (type (;97;) (func (param (ref 77)) (result (ref 8))))
  (type (;98;) (func (param (ref 77) i32 i32)))
  (type (;99;) (func (param (ref 77)) (result i32)))
  (type (;100;) (func (param (ref 75)) (result i32)))
  (type (;101;) (func (param eqref (ref 37) i32) (result (ref 77))))
  (type (;102;) (func (param eqref (ref 37)) (result (ref 77))))
  (type (;103;) (func (param (ref 77) eqref i32)))
  (type (;104;) (func (param (ref 77)) (result (ref 8))))
  (type (;105;) (func (param (ref 75)) (result eqref)))
  (type (;106;) (func (param (ref 77)) (result (ref 78))))
  (type (;107;) (func (param (ref 78)) (result (ref 75))))
  (type (;108;) (func (param (ref 77)) (result i32)))
  (type (;109;) (func (param (ref 77))))
  (type (;110;) (func (param (ref 76) (ref 75) (ref 75)) (result (ref 11))))
  (type (;111;) (func (param (ref 76) (ref 75) (ref 75)) (result (ref 11))))
  (type (;112;) (struct (field i32)))
  (type (;113;) (func))
  (type (;114;) (func (param (ref 77)) (result i32)))
  (type (;115;) (func))
  (type (;116;) (array (mut v128)))
  (type (;117;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;118;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;119;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;120;) (struct (field (mut (ref 116))) (field (mut i32)) (field (mut i32))))
  (type (;121;) (struct (field (mut (ref 116))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 47))
  (func (;0;) (type 13) (result (ref 12))
    struct.new 12
    ref.cast (ref 12)
  )
  (func (;1;) (type 15) (param (ref 11)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 11)
              struct.get 11 0
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
  (func (;2;) (type 16) (param (ref 11)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 11)
              struct.get 11 0
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
  (func (;3;) (type 17) (param (ref 12) i32 i32) (result (ref 11))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 11
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 11
      else
        i32.const 2
        struct.new 11
      end
    end
    ref.cast (ref 11)
  )
  (func (;4;) (type 39) (param (ref 37)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 37)
            struct.get 37 0
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
  (func (;5;) (type 46))
  (func (;6;) (type 55) (param (ref 38)) (result (ref 8))
    (local i32 eqref eqref eqref i32 eqref eqref eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 2
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 3
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      local.set 4
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 8
      else
        local.get 4
        ref.cast (ref 18)
        struct.get 18 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        array.get 5
        local.set 7
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        ref.null eq
        array.set 5
        local.get 4
        ref.cast (ref 18)
        local.get 5
        struct.set 18 1
        i32.const 1
        local.get 7
        struct.new 10
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        ref.cast (ref 38)
        struct.get 38 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 18)
        struct.get 18 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        local.get 8
        array.set 5
        local.get 0
        ref.cast (ref 38)
        i32.const 0
        call 20
      else
        call 5
      end
      i32.const 1
      local.get 2
      struct.new 10
    end
    ref.cast (ref 8)
  )
  (func (;7;) (type 56) (param eqref (ref 37)) (result (ref 38))
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 18
    ref.cast (ref 18)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 37)
    call 4
    struct.new 38
    ref.cast (ref 38)
  )
  (func (;8;) (type 57) (param (ref 38)) (result i32)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
    i32.const 0
    i32.eq
  )
  (func (;9;) (type 58) (param (ref 38)) (result (ref 8))
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 18)
    struct.get 18 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 1
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      local.get 2
      array.get 5
      struct.new 10
    else
      i32.const 0
      struct.new 8
    end
    ref.cast (ref 8)
    ref.cast (ref 8)
  )
  (func (;10;) (type 59) (param (ref 38) eqref)
    (local eqref i32 eqref eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    local.get 2
    ref.cast (ref 18)
    struct.get 18 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 18)
      struct.get 18 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 18)
        struct.get 18 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 18)
      struct.get 18 2
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
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      ref.cast (ref 18)
      struct.get 18 1
      array.copy 5 5
      local.get 2
      ref.cast (ref 18)
      local.get 4
      struct.set 18 0
      local.get 2
      ref.cast (ref 18)
      local.get 4
      ref.cast (ref 5)
      array.len
      struct.set 18 2
    end
    local.get 2
    ref.cast (ref 18)
    struct.get 18 0
    ref.cast (ref 5)
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    local.get 5
    array.set 5
    local.get 2
    ref.cast (ref 18)
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    i32.const 1
    i32.add
    struct.set 18 1
    local.get 0
    ref.cast (ref 38)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
    i32.const 1
    i32.sub
    call 21
  )
  (func (;11;) (type 60) (param (ref 38)) (result i32)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
  )
  (func (;12;) (type 61) (param eqref (ref 37) i32) (result (ref 38))
    (local eqref i32 eqref)
    local.get 2
    local.set 4
    local.get 4
    array.new_default 5
    i32.const 0
    local.get 4
    struct.new 18
    ref.cast (ref 18)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 37)
    call 4
    struct.new 38
    ref.cast (ref 38)
  )
  (func (;13;) (type 62) (param eqref (ref 37)) (result (ref 38))
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 18
    ref.cast (ref 18)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    local.get 1
    ref.cast (ref 37)
    call 4
    struct.new 38
    ref.cast (ref 38)
  )
  (func (;14;) (type 63) (param (ref 38) eqref)
    (local eqref i32 eqref eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    local.get 2
    ref.cast (ref 18)
    struct.get 18 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 18)
      struct.get 18 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 18)
        struct.get 18 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 18)
      struct.get 18 2
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
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      ref.cast (ref 18)
      struct.get 18 1
      array.copy 5 5
      local.get 2
      ref.cast (ref 18)
      local.get 4
      struct.set 18 0
      local.get 2
      ref.cast (ref 18)
      local.get 4
      ref.cast (ref 5)
      array.len
      struct.set 18 2
    end
    local.get 2
    ref.cast (ref 18)
    struct.get 18 0
    ref.cast (ref 5)
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    local.get 5
    array.set 5
    local.get 2
    ref.cast (ref 18)
    local.get 2
    ref.cast (ref 18)
    struct.get 18 1
    i32.const 1
    i32.add
    struct.set 18 1
    local.get 0
    ref.cast (ref 38)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
    i32.const 1
    i32.sub
    call 22
  )
  (func (;15;) (type 64) (param (ref 38)) (result (ref 8))
    (local i32 eqref eqref eqref i32 eqref eqref eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      i32.const 0
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 2
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 18)
      struct.get 18 0
      ref.cast (ref 5)
      local.get 5
      array.get 5
      local.set 3
      local.get 0
      ref.cast (ref 38)
      struct.get 38 0
      local.set 4
      local.get 4
      ref.cast (ref 18)
      struct.get 18 1
      i32.eqz
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 8
      else
        local.get 4
        ref.cast (ref 18)
        struct.get 18 1
        i32.const 1
        i32.sub
        local.set 5
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        array.get 5
        local.set 7
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        ref.null eq
        array.set 5
        local.get 4
        ref.cast (ref 18)
        local.get 5
        struct.set 18 1
        i32.const 1
        local.get 7
        struct.new 10
      end
      drop
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        ref.cast (ref 38)
        struct.get 38 0
        i32.const 0
        local.set 5
        local.get 3
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 18)
        struct.get 18 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 5
        local.get 8
        array.set 5
        local.get 0
        ref.cast (ref 38)
        i32.const 0
        call 23
      else
        call 5
      end
      i32.const 1
      local.get 2
      struct.new 10
    end
    ref.cast (ref 8)
  )
  (func (;16;) (type 65) (param (ref 38)) (result (ref 19))
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    i32.const 0
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;17;) (type 66) (param (ref 19)) (result eqref)
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 19)
    struct.get 19 1
    local.get 1
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 18)
    struct.get 18 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 1
    ref.cast (ref 19)
    struct.get 19 1
    local.set 2
    local.get 1
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 18)
    struct.get 18 0
    ref.cast (ref 5)
    local.get 2
    array.get 5
    local.get 1
    ref.cast (ref 19)
    local.get 2
    i32.const 1
    i32.add
    struct.set 19 1
  )
  (func (;18;) (type 67) (param (ref 38)) (result i32)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    ref.cast (ref 18)
    struct.get 18 2
  )
  (func (;19;) (type 68) (param (ref 38))
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 0
    local.set 1
    i32.const 0
    local.set 2
    block ;; label = @1
      loop ;; label = @2
        local.get 2
        local.get 1
        ref.cast (ref 18)
        struct.get 18 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 1
        ref.cast (ref 18)
        struct.get 18 0
        ref.cast (ref 5)
        local.get 2
        ref.null eq
        array.set 5
        local.get 2
        i32.const 1
        i32.add
        local.set 2
        br 0 (;@2;)
      end
    end
    local.get 1
    ref.cast (ref 18)
    i32.const 0
    struct.set 18 1
  )
  (func (;20;) (type 69) (param (ref 38) i32)
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
            ref.cast (ref 38)
            struct.get 38 0
            ref.cast (ref 18)
            struct.get 18 1
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
                ref.cast (ref 38)
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
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
              ref.cast (ref 38)
              struct.get 38 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 7
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 8
              local.get 0
              ref.cast (ref 38)
              local.get 8
              local.get 7
              call 24
              if ;; label = @6
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                local.get 12
                array.set 5
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
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
  (func (;21;) (type 70) (param (ref 38) i32)
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
            ref.cast (ref 38)
            struct.get 38 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 18)
            struct.get 18 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 18)
            struct.get 18 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 4
            local.get 0
            ref.cast (ref 38)
            struct.get 38 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 18)
            struct.get 18 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 18)
            struct.get 18 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 5
            local.get 0
            ref.cast (ref 38)
            local.get 4
            local.get 5
            call 24
            if ;; label = @5
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 7
              local.get 9
              array.set 5
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 18)
              struct.get 18 0
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
  (func (;22;) (type 71) (param (ref 38) i32)
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
            ref.cast (ref 38)
            struct.get 38 0
            local.get 2
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 18)
            struct.get 18 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 18)
            struct.get 18 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 4
            local.get 0
            ref.cast (ref 38)
            struct.get 38 0
            local.get 3
            local.set 7
            local.set 6
            local.get 7
            local.get 6
            ref.cast (ref 18)
            struct.get 18 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 6
            ref.cast (ref 18)
            struct.get 18 0
            ref.cast (ref 5)
            local.get 7
            array.get 5
            local.set 5
            local.get 0
            ref.cast (ref 38)
            local.get 4
            local.get 5
            call 25
            if ;; label = @5
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 2
              local.set 7
              local.get 5
              local.set 9
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 7
              local.get 9
              array.set 5
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 3
              local.set 7
              local.get 4
              local.set 10
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 18)
              struct.get 18 0
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
  (func (;23;) (type 72) (param (ref 38) i32)
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
            ref.cast (ref 38)
            struct.get 38 0
            ref.cast (ref 18)
            struct.get 18 1
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
                ref.cast (ref 38)
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 5
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 4
                local.set 10
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                array.get 5
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
              ref.cast (ref 38)
              struct.get 38 0
              local.get 2
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 7
              local.get 0
              ref.cast (ref 38)
              struct.get 38 0
              local.get 6
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 18)
              struct.get 18 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 18)
              struct.get 18 0
              ref.cast (ref 5)
              local.get 10
              array.get 5
              local.set 8
              local.get 0
              ref.cast (ref 38)
              local.get 8
              local.get 7
              call 25
              if ;; label = @6
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 2
                local.set 10
                local.get 8
                local.set 12
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
                ref.cast (ref 5)
                local.get 10
                local.get 12
                array.set 5
                local.get 0
                ref.cast (ref 38)
                struct.get 38 0
                local.get 6
                local.set 10
                local.get 7
                local.set 13
                local.set 9
                local.get 10
                local.get 9
                ref.cast (ref 18)
                struct.get 18 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 9
                ref.cast (ref 18)
                struct.get 18 0
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
  (func (;24;) (type 73) (param (ref 38) eqref eqref) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 6
    ref.cast (ref 76)
    local.get 1
    ref.cast (ref 75)
    local.get 2
    ref.cast (ref 75)
    call 43
    local.set 3
    local.get 0
    ref.cast (ref 38)
    struct.get 38 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 11)
      call 2
    else
      local.get 3
      ref.cast (ref 11)
      call 1
    end
  )
  (func (;25;) (type 74) (param (ref 38) eqref eqref) (result i32)
    (local eqref)
    local.get 0
    ref.cast (ref 38)
    struct.get 38 6
    ref.cast (ref 76)
    local.get 1
    ref.cast (ref 75)
    local.get 2
    ref.cast (ref 75)
    call 44
    local.set 3
    local.get 0
    ref.cast (ref 38)
    struct.get 38 7
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 11)
      call 2
    else
      local.get 3
      ref.cast (ref 11)
      call 1
    end
  )
  (func (;26;) (type 93) (param (ref 77)) (result (ref 8))
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 6
    ref.cast (ref 8)
  )
  (func (;27;) (type 94) (param (ref 75)) (result i32)
    local.get 0
    ref.cast (ref 75)
    struct.get 75 0
  )
  (func (;28;) (type 95) (param eqref (ref 37)) (result (ref 77))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 76
    local.get 1
    ref.cast (ref 37)
    call 7
    ref.cast (ref 38)
    struct.new 77
    ref.cast (ref 77)
  )
  (func (;29;) (type 96) (param (ref 77)) (result i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 8
  )
  (func (;30;) (type 97) (param (ref 77)) (result (ref 8))
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 9
    ref.cast (ref 8)
  )
  (func (;31;) (type 98) (param (ref 77) i32 i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
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
    struct.new 75
    call 10
  )
  (func (;32;) (type 99) (param (ref 77)) (result i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 11
  )
  (func (;33;) (type 100) (param (ref 75)) (result i32)
    local.get 0
    ref.cast (ref 75)
    struct.get 75 6
  )
  (func (;34;) (type 101) (param eqref (ref 37) i32) (result (ref 77))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 76
    local.get 1
    ref.cast (ref 37)
    local.get 2
    call 12
    ref.cast (ref 38)
    struct.new 77
    ref.cast (ref 77)
  )
  (func (;35;) (type 102) (param eqref (ref 37)) (result (ref 77))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 76
    local.get 1
    ref.cast (ref 37)
    call 13
    ref.cast (ref 38)
    struct.new 77
    ref.cast (ref 77)
  )
  (func (;36;) (type 103) (param (ref 77) eqref i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
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
    struct.new 75
    call 14
  )
  (func (;37;) (type 104) (param (ref 77)) (result (ref 8))
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 15
    ref.cast (ref 8)
  )
  (func (;38;) (type 105) (param (ref 75)) (result eqref)
    local.get 0
    ref.cast (ref 75)
    struct.get 75 5
  )
  (func (;39;) (type 106) (param (ref 77)) (result (ref 78))
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 16
    ref.cast (ref 19)
    struct.new 78
    ref.cast (ref 78)
  )
  (func (;40;) (type 107) (param (ref 78)) (result (ref 75))
    local.get 0
    ref.cast (ref 78)
    struct.get 78 0
    ref.cast (ref 19)
    call 17
    ref.cast (ref 75)
  )
  (func (;41;) (type 108) (param (ref 77)) (result i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 18
  )
  (func (;42;) (type 109) (param (ref 77))
    local.get 0
    ref.cast (ref 77)
    struct.get 77 0
    ref.cast (ref 38)
    call 19
  )
  (func (;43;) (type 110) (param (ref 76) (ref 75) (ref 75)) (result (ref 11))
    local.get 0
    ref.cast (ref 76)
    struct.get 76 5
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 75)
    struct.get 75 6
    local.get 2
    ref.cast (ref 75)
    struct.get 75 6
    call 3
    ref.cast (ref 11)
  )
  (func (;44;) (type 111) (param (ref 76) (ref 75) (ref 75)) (result (ref 11))
    local.get 0
    ref.cast (ref 76)
    struct.get 76 5
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 75)
    struct.get 75 6
    local.get 2
    ref.cast (ref 75)
    struct.get 75 6
    call 3
    ref.cast (ref 11)
  )
  (func (;45;) (type 113))
  (func (;46;) (type 114) (param (ref 77)) (result i32)
    (local eqref eqref i32)
    local.get 0
    ref.cast (ref 77)
    call 26
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
          i32.const -1
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        local.set 1
        local.get 1
        ref.cast (ref 75)
        call 27
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;47;) (type 115)
    (local eqref eqref i32 i32 eqref eqref eqref eqref eqref i32 i32 i32 eqref i32 eqref i32 eqref eqref i32)
    call 0
    i32.const 0
    struct.new 37
    call 28
    local.set 0
    local.get 0
    ref.cast (ref 77)
    call 29
    v128.const i32x4 0x2077656e 0x75657571 0x6d652065 0x00797470
    array.new_fixed 116 1
    i32.const 0
    i32.const 15
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 30
    local.set 12
    block ;; label = @1
      local.get 12
      ref.cast (ref 8)
      struct.get 8 0
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
    array.new_fixed 116 1
    i32.const 0
    i32.const 10
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 26
    local.set 14
    block ;; label = @1
      local.get 14
      ref.cast (ref 8)
      struct.get 8 0
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
    array.new_fixed 116 1
    i32.const 0
    i32.const 13
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    i32.const 50
    i32.const 5
    call 31
    local.get 0
    ref.cast (ref 77)
    i32.const 10
    i32.const 1
    call 31
    local.get 0
    ref.cast (ref 77)
    i32.const 30
    i32.const 3
    call 31
    local.get 0
    ref.cast (ref 77)
    i32.const 31
    i32.const 3
    call 31
    local.get 0
    ref.cast (ref 77)
    i32.const 20
    i32.const 2
    call 31
    local.get 0
    ref.cast (ref 77)
    call 32
    i32.const 5
    i32.eq
    v128.const i32x4 0x61696c61 0x756d2073 0x69746174 0x00006e6f
    array.new_fixed 116 1
    i32.const 0
    i32.const 14
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 30
    local.set 16
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 16
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x6b656570 0x73696d20 0x676e6973 0x00000000
          array.new_fixed 116 1
          i32.const 0
          i32.const 12
          struct.new 117
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 16
        ref.cast (ref 10)
        struct.get 10 1
        local.set 1
        local.get 1
        ref.cast (ref 75)
        call 27
        i32.const 10
        i32.eq
        v128.const i32x4 0x6b656570 0x6c617620 0x00006575 0x00000000
        array.new_fixed 116 1
        i32.const 0
        i32.const 10
        struct.new 117
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        local.get 1
        ref.cast (ref 75)
        call 33
        i32.const 1
        i32.eq
        v128.const i32x4 0x6b656570 0x69727020 0x7469726f 0x00000079
        array.new_fixed 116 1
        i32.const 0
        i32.const 13
        struct.new 117
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
    ref.cast (ref 77)
    call 32
    i32.const 5
    i32.eq
    v128.const i32x4 0x6b656570 0x6e6f6e20 0x74756d2d 0x6e697461
    v128.const i32x4 0x00000067 0x00000000 0x00000000 0x00000000
    array.new_fixed 116 2
    i32.const 0
    i32.const 17
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 46
    i32.const 10
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x73726966 0x00000074
    array.new_fixed 116 1
    i32.const 0
    i32.const 13
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 46
    i32.const 20
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x6f636573 0x0000646e
    array.new_fixed 116 1
    i32.const 0
    i32.const 14
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 46
    local.set 2
    local.get 0
    ref.cast (ref 77)
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
    array.new_fixed 116 2
    i32.const 0
    i32.const 30
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 77)
    call 46
    i32.const 50
    i32.eq
    v128.const i32x4 0x696e696d 0x206d756d 0x7473616c 0x00000000
    array.new_fixed 116 1
    i32.const 0
    i32.const 12
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    i32.const 1
    struct.new 37
    i32.const 2
    call 34
    local.set 4
    local.get 4
    ref.cast (ref 77)
    i32.const 1
    i32.const 1
    call 31
    local.get 4
    ref.cast (ref 77)
    i32.const 9
    i32.const 9
    call 31
    local.get 4
    ref.cast (ref 77)
    i32.const 4
    i32.const 4
    call 31
    local.get 4
    ref.cast (ref 77)
    call 46
    i32.const 9
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x73726966 0x00000074
    array.new_fixed 116 1
    i32.const 0
    i32.const 13
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 77)
    call 46
    i32.const 4
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x6f636573 0x0000646e
    array.new_fixed 116 1
    i32.const 0
    i32.const 14
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 77)
    call 46
    i32.const 1
    i32.eq
    v128.const i32x4 0x6978616d 0x206d756d 0x7473616c 0x00000000
    array.new_fixed 116 1
    i32.const 0
    i32.const 12
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    i32.const 0
    struct.new 37
    call 35
    local.set 5
    local.get 5
    ref.cast (ref 77)
    i32.const 2
    struct.new 112
    i32.const 2
    call 36
    local.get 5
    ref.cast (ref 77)
    i32.const 1
    struct.new 112
    i32.const 1
    call 36
    local.get 5
    ref.cast (ref 77)
    call 37
    local.set 17
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 17
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x20626f6a 0x7373696d 0x00676e69 0x00000000
          array.new_fixed 116 1
          i32.const 0
          i32.const 11
          struct.new 117
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 17
        ref.cast (ref 10)
        struct.get 10 1
        local.set 6
        local.get 6
        ref.cast (ref 75)
        call 38
        ref.cast (ref 112)
        struct.get 112 0
        i32.const 1
        i32.eq
        v128.const i32x4 0x65666572 0x636e6572 0x61762065 0x0065756c
        array.new_fixed 116 1
        i32.const 0
        i32.const 15
        struct.new 117
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
    struct.new 37
    call 28
    local.set 7
    local.get 7
    ref.cast (ref 77)
    i32.const 4
    i32.const 4
    call 31
    local.get 7
    ref.cast (ref 77)
    i32.const 1
    i32.const 1
    call 31
    local.get 7
    ref.cast (ref 77)
    i32.const 3
    i32.const 3
    call 31
    local.get 7
    ref.cast (ref 77)
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
            ref.cast (ref 77)
            call 32
            i32.lt_u
            if ;; label = @5
              local.get 9
              local.get 8
              ref.cast (ref 78)
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
    array.new_fixed 116 1
    i32.const 0
    i32.const 15
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 77)
    call 41
    local.set 11
    local.get 7
    ref.cast (ref 77)
    call 42
    local.get 7
    ref.cast (ref 77)
    call 29
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 116 1
    i32.const 0
    i32.const 11
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 77)
    call 41
    local.get 11
    i32.eq
    v128.const i32x4 0x61656c63 0x61632072 0x69636170 0x00007974
    array.new_fixed 116 1
    i32.const 0
    i32.const 14
    struct.new 117
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
