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
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (param (ref 11)) (result i32)))
  (type (;31;) (func))
  (type (;32;) (func (param i32 i32) (result i32)))
  (type (;33;) (func (param i32 i32 i32)))
  (type (;34;) (func (param (ref 11) (ref 11))))
  (type (;35;) (func (param i32 i32) (result (ref 8))))
  (type (;36;) (func (param (ref 11) (ref 11) i32 i32)))
  (type (;37;) (func (param i32 eqref) (result (ref 11))))
  (type (;38;) (func (param (ref 11) i32)))
  (type (;39;) (func (param (ref 11))))
  (type (;40;) (func (param (ref 11) i32)))
  (type (;41;) (func (param (ref 11)) (result (ref 11))))
  (type (;42;) (func (param (ref 11)) (result (ref 11))))
  (type (;43;) (func (param (ref 11) (ref 11))))
  (type (;44;) (func (param (ref 11) (ref 11))))
  (type (;45;) (func (param (ref 11)) (result (ref 8))))
  (type (;46;) (func (param (ref 11)) (result (ref 8))))
  (type (;47;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;48;) (func (param (ref 11) i32 i32)))
  (type (;49;) (func (param (ref 11)) (result (ref 8))))
  (type (;50;) (func (param (ref 11) eqref)))
  (type (;51;) (func (param (ref 11) i32 eqref) (result i32)))
  (type (;52;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;53;) (func (param (ref 11) eqref i32 i32)))
  (type (;54;) (func (param (ref 11) i32 i32 i32)))
  (type (;55;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;56;) (func (param (ref 11) (ref 11)) (result (ref 11))))
  (type (;57;) (func (param (ref 11))))
  (type (;58;) (func (param (ref 11)) (result (ref 11))))
  (type (;59;) (func (param (ref 11) i32 i32 (ref 11)) (result (ref 11))))
  (type (;60;) (func (param (ref 11) i32 i32 (ref 11)) (result (ref 11))))
  (type (;61;) (func (param (ref 11))))
  (type (;62;) (func (param (ref 11)) (result (ref 11))))
  (type (;63;) (func (param (ref 11) eqref) (result i32)))
  (type (;64;) (func (param (ref 11) eqref) (result (ref 8))))
  (type (;65;) (func (param (ref 11) eqref i32) (result (ref 8))))
  (type (;66;) (func (param (ref 11) eqref) (result (ref 8))))
  (type (;67;) (func (param (ref 11) eqref i32) (result (ref 8))))
  (type (;68;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;69;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;70;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;71;) (func (param (ref 11)) (result (ref 11))))
  (type (;72;) (func (param (ref 11)) (result i32)))
  (type (;73;) (func (param (ref 11)) (result (ref 8))))
  (type (;74;) (func (param (ref 11)) (result (ref 8))))
  (type (;75;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;76;) (func (param i32 i32) (result (ref 11))))
  (type (;77;) (func (param (ref 11)) (result (ref 11))))
  (type (;78;) (func (param (ref 11)) (result (ref 11))))
  (type (;79;) (func (param (ref 11) i32)))
  (type (;80;) (func (param (ref 11) i32)))
  (type (;81;) (func (param (ref 11))))
  (type (;82;) (func (param (ref 11) i32 i32 i32)))
  (type (;83;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;84;) (func (param (ref 11) i32 i32 i32)))
  (type (;85;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;86;) (func (param (ref 11) (ref 11)) (result (ref 11))))
  (type (;87;) (func (param (ref 11) (ref 11))))
  (type (;88;) (func (param (ref 11) (ref 11))))
  (type (;89;) (func (param (ref 11)) (result (ref 8))))
  (type (;90;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;91;) (func (param (ref 11) i32 i32) (result i32)))
  (type (;92;) (func (param (ref 11) i32)))
  (type (;93;) (func (param (ref 11)) (result (ref 11))))
  (type (;94;) (func (param (ref 11))))
  (type (;95;) (func (param (ref 11) i32 i32 (ref 11)) (result (ref 11))))
  (type (;96;) (func (param (ref 11) i32 i32 (ref 11)) (result (ref 11))))
  (type (;97;) (func (param (ref 11) i32) (result i32)))
  (type (;98;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;99;) (func (param (ref 11) i32 i32) (result (ref 8))))
  (type (;100;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;101;) (func (param (ref 11) i32 i32) (result (ref 8))))
  (type (;102;) (func (param (ref 11) i32 i32)))
  (type (;103;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;104;) (func (param (ref 11) (ref 11)) (result i32)))
  (type (;105;) (func (param (ref 11)) (result (ref 11))))
  (type (;106;) (func (param (ref 11))))
  (type (;107;) (func (param (ref 11)) (result (ref 11))))
  (type (;108;) (func (param (ref 11) (ref 11))))
  (type (;109;) (func (param (ref 11) (ref 11) i32 i32)))
  (type (;110;) (func (param eqref eqref) (result i32)))
  (type (;111;) (func (param eqref eqref) (result i32)))
  (type (;112;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;113;) (func (param i32 eqref) (result i32)))
  (type (;114;) (struct (field i32) (field i32)))
  (type (;115;) (struct))
  (type (;116;) (struct))
  (type (;117;) (func (result (ref 11))))
  (type (;118;) (func (param i32) (result (ref 11))))
  (type (;119;) (func (result (ref 11))))
  (type (;120;) (func (result (ref 11))))
  (type (;121;) (func (param i32 i32) (result (ref 11))))
  (type (;122;) (func (param (ref 8)) (result i32)))
  (type (;123;) (func (param (ref 8)) (result i32)))
  (type (;124;) (func (param i32) (result i32)))
  (type (;125;) (func (param i32 i32) (result i32)))
  (type (;126;) (func (param i32 i32 i32) (result i32)))
  (type (;127;) (func (param i32) (result i32)))
  (type (;128;) (func (param i32 i32) (result i32)))
  (type (;129;) (func (param i32) (result i32)))
  (type (;130;) (func (param i32) (result i32)))
  (type (;131;) (func (param i32 i32) (result i32)))
  (type (;132;) (func (param i32) (result (ref 11))))
  (type (;133;) (func (param i32) (result eqref)))
  (type (;134;) (func (param i32 i32) (result i32)))
  (type (;135;) (func (param (ref 115) i32 i32) (result i32)))
  (type (;136;) (func (param (ref 116) (ref 114) (ref 114)) (result i32)))
  (type (;137;) (func (result (ref 11))))
  (type (;138;) (func (param eqref eqref) (result i32)))
  (type (;139;) (func (param (ref 114)) (result i32)))
  (type (;140;) (func (param (ref 114)) (result i32)))
  (type (;141;) (func))
  (type (;142;) (func))
  (type (;143;) (func))
  (type (;144;) (func))
  (type (;145;) (func))
  (type (;146;) (func))
  (type (;147;) (func))
  (type (;148;) (func))
  (type (;149;) (func))
  (type (;150;) (func))
  (type (;151;) (func))
  (type (;152;) (func))
  (type (;153;) (func))
  (type (;154;) (func))
  (type (;155;) (func))
  (type (;156;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;157;) (struct))
  (type (;158;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;159;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;160;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;161;) (array (mut v128)))
  (type (;162;) (struct (field (ref 161)) (field i32) (field i32)))
  (type (;163;) (struct (field (ref 161)) (field i32) (field i32)))
  (type (;164;) (struct (field (ref 161)) (field i32) (field i32)))
  (type (;165;) (struct (field (mut (ref 161))) (field (mut i32)) (field (mut i32))))
  (type (;166;) (struct (field (mut (ref 161))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 112)))
  (memory (;0;) 1)
  (export "main" (func 84))
  (export "memory" (memory 0))
  (func (;1;) (type 31))
  (func (;2;) (type 32) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
    else
      local.get 1
    end
  )
  (func (;3;) (type 33) (param i32 i32 i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      local.get 0
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;4;) (type 35) (param i32 i32) (result (ref 8))
    (local i64 i64 i64)
    local.get 0
    i64.extend_i32_u
    local.set 2
    local.get 1
    i64.extend_i32_s
    local.set 3
    local.get 3
    i64.const 0
    i64.lt_s
    if (result i64) ;; label = @1
      local.get 2
      local.get 3
      i64.add
    else
      local.get 3
    end
    local.set 4
    local.get 4
    i64.const 0
    i64.lt_s
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 2
      i64.ge_s
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      i32.const 1
      local.get 4
      i32.wrap_i64
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;5;) (type 72) (param (ref 11)) (result i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
  )
  (func (;6;) (type 73) (param (ref 11)) (result (ref 8))
    (local eqref i32 eqref)
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 2
      array.get 0
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    ref.cast (ref 8)
    ref.cast (ref 8)
  )
  (func (;7;) (type 74) (param (ref 11)) (result (ref 8))
    (local i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      local.get 1
      i32.const 1
      i32.sub
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      i32.lt_u
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 2
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 3
        array.get 0
        struct.new 9
      else
        i32.const 0
        struct.new 8
      end
      ref.cast (ref 8)
    end
    ref.cast (ref 8)
  )
  (func (;8;) (type 75) (param (ref 11) i32) (result (ref 8))
    (local i32 eqref i32 eqref eqref eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    call 4
    local.set 6
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 6
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          struct.new 8
          local.set 7
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 9)
        struct.get 9 1
        local.set 2
        local.get 0
        local.get 2
        local.set 4
        local.set 3
        local.get 4
        local.get 3
        ref.cast (ref 11)
        struct.get 11 1
        i32.lt_u
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 3
          ref.cast (ref 11)
          struct.get 11 0
          ref.cast (ref 0)
          local.get 4
          array.get 0
          struct.new 9
        else
          i32.const 0
          struct.new 8
        end
        ref.cast (ref 8)
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    ref.cast (ref 8)
  )
  (func (;9;) (type 76) (param i32 i32) (result (ref 11))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;10;) (type 77) (param (ref 11)) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    array.new_default 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    array.copy 0 0
    local.get 3
    local.get 2
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;11;) (type 78) (param (ref 11)) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    array.new_default 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    array.copy 0 0
    local.get 3
    local.get 2
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;12;) (type 79) (param (ref 11) i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.add
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.gt_u
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.get 3
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 3
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 2
          ref.cast (ref 11)
          struct.get 11 2
          i32.const 2
          i32.mul
        end
      end
      array.new_default 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
  )
  (func (;13;) (type 80) (param (ref 11) i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 1
  )
  (func (;14;) (type 81) (param (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
    else
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 2
      struct.set 11 2
    end
  )
  (func (;15;) (type 82) (param (ref 11) i32 i32 i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    local.get 3
    call 3
    local.get 0
    local.set 4
    local.get 1
    local.set 7
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    local.get 7
    local.get 3
    local.get 2
    i32.sub
    array.fill 0
  )
  (func (;16;) (type 83) (param (ref 11) (ref 11)) (result i32)
    (local i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ne
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      local.set 7
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 7
              local.set 3
              local.get 3
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 0
                local.get 3
                local.set 5
                local.set 4
                local.get 5
                local.get 4
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 4
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 5
                array.get 0
                local.get 1
                local.get 3
                local.set 5
                local.set 4
                local.get 5
                local.get 4
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 4
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 5
                array.get 0
                i32.eq
                if ;; label = @7
                  local.get 3
                  i32.const 1
                  i32.add
                  local.set 7
                  br 4 (;@3;)
                else
                  i32.const 0
                  local.set 8
                  br 5 (;@2;)
                end
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              local.set 8
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 8
    end
  )
  (func (;17;) (type 84) (param (ref 11) i32 i32 i32)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 4
    local.get 2
    local.get 3
    call 3
    local.get 3
    local.get 2
    i32.sub
    local.set 5
    local.get 1
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 5
      local.get 4
      local.get 1
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
      local.get 0
      local.set 6
      local.get 6
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 1
      local.get 6
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 2
      local.get 3
      local.get 2
      i32.sub
      array.copy 0 0
    end
  )
  (func (;18;) (type 85) (param (ref 11) i32 i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    local.get 2
    call 3
    local.get 0
    local.set 3
    local.get 2
    local.get 1
    i32.sub
    local.set 4
    local.get 4
    array.new_default 0
    local.set 5
    local.get 5
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    local.get 4
    array.copy 0 0
    local.get 5
    local.get 4
    local.get 4
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;19;) (type 86) (param (ref 11) (ref 11)) (result (ref 11))
    (local eqref eqref i32 eqref)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 4
    array.new_default 0
    local.set 5
    local.get 5
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 4
    array.copy 0 0
    local.get 5
    local.get 4
    local.get 4
    struct.new 11
    local.set 2
    local.get 2
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 41
    local.get 2
    ref.cast (ref 11)
  )
  (func (;20;) (type 87) (param (ref 11) (ref 11))
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 41
  )
  (func (;21;) (type 88) (param (ref 11) (ref 11))
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 41
  )
  (func (;22;) (type 89) (param (ref 11)) (result (ref 8))
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      i32.const 0
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 2
      local.get 1
      i32.const 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        local.set 3
        local.get 3
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        i32.const 0
        local.get 3
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        i32.const 1
        local.get 1
        i32.const 1
        i32.sub
        array.copy 0 0
      else
      end
      local.get 0
      local.set 3
      local.get 1
      i32.const 1
      i32.sub
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.gt_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 11)
      local.get 4
      struct.set 11 1
      i32.const 1
      local.get 2
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;23;) (type 90) (param (ref 11) i32) (result (ref 8))
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      local.get 1
      local.set 5
      local.set 4
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 3
      local.get 1
      i32.const 1
      i32.add
      local.get 2
      i32.lt_u
      if ;; label = @2
        local.get 0
        local.set 4
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 1
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 1
        i32.const 1
        i32.add
        local.get 2
        local.get 1
        i32.const 1
        i32.add
        i32.sub
        array.copy 0 0
      else
      end
      local.get 0
      local.set 4
      local.get 2
      i32.const 1
      i32.sub
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.gt_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      ref.cast (ref 11)
      local.get 5
      struct.set 11 1
      i32.const 1
      local.get 3
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;24;) (type 91) (param (ref 11) i32 i32) (result i32)
    (local i32 eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 1
    local.get 3
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.set 4
      i32.const 1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.lt_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.gt_u
      if ;; label = @2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 11)
          struct.get 11 2
          i32.const 2
          i32.mul
        end
        local.get 5
        i32.lt_u
        if (result i32) ;; label = @3
          local.get 5
        else
          local.get 4
          ref.cast (ref 11)
          struct.get 11 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2
            i32.mul
          end
        end
        array.new_default 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        i32.const 0
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        i32.const 0
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        array.copy 0 0
        local.get 4
        ref.cast (ref 11)
        local.get 6
        struct.set 11 0
        local.get 4
        ref.cast (ref 11)
        local.get 6
        ref.cast (ref 0)
        array.len
        struct.set 11 2
      end
      local.get 0
      local.get 2
      local.set 7
      local.set 4
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.eq
      if ;; label = @2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 11)
          struct.get 11 2
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 5
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.le_u
        if ;; label = @3
          unreachable
        end
        local.get 5
        array.new_default 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        i32.const 0
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        i32.const 0
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        array.copy 0 0
        local.get 4
        ref.cast (ref 11)
        local.get 6
        struct.set 11 0
        local.get 4
        ref.cast (ref 11)
        local.get 6
        ref.cast (ref 0)
        array.len
        struct.set 11 2
      end
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      local.get 7
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      local.get 1
      local.get 3
      i32.lt_u
      if ;; label = @2
        local.get 0
        local.set 4
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 1
        i32.const 1
        i32.add
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 1
        local.get 3
        local.get 1
        i32.sub
        array.copy 0 0
        local.get 0
        local.get 1
        local.set 5
        local.get 2
        local.set 8
        local.set 4
        local.get 5
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 5
        local.get 8
        array.set 0
      else
      end
      i32.const 1
    end
  )
  (func (;25;) (type 92) (param (ref 11) i32)
    (local i32 eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 0
    local.set 3
    i32.const 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.add
    local.set 4
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.gt_u
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.get 4
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 3
          ref.cast (ref 11)
          struct.get 11 2
          i32.const 2
          i32.mul
        end
      end
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 0
    local.get 1
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    i32.const 0
    i32.gt_u
    if ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      i32.const 0
      i32.sub
      array.copy 0 0
      local.get 0
      i32.const 0
      local.set 4
      local.get 1
      local.set 7
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      local.get 7
      array.set 0
    else
    end
  )
  (func (;26;) (type 93) (param (ref 11)) (result (ref 11))
    (local eqref eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 3
    array.new_default 0
    local.set 4
    local.get 4
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    array.copy 0 0
    local.get 4
    local.get 3
    local.get 3
    struct.new 11
    local.set 1
    local.get 1
    ref.cast (ref 11)
    call 27
    local.get 1
    ref.cast (ref 11)
  )
  (func (;27;) (type 94) (param (ref 11))
    (local i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 1
    local.get 1
    i32.const 1
    i32.gt_u
    if ;; label = @1
      i32.const 0
      local.set 2
      local.get 1
      i32.const 1
      i32.sub
      local.set 3
      i32.const 1
      local.set 11
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 11
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 2
              local.get 3
              i32.lt_u
              if ;; label = @6
                local.get 0
                local.get 2
                local.set 7
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 7
                array.get 0
                local.set 4
                local.get 0
                local.get 3
                local.set 7
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 7
                array.get 0
                local.set 5
                local.get 0
                local.get 2
                local.set 7
                local.get 5
                local.set 9
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 7
                local.get 9
                array.set 0
                local.get 0
                local.get 3
                local.set 7
                local.get 4
                local.set 10
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 7
                local.get 10
                array.set 0
                local.get 2
                i32.const 1
                i32.add
                local.set 2
                local.get 3
                i32.const 1
                i32.sub
                local.set 3
                i32.const 1
                local.set 11
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 1
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
    else
    end
  )
  (func (;28;) (type 95) (param (ref 11) i32 i32 (ref 11)) (result (ref 11))
    (local i32 i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 1
    local.get 4
    i32.gt_u
    if ;; label = @1
      unreachable
    else
    end
    local.get 2
    local.get 4
    local.get 1
    i32.sub
    call 2
    local.set 5
    local.get 0
    local.set 15
    local.get 1
    local.get 5
    i32.add
    local.get 1
    i32.sub
    local.set 16
    local.get 16
    array.new_default 0
    local.set 17
    local.get 17
    ref.cast (ref 0)
    i32.const 0
    local.get 15
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    local.get 16
    array.copy 0 0
    local.get 17
    local.get 16
    local.get 16
    struct.new 11
    local.set 6
    local.get 3
    local.set 15
    local.get 15
    ref.cast (ref 11)
    struct.get 11 1
    local.set 16
    local.get 16
    array.new_default 0
    local.set 17
    local.get 17
    ref.cast (ref 0)
    i32.const 0
    local.get 15
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 16
    array.copy 0 0
    local.get 17
    local.get 16
    local.get 16
    struct.new 11
    local.set 7
    local.get 7
    ref.cast (ref 11)
    struct.get 11 1
    local.set 8
    local.get 1
    local.get 5
    i32.add
    local.set 9
    local.get 8
    local.get 5
    i32.gt_u
    if ;; label = @1
      local.get 8
      local.get 5
      i32.sub
      local.set 10
      local.get 0
      local.set 15
      local.get 10
      local.get 15
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      local.set 16
      local.get 16
      local.get 15
      ref.cast (ref 11)
      struct.get 11 1
      i32.lt_u
      if ;; label = @2
        unreachable
      end
      local.get 16
      local.get 15
      ref.cast (ref 11)
      struct.get 11 2
      i32.gt_u
      if ;; label = @2
        local.get 15
        ref.cast (ref 11)
        struct.get 11 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 15
          ref.cast (ref 11)
          struct.get 11 2
          i32.const 2
          i32.mul
        end
        local.get 16
        i32.lt_u
        if (result i32) ;; label = @3
          local.get 16
        else
          local.get 15
          ref.cast (ref 11)
          struct.get 11 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 15
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2
            i32.mul
          end
        end
        array.new_default 0
        local.set 17
        local.get 17
        ref.cast (ref 0)
        i32.const 0
        local.get 15
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        i32.const 0
        local.get 15
        ref.cast (ref 11)
        struct.get 11 1
        array.copy 0 0
        local.get 15
        ref.cast (ref 11)
        local.get 17
        struct.set 11 0
        local.get 15
        ref.cast (ref 11)
        local.get 17
        ref.cast (ref 0)
        array.len
        struct.set 11 2
      end
      i32.const 0
      local.set 19
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 19
              local.set 11
              local.get 11
              local.get 10
              i32.lt_u
              if ;; label = @6
                local.get 7
                local.get 11
                local.set 16
                local.set 15
                local.get 16
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 15
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 16
                array.get 0
                local.set 12
                local.get 0
                local.get 12
                local.set 18
                local.set 15
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                local.get 15
                ref.cast (ref 11)
                struct.get 11 2
                i32.eq
                if ;; label = @7
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 2
                  i32.eqz
                  if (result i32) ;; label = @8
                    i32.const 4
                  else
                    local.get 15
                    ref.cast (ref 11)
                    struct.get 11 2
                    i32.const 2
                    i32.mul
                  end
                  local.set 16
                  local.get 16
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 2
                  i32.le_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 16
                  array.new_default 0
                  local.set 17
                  local.get 17
                  ref.cast (ref 0)
                  i32.const 0
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 0)
                  i32.const 0
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 1
                  array.copy 0 0
                  local.get 15
                  ref.cast (ref 11)
                  local.get 17
                  struct.set 11 0
                  local.get 15
                  ref.cast (ref 11)
                  local.get 17
                  ref.cast (ref 0)
                  array.len
                  struct.set 11 2
                end
                local.get 15
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                local.get 18
                array.set 0
                local.get 15
                ref.cast (ref 11)
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                i32.const 1
                i32.add
                struct.set 11 1
                local.get 11
                i32.const 1
                i32.add
                local.set 19
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 1
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 9
      local.get 4
      i32.lt_u
      if ;; label = @2
        local.get 0
        local.set 15
        local.get 15
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 1
        local.get 8
        i32.add
        local.get 15
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 9
        local.get 4
        local.get 9
        i32.sub
        array.copy 0 0
      else
      end
    else
      local.get 8
      local.get 5
      i32.lt_u
      if ;; label = @2
        local.get 9
        local.get 4
        i32.lt_u
        if ;; label = @3
          local.get 0
          local.set 15
          local.get 15
          ref.cast (ref 11)
          struct.get 11 0
          ref.cast (ref 0)
          local.get 1
          local.get 8
          i32.add
          local.get 15
          ref.cast (ref 11)
          struct.get 11 0
          ref.cast (ref 0)
          local.get 9
          local.get 4
          local.get 9
          i32.sub
          array.copy 0 0
        else
        end
        local.get 0
        local.set 15
        local.get 4
        local.get 5
        local.get 8
        i32.sub
        i32.sub
        local.set 16
        local.get 16
        local.get 15
        ref.cast (ref 11)
        struct.get 11 1
        i32.gt_u
        if ;; label = @3
          unreachable
        end
        local.get 15
        ref.cast (ref 11)
        local.get 16
        struct.set 11 1
      else
      end
    end
    i32.const 0
    local.set 21
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 21
            local.set 13
            local.get 13
            local.get 8
            i32.lt_u
            if ;; label = @5
              local.get 7
              local.get 13
              local.set 16
              local.set 15
              local.get 16
              local.get 15
              ref.cast (ref 11)
              struct.get 11 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 15
              ref.cast (ref 11)
              struct.get 11 0
              ref.cast (ref 0)
              local.get 16
              array.get 0
              local.set 14
              local.get 0
              local.get 1
              local.get 13
              i32.add
              local.set 16
              local.get 14
              local.set 20
              local.set 15
              local.get 16
              local.get 15
              ref.cast (ref 11)
              struct.get 11 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 15
              ref.cast (ref 11)
              struct.get 11 0
              ref.cast (ref 0)
              local.get 16
              local.get 20
              array.set 0
              local.get 13
              i32.const 1
              i32.add
              local.set 21
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 6
    ref.cast (ref 11)
  )
  (func (;29;) (type 96) (param (ref 11) i32 i32 (ref 11)) (result (ref 11))
    (local eqref eqref i32 eqref)
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    local.set 6
    local.get 6
    array.new_default 0
    local.set 7
    local.get 7
    ref.cast (ref 0)
    i32.const 0
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 6
    array.copy 0 0
    local.get 7
    local.get 6
    local.get 6
    struct.new 11
    local.set 4
    local.get 4
    ref.cast (ref 11)
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 11)
    call 28
    drop
    local.get 4
    ref.cast (ref 11)
  )
  (func (;30;) (type 97) (param (ref 11) i32) (result i32)
    (local eqref i32)
    local.get 0
    ref.cast (ref 11)
    local.get 1
    call 31
    local.set 2
    block ;; label = @1
      local.get 2
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 3
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;31;) (type 98) (param (ref 11) i32) (result (ref 8))
    local.get 0
    ref.cast (ref 11)
    local.get 1
    i32.const 0
    call 32
    ref.cast (ref 8)
  )
  (func (;32;) (type 99) (param (ref 11) i32 i32) (result (ref 8))
    (local i32 i32 eqref i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 2
    local.get 3
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 2
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 8
              local.set 4
              local.get 4
              local.get 3
              i32.lt_u
              if ;; label = @6
                local.get 0
                local.get 4
                local.set 6
                local.set 5
                local.get 6
                local.get 5
                ref.cast (ref 11)
                struct.get 11 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 5
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 0)
                local.get 6
                array.get 0
                local.get 1
                i32.eq
                if ;; label = @7
                  i32.const 1
                  local.get 4
                  struct.new 9
                  local.set 9
                  br 5 (;@2;)
                else
                  local.get 4
                  i32.const 1
                  i32.add
                  local.set 8
                  br 4 (;@3;)
                end
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              struct.new 8
              local.set 9
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 9
    end
    ref.cast (ref 8)
  )
  (func (;33;) (type 100) (param (ref 11) i32) (result (ref 8))
    local.get 0
    ref.cast (ref 11)
    local.get 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    call 34
    ref.cast (ref 8)
  )
  (func (;34;) (type 101) (param (ref 11) i32 i32) (result (ref 8))
    (local i32 i32 i32 eqref i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 2
    local.get 3
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 2
      local.set 9
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 9
            i32.const 0
            i32.eq
            if ;; label = @5
              i32.const 0
              struct.new 8
              local.set 10
              br 3 (;@2;)
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              local.get 9
              local.set 4
              local.get 4
              i32.const 1
              i32.sub
              local.set 5
              local.get 0
              local.get 5
              local.set 7
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 11)
              struct.get 11 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 11)
              struct.get 11 0
              ref.cast (ref 0)
              local.get 7
              array.get 0
              local.get 1
              i32.eq
              if ;; label = @6
                i32.const 1
                local.get 5
                struct.new 9
                local.set 10
                br 4 (;@2;)
              else
                local.get 5
                local.set 9
                br 3 (;@3;)
              end
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 10
    end
    ref.cast (ref 8)
  )
  (func (;35;) (type 102) (param (ref 11) i32 i32)
    (local i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 1
    local.get 3
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      local.get 3
      i32.ge_u
    end
    if ;; label = @1
      unreachable
    else
      local.get 1
      local.get 2
      i32.eq
      if ;; label = @2
      else
        local.get 0
        local.get 1
        local.set 7
        local.set 6
        local.get 7
        local.get 6
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 6
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 7
        array.get 0
        local.set 4
        local.get 0
        local.get 2
        local.set 7
        local.set 6
        local.get 7
        local.get 6
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 6
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 7
        array.get 0
        local.set 5
        local.get 0
        local.get 1
        local.set 7
        local.get 5
        local.set 9
        local.set 6
        local.get 7
        local.get 6
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 6
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 7
        local.get 9
        array.set 0
        local.get 0
        local.get 2
        local.set 7
        local.get 4
        local.set 10
        local.set 6
        local.get 7
        local.get 6
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 6
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 7
        local.get 10
        array.set 0
      end
    end
  )
  (func (;36;) (type 103) (param (ref 11) (ref 11)) (result i32)
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
  )
  (func (;37;) (type 104) (param (ref 11) (ref 11)) (result i32)
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
    i32.eqz
  )
  (func (;38;) (type 105) (param (ref 11)) (result (ref 11))
    (local eqref eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.set 3
    local.get 3
    array.new_default 0
    local.set 4
    local.get 4
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    array.copy 0 0
    local.get 4
    local.get 3
    local.get 3
    struct.new 11
    local.set 1
    local.get 1
    ref.cast (ref 11)
    call 39
    local.get 1
    ref.cast (ref 11)
  )
  (func (;39;) (type 106) (param (ref 11))
    (local i32 eqref i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 1
    local.get 1
    i32.const 2
    i32.lt_u
    if ;; label = @1
    else
      local.get 0
      local.set 7
      local.get 7
      ref.cast (ref 11)
      struct.get 11 1
      local.set 8
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 8
      array.copy 0 0
      local.get 9
      local.get 8
      local.get 8
      struct.new 11
      local.set 2
      i32.const 1
      local.set 3
      i32.const 1
      local.set 4
      i32.const 1
      local.set 10
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 10
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 3
              local.get 1
              i32.lt_u
              if ;; label = @6
                local.get 4
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 11)
                  local.get 2
                  ref.cast (ref 11)
                  local.get 3
                  local.get 1
                  call 42
                else
                  local.get 2
                  ref.cast (ref 11)
                  local.get 0
                  ref.cast (ref 11)
                  local.get 3
                  local.get 1
                  call 42
                end
                local.get 4
                i32.eqz
                local.set 4
                local.get 3
                local.get 1
                i32.const 2
                i32.div_u
                i32.gt_u
                if ;; label = @7
                  local.get 1
                  local.set 3
                else
                  local.get 3
                  i32.const 2
                  i32.mul
                  local.set 3
                end
                i32.const 1
                local.set 10
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 1
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 4
      i32.eqz
      if ;; label = @2
        i32.const 0
        local.set 12
        block ;; label = @3
          loop ;; label = @4
            block ;; label = @5
              i32.const 1
              if ;; label = @6
                local.get 12
                local.set 5
                local.get 5
                local.get 1
                i32.lt_u
                if ;; label = @7
                  local.get 2
                  local.get 5
                  local.set 8
                  local.set 7
                  local.get 8
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 0)
                  local.get 8
                  array.get 0
                  local.set 6
                  local.get 0
                  local.get 5
                  local.set 8
                  local.get 6
                  local.set 11
                  local.set 7
                  local.get 8
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 0)
                  local.get 8
                  local.get 11
                  array.set 0
                  local.get 5
                  i32.const 1
                  i32.add
                  local.set 12
                  br 3 (;@4;)
                  br 2 (;@5;)
                end
              end
              i32.const 1
              if ;; label = @6
                call 1
                br 3 (;@3;)
                br 1 (;@5;)
              end
              unreachable
            end
            unreachable
          end
          unreachable
        end
      else
      end
    end
  )
  (func (;40;) (type 107) (param (ref 11)) (result (ref 11))
    (local eqref i32 i32 eqref i32 eqref i32 eqref)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    i32.const 0
    local.set 7
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 7
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 1
              ref.cast (ref 11)
              local.get 0
              local.get 3
              local.set 5
              local.set 4
              local.get 5
              local.get 4
              ref.cast (ref 11)
              struct.get 11 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 11)
              struct.get 11 0
              ref.cast (ref 5)
              local.get 5
              array.get 5
              ref.cast (ref 11)
              ref.cast (ref 11)
              call 41
              local.get 3
              i32.const 1
              i32.add
              local.set 7
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 1
            local.set 8
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
  )
  (func (;41;) (type 108) (param (ref 11) (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.add
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    array.new_default 0
    local.set 4
    local.get 4
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    array.copy 0 0
    local.get 4
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    array.copy 0 0
    local.get 2
    ref.cast (ref 11)
    local.get 4
    struct.set 11 0
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 1
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 2
  )
  (func (;42;) (type 109) (param (ref 11) (ref 11) i32 i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 0
    local.set 26
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 26
            local.set 4
            local.get 4
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.get 3
              local.get 4
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 4
                local.get 2
                i32.add
              end
              local.set 5
              local.get 2
              local.get 3
              local.get 5
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 5
                local.get 2
                i32.add
              end
              local.set 6
              local.get 4
              local.set 7
              local.get 5
              local.set 8
              local.get 4
              local.set 9
              i32.const 1
              local.set 21
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 21
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 7
                      local.get 5
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 8
                        local.get 6
                        i32.lt_u
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 0
                        local.get 7
                        local.set 17
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        array.get 0
                        local.set 10
                        local.get 0
                        local.get 8
                        local.set 17
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        array.get 0
                        local.set 11
                        local.get 11
                        local.get 10
                        i32.lt_s
                        if ;; label = @11
                          local.get 1
                          local.get 9
                          local.set 17
                          local.get 11
                          local.set 19
                          local.set 16
                          local.get 17
                          local.get 16
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 16
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 0)
                          local.get 17
                          local.get 19
                          array.set 0
                          local.get 8
                          i32.const 1
                          i32.add
                          local.set 8
                        else
                          local.get 1
                          local.get 9
                          local.set 17
                          local.get 10
                          local.set 20
                          local.set 16
                          local.get 17
                          local.get 16
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 16
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 0)
                          local.get 17
                          local.get 20
                          array.set 0
                          local.get 7
                          i32.const 1
                          i32.add
                          local.set 7
                        end
                        local.get 9
                        i32.const 1
                        i32.add
                        local.set 9
                        i32.const 1
                        local.set 21
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 7
              local.set 23
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 23
                      local.set 12
                      local.get 12
                      local.get 5
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 12
                        local.set 17
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        array.get 0
                        local.set 13
                        local.get 1
                        local.get 9
                        local.set 17
                        local.get 13
                        local.set 22
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        local.get 22
                        array.set 0
                        local.get 9
                        i32.const 1
                        i32.add
                        local.set 9
                        local.get 12
                        i32.const 1
                        i32.add
                        local.set 23
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 8
              local.set 25
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 25
                      local.set 14
                      local.get 14
                      local.get 6
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 14
                        local.set 17
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        array.get 0
                        local.set 15
                        local.get 1
                        local.get 9
                        local.set 17
                        local.get 15
                        local.set 24
                        local.set 16
                        local.get 17
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 16
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 17
                        local.get 24
                        array.set 0
                        local.get 9
                        i32.const 1
                        i32.add
                        local.set 9
                        local.get 14
                        i32.const 1
                        i32.add
                        local.set 25
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 6
              local.set 26
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;43;) (type 110) (param eqref eqref) (result i32)
    (local (ref 162) (ref 162) (ref 161) (ref 161) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 162)
    local.set 2
    local.get 1
    ref.cast (ref 162)
    local.set 3
    local.get 2
    struct.get 162 2
    local.tee 6
    local.get 3
    struct.get 162 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 162 0
    local.set 4
    local.get 3
    struct.get 162 0
    local.set 5
    local.get 2
    struct.get 162 1
    local.set 7
    local.get 3
    struct.get 162 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 161
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 161
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 161
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 161
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 161
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 161
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 11
        end
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 161
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 161
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;44;) (type 111) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 43
  )
  (func (;45;) (type 113) (param i32 eqref) (result i32)
    (local (ref 163) (ref 161) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 163)
    local.set 2
    local.get 2
    struct.get 163 0
    local.set 3
    local.get 2
    struct.get 163 1
    local.set 4
    local.get 2
    struct.get 163 2
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        local.get 5
        local.get 6
        i32.sub
        local.tee 7
        i32.const 65520
        i32.gt_u
        if ;; label = @3
          i32.const 65520
          local.set 7
        end
        i32.const 0
        local.set 8
        block ;; label = @3
          loop ;; label = @4
            local.get 8
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            local.get 6
            i32.add
            local.get 8
            i32.add
            local.set 9
            local.get 9
            i32.const 15
            i32.and
            i32.eqz
            local.get 8
            i32.const 64
            i32.add
            local.get 7
            i32.le_u
            i32.and
            if ;; label = @5
              i32.const 16
              local.get 8
              i32.add
              local.get 3
              local.get 9
              i32.const 4
              i32.shr_u
              array.get 161
              v128.store
              i32.const 16
              local.get 8
              i32.const 16
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 16
              i32.add
              i32.const 4
              i32.shr_u
              array.get 161
              v128.store
              i32.const 16
              local.get 8
              i32.const 32
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 32
              i32.add
              i32.const 4
              i32.shr_u
              array.get 161
              v128.store
              i32.const 16
              local.get 8
              i32.const 48
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 48
              i32.add
              i32.const 4
              i32.shr_u
              array.get 161
              v128.store
              local.get 8
              i32.const 64
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 8
            i32.const 16
            i32.add
            local.get 7
            i32.le_u
            if ;; label = @5
              local.get 9
              i32.const 15
              i32.and
              i32.eqz
              if ;; label = @6
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 161
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 161
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i8x16.swizzle
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                array.get 161
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i32.const 16
                i8x16.splat
                i8x16.sub
                i8x16.swizzle
                v128.or
                local.set 11
              end
              i32.const 16
              local.get 8
              i32.add
              local.get 11
              v128.store
              local.get 8
              i32.const 16
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 3
            local.get 9
            i32.const 4
            i32.shr_u
            array.get 161
            local.get 9
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.set 10
            i32.const 16
            local.get 8
            i32.add
            local.get 10
            i32.store8
            local.get 8
            i32.const 1
            i32.add
            local.set 8
            br 0 (;@4;)
          end
        end
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            local.get 13
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            i32.const 0
            i32.const 16
            local.get 13
            i32.add
            i32.store
            i32.const 4
            local.get 7
            local.get 13
            i32.sub
            i32.store
            local.get 0
            i32.const 0
            i32.const 1
            i32.const 8
            call 0
            i32.const 0
            i32.ne
            if ;; label = @5
              unreachable
            end
            i32.const 8
            i32.load
            local.tee 12
            i32.eqz
            local.get 12
            local.get 7
            local.get 13
            i32.sub
            i32.gt_u
            i32.or
            if ;; label = @5
              unreachable
            end
            local.get 13
            local.get 12
            i32.add
            local.set 13
            br 0 (;@4;)
          end
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 6
  )
  (func (;46;) (type 117) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;47;) (type 118) (param i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;48;) (type 119) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 3
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;49;) (type 120) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
  )
  (func (;50;) (type 121) (param i32 i32) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32)
    i32.const 2
    local.set 4
    local.get 4
    array.new_default 0
    i32.const 0
    local.get 4
    struct.new 11
    local.set 2
    local.get 2
    local.get 0
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    local.get 1
    local.set 7
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    ref.cast (ref 11)
  )
  (func (;51;) (type 122) (param (ref 8)) (result i32)
    (local i32 eqref i32)
    local.get 0
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
          unreachable
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
  (func (;52;) (type 123) (param (ref 8)) (result i32)
    (local i32 eqref i32)
    local.get 0
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
          unreachable
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
  (func (;53;) (type 124) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.mul
  )
  (func (;54;) (type 125) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;55;) (type 126) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    local.get 2
    i32.add
  )
  (func (;56;) (type 127) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;57;) (type 128) (param i32 i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
      i32.const 2
      i32.rem_u
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;58;) (type 129) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;59;) (type 130) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.ne
  )
  (func (;60;) (type 131) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.const 1
    i32.add
    i32.eq
  )
  (func (;61;) (type 132) (param i32) (result (ref 11))
    local.get 0
    local.get 0
    i32.const 10
    i32.add
    call 50
    ref.cast (ref 11)
  )
  (func (;62;) (type 133) (param i32) (result eqref)
    local.get 0
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
      array.new_fixed 161 1
      i32.const 0
      i32.const 3
      struct.new 162
    else
      local.get 0
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        v128.const i32x4 0x006f7774 0x00000000 0x00000000 0x00000000
        array.new_fixed 161 1
        i32.const 0
        i32.const 3
        struct.new 162
      else
        v128.const i32x4 0x6568746f 0x00000072 0x00000000 0x00000000
        array.new_fixed 161 1
        i32.const 0
        i32.const 5
        struct.new 162
      end
    end
  )
  (func (;63;) (type 134) (param i32 i32) (result i32)
    local.get 1
    i32.const 0
    i32.gt_s
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;64;) (type 135) (param (ref 115) i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
  )
  (func (;65;) (type 136) (param (ref 116) (ref 114) (ref 114)) (result i32)
    local.get 1
    ref.cast (ref 114)
    struct.get 114 0
    local.get 2
    ref.cast (ref 114)
    struct.get 114 0
    i32.lt_s
  )
  (func (;66;) (type 137) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 5
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;67;) (type 138) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 44
  )
  (func (;68;) (type 139) (param (ref 114)) (result i32)
    local.get 0
    ref.cast (ref 114)
    struct.get 114 0
  )
  (func (;69;) (type 140) (param (ref 114)) (result i32)
    local.get 0
    ref.cast (ref 114)
    struct.get 114 1
  )
  (func (;70;) (type 141)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref eqref i32 eqref i32)
    call 46
    local.set 0
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x2077656e 0x676e656c 0x00006874 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 0
    i32.eq
    v128.const i32x4 0x2077656e 0x61706163 0x79746963 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 5
    v128.const i32x4 0x2077656e 0x74706d65 0x00000079 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 6
    local.set 3
    block ;; label = @1
      local.get 3
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 4
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    v128.const i32x4 0x2077656e 0x73726966 0x00000074 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 7
    local.set 5
    block ;; label = @1
      local.get 5
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 6
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 6
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 6
    v128.const i32x4 0x2077656e 0x7473616c 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    call 8
    local.set 7
    block ;; label = @1
      local.get 7
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 8
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
    v128.const i32x4 0x2077656e 0x7a207461 0x006f7265 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const -1
    call 8
    local.set 9
    block ;; label = @1
      local.get 9
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 10
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    v128.const i32x4 0x2077656e 0x6e207461 0x74616765 0x00657669
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    call 47
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x65736572 0x64657672 0x6e656c20 0x00687467
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 7
    i32.eq
    v128.const i32x4 0x65736572 0x64657672 0x70616320 0x74696361
    v128.const i32x4 0x00000079 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5
    i32.const 9
    call 9
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x656b616d 0x6e656c20 0x00687467 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 5
    i32.eq
    v128.const i32x4 0x656b616d 0x70616320 0x74696361 0x00000079
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 0
    local.set 12
    local.set 11
    local.get 12
    local.get 11
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 12
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x656b616d 0x72696620 0x00007473 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 2
    local.set 12
    local.set 11
    local.get 12
    local.get 11
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 12
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x656b616d 0x64696d20 0x00656c64 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 4
    local.set 12
    local.set 11
    local.get 12
    local.get 11
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 12
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x656b616d 0x73616c20 0x00000074 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    call 6
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x73726966 0x61762074 0x0065756c 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    call 7
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x7473616c 0x6c617620 0x00006575 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const 0
    call 8
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x66207461 0x74737269 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const 4
    call 8
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x6c207461 0x00747361 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 7
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const -1
    call 8
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x6e207461 0x74616765 0x20657669 0x00656e6f
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const -5
    call 8
    call 51
    i32.const 9
    i32.eq
    v128.const i32x4 0x6e207461 0x74616765 0x20657669 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const 5
    call 8
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
    v128.const i32x4 0x70207461 0x7469736f 0x20657669 0x2074756f
    v128.const i32x4 0x7220666f 0x65676e61 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 24
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    i32.const -6
    call 8
    local.set 16
    block ;; label = @1
      local.get 16
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 17
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 17
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 17
    v128.const i32x4 0x6e207461 0x74616765 0x20657669 0x2074756f
    v128.const i32x4 0x7220666f 0x65676e61 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 24
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;71;) (type 142)
    (local eqref eqref eqref eqref i32 eqref i32 i32 i32)
    call 49
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    i32.const 20
    local.set 6
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    local.get 6
    array.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 20
    i32.eq
    v128.const i32x4 0x61696c61 0x6e692073 0x65786564 0x756d2064
    v128.const i32x4 0x69746174 0x00006e6f 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 22
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 10
    local.set 1
    local.get 0
    ref.cast (ref 11)
    call 11
    local.set 2
    local.get 1
    i32.const 0
    local.set 4
    i32.const 100
    local.set 7
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    local.get 7
    array.set 0
    local.get 2
    i32.const 4
    local.set 4
    i32.const 500
    local.set 8
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    local.get 8
    array.set 0
    local.get 0
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x79706f63 0x656f6420 0x6f6e2073 0x756d2074
    v128.const i32x4 0x65746174 0x756f7320 0x20656372 0x73726966
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 3
    i32.const 0
    i32.const 33
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x6e6f6c63 0x6f642065 0x6e207365 0x6d20746f
    v128.const i32x4 0x74617475 0x6f732065 0x65637275 0x73616c20
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 3
    i32.const 0
    i32.const 33
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 100
    i32.eq
    v128.const i32x4 0x79706f63 0x6e776f20 0x69662073 0x00747372
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 4
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 500
    i32.eq
    v128.const i32x4 0x6e6f6c63 0x776f2065 0x6c20736e 0x00747361
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.eq
    v128.const i32x4 0x79706f63 0x61786520 0x63207463 0x63617061
    v128.const i32x4 0x00797469 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.eq
    v128.const i32x4 0x6e6f6c63 0x78652065 0x20746361 0x61706163
    v128.const i32x4 0x79746963 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;72;) (type 143)
    (local eqref i32 eqref i32 eqref i32)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    local.set 1
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    call 12
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    local.get 1
    i32.eq
    v128.const i32x4 0x65736572 0x20657672 0x6f72657a 0x2d6f6e20
    v128.const i32x4 0x0000706f 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 20
    call 12
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 25
    i32.ge_u
    v128.const i32x4 0x65736572 0x20657672 0x69646461 0x6e6f6974
    v128.const i32x4 0x63206c61 0x63617061 0x00797469 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 27
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x65736572 0x20657672 0x676e656c 0x00006874
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x65736572 0x20657672 0x73726966 0x00000074
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x65736572 0x20657672 0x7473616c 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 3
    call 13
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x6e757274 0x65746163 0x6e656c20 0x00687467
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x6e757274 0x65746163 0x72696620 0x00007473
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x6e757274 0x65746163 0x6e696620 0x6c206c61
    v128.const i32x4 0x00657669 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    local.set 1
    local.get 0
    ref.cast (ref 11)
    i32.const 3
    call 13
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    local.get 1
    i32.eq
    v128.const i32x4 0x6e757274 0x65746163 0x6d617320 0x72702065
    v128.const i32x4 0x72657365 0x20736576 0x61706163 0x79746963
    array.new_fixed 161 2
    i32.const 0
    i32.const 32
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 14
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 3
    i32.eq
    v128.const i32x4 0x69726873 0x65206b6e 0x74636178 0x70616320
    v128.const i32x4 0x74696361 0x00000079 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x69726873 0x6c206b6e 0x74676e65 0x00000068
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x61656c63 0x656c2072 0x6874676e 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 3
    i32.eq
    v128.const i32x4 0x61656c63 0x61632072 0x69636170 0x00007974
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 14
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x68732079 0x6b6e6972 0x70616320
    v128.const i32x4 0x74696361 0x00000079 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 42
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x68737570 0x74666120 0x65207265 0x7974706d
    v128.const i32x4 0x72687320 0x006b6e69 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;73;) (type 144)
    (local eqref eqref i32 eqref)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 9
    i32.const 2
    i32.const 2
    call 15
    local.get 0
    ref.cast (ref 11)
    call 49
    call 16
    v128.const i32x4 0x74706d65 0x69662079 0x6e206c6c 0x706f2d6f
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 7
    i32.const 1
    i32.const 4
    call 15
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x74726170 0x206c6169 0x6c6c6966 0x65727020
    v128.const i32x4 0x00786966 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x74726170 0x206c6169 0x6c6c6966 0x72696620
    v128.const i32x4 0x00007473 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x74726170 0x206c6169 0x6c6c6966 0x64696d20
    v128.const i32x4 0x00656c64 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x74726170 0x206c6169 0x6c6c6966 0x6e696620
    v128.const i32x4 0x00006c61 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x74726170 0x206c6169 0x6c6c6966 0x66757320
    v128.const i32x4 0x00786966 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 8
    i32.const 0
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    call 15
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x6c6c7566 0x6c696620 0x6966206c 0x00747372
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x6c6c7566 0x6c696620 0x696d206c 0x656c6464
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x6c6c7566 0x6c696620 0x616c206c 0x00007473
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;74;) (type 145)
    (local eqref eqref i32 eqref)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 0
    i32.const 4
    call 17
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x68676972 0x766f2074 0x616c7265 0x72702070
    v128.const i32x4 0x78696665 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x68676972 0x766f2074 0x616c7265 0x6e6f2070
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x68676972 0x766f2074 0x616c7265 0x77742070
    v128.const i32x4 0x0000006f 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x68676972 0x766f2074 0x616c7265 0x68742070
    v128.const i32x4 0x00656572 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x68676972 0x766f2074 0x616c7265 0x6f662070
    v128.const i32x4 0x00007275 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    i32.const 1
    i32.const 5
    call 17
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x7466656c 0x65766f20 0x70616c72 0x72657a20
    v128.const i32x4 0x0000006f 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x7466656c 0x65766f20 0x70616c72 0x656e6f20
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x7466656c 0x65766f20 0x70616c72 0x6f777420
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x7466656c 0x65766f20 0x70616c72 0x72687420
    v128.const i32x4 0x00006565 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x7466656c 0x65766f20 0x70616c72 0x66757320
    v128.const i32x4 0x00786966 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 2
    i32.const 2
    i32.const 5
    call 17
    local.get 0
    ref.cast (ref 11)
    call 49
    call 16
    v128.const i32x4 0x656d6173 0x6e617220 0x63206567 0x0079706f
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 5
    i32.const 5
    i32.const 5
    call 17
    local.get 0
    ref.cast (ref 11)
    call 49
    call 16
    v128.const i32x4 0x74706d65 0x6e652079 0x6f632064 0x00007970
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;75;) (type 146)
    (local eqref eqref eqref eqref eqref eqref i32 eqref i32)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 2
    i32.const 2
    call 18
    local.set 1
    local.get 1
    ref.cast (ref 11)
    call 5
    v128.const i32x4 0x74706d65 0x6c732079 0x00656369 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x6c732079 0x20656369 0x61706163
    v128.const i32x4 0x79746963 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 4
    call 18
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x6464696d 0x7320656c 0x6563696c 0x6e656c20
    v128.const i32x4 0x00687467 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 0
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x6464696d 0x7320656c 0x6563696c 0x72696620
    v128.const i32x4 0x00007473 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 1
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x6464696d 0x7320656c 0x6563696c 0x64696d20
    v128.const i32x4 0x00656c64 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 2
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x6464696d 0x7320656c 0x6563696c 0x73616c20
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 0
    local.set 6
    i32.const 20
    local.set 8
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    local.get 8
    array.set 0
    local.get 0
    i32.const 1
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x63696c73 0x73692065 0x646e6920 0x6e657065
    v128.const i32x4 0x746e6564 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 6
    i32.const 7
    call 50
    call 19
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x636e6f63 0x6c207461 0x74676e65 0x00000068
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 0
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x636e6f63 0x66207461 0x74737269 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 4
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x636e6f63 0x62207461 0x646e756f 0x20797261
    v128.const i32x4 0x7466656c 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 5
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 6
    i32.eq
    v128.const i32x4 0x636e6f63 0x62207461 0x646e756f 0x20797261
    v128.const i32x4 0x68676972 0x00000074 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 6
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x636e6f63 0x6c207461 0x00747361 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x636e6f63 0x73207461 0x6372756f 0x6e752065
    v128.const i32x4 0x6e616863 0x00646567 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 6
    i32.const 7
    call 50
    call 20
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x65747865 0x6c20646e 0x74676e65 0x00000068
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 5
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 6
    i32.eq
    v128.const i32x4 0x65747865 0x6620646e 0x74737269 0x64646120
    v128.const i32x4 0x00006465 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 6
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x65747865 0x6620646e 0x6c616e69 0x64646120
    v128.const i32x4 0x00006465 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 46
    call 21
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x65747865 0x6520646e 0x7974706d 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8
    i32.const 9
    call 50
    local.set 4
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    call 20
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x666c6573 0x74786520 0x20646e65 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    i32.const 0
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x666c6573 0x74786520 0x20646e65 0x6f72657a
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    i32.const 1
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x666c6573 0x74786520 0x20646e65 0x00656e6f
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    i32.const 2
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x666c6573 0x74786520 0x20646e65 0x006f7774
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    i32.const 3
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 6
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x666c6573 0x74786520 0x20646e65 0x65726874
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;76;) (type 147)
    (local eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 eqref i32 i32)
    call 46
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 22
    local.set 2
    block ;; label = @1
      local.get 2
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 3
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    v128.const i32x4 0x74706d65 0x68732079 0x00746669 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 16
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 7
      local.get 4
      ref.cast (ref 11)
      local.get 5
      struct.set 11 1
      i32.const 1
      local.set 16
      local.get 7
      drop
    end
    block ;; label = @1
      local.get 16
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
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
    v128.const i32x4 0x74706d65 0x6f702079 0x00000070 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    call 23
    local.set 10
    block ;; label = @1
      local.get 10
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 11
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    v128.const i32x4 0x74706d65 0x65722079 0x65766f6d 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 9
    call 24
    i32.eqz
    v128.const i32x4 0x65736e69 0x62207472 0x6e6f7965 0x6d652064
    v128.const i32x4 0x00797470 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 2
    call 25
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    call 25
    i32.const 4
    local.set 12
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      array.new_default 0
      local.set 6
      local.get 6
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      struct.set 11 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 12
    array.set 0
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    i32.const 2
    i32.const 3
    call 24
    v128.const i32x4 0x65736e69 0x6d207472 0x6c646469 0x00000065
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 5
    call 24
    v128.const i32x4 0x65736e69 0x65207472 0x0000646e 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x6e656c20 0x00687467
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x72657a20 0x0000006f
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x656e6f20 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x6f777420 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x72687420 0x00006565
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x65736e69 0x64657472 0x756f6620 0x00000072
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 22
    call 51
    i32.const 1
    i32.eq
    v128.const i32x4 0x66696873 0x61762074 0x0065756c 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    call 23
    call 51
    i32.const 3
    i32.eq
    v128.const i32x4 0x6f6d6572 0x6d206576 0x6c646469 0x61762065
    v128.const i32x4 0x0065756c 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.sub
    call 23
    call 51
    i32.const 5
    i32.eq
    v128.const i32x4 0x6f6d6572 0x65206576 0x7620646e 0x65756c61
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 13
      local.get 4
      ref.cast (ref 11)
      local.get 5
      struct.set 11 1
      i32.const 1
      local.get 13
      struct.new 9
    end
    local.set 1
    local.get 1
    ref.cast (ref 8)
    call 51
    i32.const 4
    i32.eq
    v128.const i32x4 0x20706f70 0x756c6176 0x00000065 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x6174756d 0x6e6f6974 0x6e696620 0x6c206c61
    v128.const i32x4 0x74676e65 0x00000068 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 5
    local.get 0
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 5
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x6174756d 0x6e6f6974 0x6e696620 0x76206c61
    v128.const i32x4 0x65756c61 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    call 23
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
    v128.const i32x4 0x6f6d6572 0x65206576 0x6f20646e 0x6f207475
    v128.const i32x4 0x61722066 0x0065676e 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;77;) (type 148)
    (local eqref eqref eqref i32 eqref)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 26
    local.set 1
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x72756f73
    v128.const i32x4 0x66206563 0x74737269 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 24
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x72756f73
    v128.const i32x4 0x6c206563 0x00747361 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x73726966
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x6f636573
    v128.const i32x4 0x0000646e 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x6464696d
    v128.const i32x4 0x0000656c 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 3
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x72756f66
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x725f6f74 0x72657665 0x20646573 0x7473616c
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 27
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
    v128.const i32x4 0x65766572 0x20657372 0x6374616d 0x20736568
    v128.const i32x4 0x756d6d69 0x6c626174 0x65722065 0x73726576
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 3
    i32.const 0
    i32.const 33
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 46
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 27
    local.get 0
    ref.cast (ref 11)
    call 5
    v128.const i32x4 0x65766572 0x20657372 0x74706d65 0x00000079
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 9
    call 9
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 27
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x65766572 0x20657372 0x00656e6f 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;78;) (type 149)
    (local eqref eqref eqref i32 eqref)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 2
    i32.const 4
    i32.const 9
    call 9
    call 28
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x6f6d6572
    v128.const i32x4 0x20646576 0x676e656c 0x00006874 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 26
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x6f6d6572
    v128.const i32x4 0x20646576 0x73726966 0x00000074 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 25
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x6f6d6572
    v128.const i32x4 0x20646576 0x6f636573 0x0000646e 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 26
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x66657270
    v128.const i32x4 0x00007869 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x65736e69
    v128.const i32x4 0x6f207472 0x0000656e 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 22
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x65736e69
    v128.const i32x4 0x66207472 0x0072756f 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x6c696174
    v128.const i32x4 0x656e6f20 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 6
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x776f7267 0x6c707320 0x20656369 0x6c696174
    v128.const i32x4 0x6f777420 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 3
    i32.const 8
    i32.const 9
    call 50
    call 28
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x69726873 0x72206b6e 0x766f6d65 0x6c206465
    v128.const i32x4 0x74676e65 0x00000068 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x69726873 0x72206b6e 0x766f6d65 0x66206465
    v128.const i32x4 0x74737269 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x69726873 0x72206b6e 0x766f6d65 0x6c206465
    v128.const i32x4 0x00747361 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x69726873 0x73206b6e 0x63696c70 0x656c2065
    v128.const i32x4 0x6874676e 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x69726873 0x70206b6e 0x69666572 0x00000078
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x69726873 0x69206b6e 0x7265736e 0x69662074
    v128.const i32x4 0x00747372 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x69726873 0x69206b6e 0x7265736e 0x65732074
    v128.const i32x4 0x646e6f63 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x69726873 0x74206b6e 0x006c6961 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    i32.const 99
    call 46
    call 28
    local.set 1
    local.get 1
    ref.cast (ref 11)
    call 49
    call 16
    v128.const i32x4 0x656c6564 0x61206574 0x72206c6c 0x766f6d65
    v128.const i32x4 0x00006465 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 5
    v128.const i32x4 0x656c6564 0x61206574 0x73206c6c 0x6372756f
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.const 6
    i32.const 7
    call 50
    call 28
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x696c7073 0x61206563 0x6e657070 0x656c2064
    v128.const i32x4 0x6874676e 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 6
    i32.eq
    v128.const i32x4 0x696c7073 0x61206563 0x6e657070 0x69662064
    v128.const i32x4 0x00747372 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 6
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x696c7073 0x61206563 0x6e657070 0x65732064
    v128.const i32x4 0x646e6f63 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 20
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 2
    call 50
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 0
    local.get 0
    ref.cast (ref 11)
    call 28
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x61696c61 0x70732073 0x6563696c 0x6e656c20
    v128.const i32x4 0x00687467 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x61696c61 0x70732073 0x6563696c 0x72657a20
    v128.const i32x4 0x0000006f 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x61696c61 0x70732073 0x6563696c 0x656e6f20
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x61696c61 0x70732073 0x6563696c 0x6f777420
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x61696c61 0x70732073 0x6563696c 0x72687420
    v128.const i32x4 0x00006565 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;79;) (type 150)
    (local eqref eqref eqref i32 eqref)
    call 49
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    i32.const 3
    i32.const 8
    i32.const 9
    call 50
    call 29
    local.set 1
    local.get 0
    ref.cast (ref 11)
    call 49
    call 16
    v128.const i32x4 0x735f6f74 0x63696c70 0x73206465 0x6372756f
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x735f6f74 0x63696c70 0x6c206465 0x74676e65
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x735f6f74 0x63696c70 0x70206465 0x69666572
    v128.const i32x4 0x00000078 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 8
    i32.eq
    v128.const i32x4 0x735f6f74 0x63696c70 0x66206465 0x74737269
    v128.const i32x4 0x736e6920 0x00747265 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x735f6f74 0x63696c70 0x73206465 0x6e6f6365
    v128.const i32x4 0x6e692064 0x74726573 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 24
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 3
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x735f6f74 0x63696c70 0x73206465 0x69666675
    v128.const i32x4 0x00000078 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;80;) (type 151)
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 eqref i32)
    call 46
    local.set 0
    local.get 0
    i32.const 4
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 4
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 4
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    call 30
    v128.const i32x4 0x6c636e69 0x73656475 0x65727020 0x746e6573
    array.new_fixed 161 1
    i32.const 0
    i32.const 16
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 9
    call 30
    i32.eqz
    v128.const i32x4 0x6c636e69 0x73656475 0x73626120 0x00746e65
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    call 31
    call 52
    i32.const 0
    i32.eq
    v128.const i32x4 0x65646e69 0x666f5f78 0x72696620 0x00007473
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 1
    call 32
    call 52
    i32.const 2
    i32.eq
    v128.const i32x4 0x65646e69 0x666f5f78 0x6f726620 0x0000006d
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 5
    call 32
    local.set 9
    block ;; label = @1
      local.get 9
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 10
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    v128.const i32x4 0x65646e69 0x666f5f78 0x20746120 0x00646e65
    array.new_fixed 161 1
    i32.const 0
    i32.const 15
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 6
    call 32
    local.set 11
    block ;; label = @1
      local.get 11
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
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
    v128.const i32x4 0x65646e69 0x666f5f78 0x79656220 0x20646e6f
    v128.const i32x4 0x00646e65 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 19
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    call 33
    call 52
    i32.const 4
    i32.eq
    v128.const i32x4 0x7473616c 0x646e695f 0x6f5f7865 0x616c2066
    v128.const i32x4 0x00007473 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 4
    call 34
    call 52
    i32.const 2
    i32.eq
    v128.const i32x4 0x7473616c 0x646e695f 0x62207865 0x726f6665
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 17
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 0
    call 34
    local.set 13
    block ;; label = @1
      local.get 13
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 14
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 14
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 14
    v128.const i32x4 0x7473616c 0x646e6920 0x65207865 0x7974706d
    v128.const i32x4 0x65727020 0x00786966 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 23
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 4
    i32.const 6
    call 34
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
    v128.const i32x4 0x7473616c 0x646e6920 0x69207865 0x6c61766e
    v128.const i32x4 0x65206469 0x0000646e 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 22
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;81;) (type 152)
    (local eqref eqref eqref eqref i32 eqref i32)
    call 49
    local.set 0
    call 49
    local.set 1
    call 49
    local.set 2
    local.get 2
    ref.cast (ref 11)
    i32.const 0
    i32.const 1
    call 35
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
    v128.const i32x4 0x61757165 0x7320736c 0x20656d61 0x756c6176
    v128.const i32x4 0x00007365 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 18
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 36
    v128.const i32x4 0x73207145 0x20656d61 0x756c6176 0x00007365
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 37
    i32.eqz
    v128.const i32x4 0x7320654e 0x20656d61 0x756c6176 0x00007365
    array.new_fixed 161 1
    i32.const 0
    i32.const 14
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    call 16
    i32.eqz
    v128.const i32x4 0x61757165 0x6f20736c 0x72656472 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    call 37
    v128.const i32x4 0x6f20654e 0x72656472 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 6
      local.get 3
      ref.cast (ref 11)
      local.get 4
      struct.set 11 1
      i32.const 1
      local.get 6
      struct.new 9
    end
    drop
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
    i32.eqz
    v128.const i32x4 0x61757165 0x6c20736c 0x74676e65 0x00000068
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 36
    i32.eqz
    v128.const i32x4 0x6c207145 0x74676e65 0x00000068 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;82;) (type 153)
    (local eqref eqref eqref i32 eqref i32 i32 i32 i32 i32 i32)
    call 46
    local.set 0
    local.get 0
    i32.const 5
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 1
    local.set 6
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 8
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    local.set 9
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 9
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 10
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    call 38
    local.set 1
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x735f6f74 0x6574726f 0x6f732064 0x65637275
    v128.const i32x4 0x72696620 0x00007473 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 22
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x735f6f74 0x6574726f 0x6f732064 0x65637275
    v128.const i32x4 0x73616c20 0x00000074 0x00000000 0x00000000
    array.new_fixed 161 2
    i32.const 0
    i32.const 21
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x74726f73 0x7a206465 0x006f7265 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x74726f73 0x6f206465 0x0000656e 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x74726f73 0x74206465 0x00006f77 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 3
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x74726f73 0x74206465 0x65657268 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 12
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x74726f73 0x66206465 0x0072756f 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x74726f73 0x66206465 0x00657669 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 39
    local.get 0
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    call 16
    v128.const i32x4 0x702d6e69 0x6563616c 0x726f7320 0x00000074
    array.new_fixed 161 1
    i32.const 0
    i32.const 13
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 46
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 39
    local.get 0
    ref.cast (ref 11)
    call 5
    v128.const i32x4 0x74726f73 0x706d6520 0x00007974 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 7
    call 9
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 39
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x74726f73 0x656e6f20 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;83;) (type 154)
    (local eqref eqref i32 eqref eqref eqref eqref)
    call 48
    local.set 0
    local.get 0
    i32.const 1
    i32.const 2
    call 50
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 5
      local.set 3
      local.get 3
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 5
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    call 46
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 5
      local.set 3
      local.get 3
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 5
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    i32.const 4
    call 50
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 5
      local.set 3
      local.get 3
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 5
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    call 40
    local.set 0
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x74616c66 0x6e656c20 0x00687467 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 11
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x74616c66 0x72657a20 0x0000006f 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 9
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x74616c66 0x656e6f20 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x74616c66 0x6f777420 0x00000000 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 8
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x74616c66 0x72687420 0x00006565 0x00000000
    array.new_fixed 161 1
    i32.const 0
    i32.const 10
    struct.new 162
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;84;) (type 155)
    call 70
    call 71
    call 72
    call 73
    call 74
    call 75
    call 76
    call 77
    call 78
    call 79
    call 80
    call 81
    call 82
    call 83
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x656d2d79 0x646f6874 0x75722d73 0x6d69746e
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 161 3
    i32.const 0
    i32.const 33
    struct.new 163
    call 45
    drop
  )
)
