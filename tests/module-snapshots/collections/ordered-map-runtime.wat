(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (struct))
  (type (;4;) (func (result (ref 3))))
  (type (;5;) (func (param (ref 3) eqref eqref) (result (ref 2))))
  (type (;6;) (func (param (ref 3) i32 i32) (result (ref 2))))
  (type (;7;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;9;) (struct (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field (ref 7)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;10;) (struct (field (ref 9)) (field (ref 7)) (field (ref 0)) (field i32)))
  (type (;11;) (func))
  (type (;12;) (func (param i32) (result (ref 7))))
  (type (;13;) (func (param i32) (result (ref 7))))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param (ref 9)) (result i32)))
  (type (;16;) (func (param (ref 9) i32)))
  (type (;17;) (func (param (ref 9)) (result i32)))
  (type (;18;) (func (param (ref 9) i32)))
  (type (;19;) (func (param (ref 9) i32) (result i32)))
  (type (;20;) (func (param (ref 9) i32) (result i32)))
  (type (;21;) (func (param (ref 9) i32) (result i32)))
  (type (;22;) (func (param (ref 9) i32) (result i32)))
  (type (;23;) (func (param (ref 9) i32 i32)))
  (type (;24;) (func (param (ref 9) i32 i32)))
  (type (;25;) (func (param (ref 9) i32 i32)))
  (type (;26;) (func (param (ref 9) i32 i32)))
  (type (;27;) (func (param (ref 9) i32) (result eqref)))
  (type (;28;) (func (param (ref 9) i32) (result eqref)))
  (type (;29;) (func (param (ref 9) i32) (result (ref 8))))
  (type (;30;) (func (param eqref) (result (ref 9))))
  (type (;31;) (func (param (ref 9)) (result i32)))
  (type (;32;) (func (param (ref 9)) (result i32)))
  (type (;33;) (func (param (ref 9) eqref i32) (result (ref 2))))
  (type (;34;) (func (param (ref 9) eqref) (result i32)))
  (type (;35;) (func (param (ref 9) i32) (result i32)))
  (type (;36;) (func (param (ref 9) i32) (result i32)))
  (type (;37;) (func (param (ref 9) i32) (result i32)))
  (type (;38;) (func (param (ref 9) i32) (result i32)))
  (type (;39;) (func (param (ref 9) i32)))
  (type (;40;) (func (param (ref 9) i32)))
  (type (;41;) (func (param (ref 9) i32)))
  (type (;42;) (func (param (ref 9) eqref eqref) (result i32)))
  (type (;43;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;44;) (func (param (ref 9) eqref) (result i32)))
  (type (;45;) (func (param (ref 9) i32 i32)))
  (type (;46;) (func (param (ref 9) i32 i32)))
  (type (;47;) (func (param (ref 9) eqref) (result i32)))
  (type (;48;) (func (param (ref 9)) (result (ref 0))))
  (type (;49;) (func (param (ref 9)) (result (ref 0))))
  (type (;50;) (func (param (ref 9) eqref i32) (result i32)))
  (type (;51;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;52;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;53;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;54;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;55;) (func (param (ref 8)) (result eqref)))
  (type (;56;) (func (param (ref 8)) (result eqref)))
  (type (;57;) (func (param (ref 9))))
  (type (;58;) (func (param (ref 9) (ref 0) i32) (result i32)))
  (type (;59;) (func (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;60;) (func (param (ref 9)) (result (ref 10))))
  (type (;61;) (func (param (ref 10)) (result i32)))
  (type (;62;) (func (param (ref 10)) (result (ref 8))))
  (type (;63;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;64;) (func (param (ref 8)) (result i32)))
  (type (;65;) (func (param eqref) (result (ref 9))))
  (type (;66;) (func (param (ref 9)) (result i32)))
  (type (;67;) (func (param (ref 9) i32) (result i32)))
  (type (;68;) (func (param (ref 9) i32 i32) (result i32)))
  (type (;69;) (func (param (ref 9)) (result i32)))
  (type (;70;) (func (param (ref 9) i32) (result i32)))
  (type (;71;) (func (param (ref 9)) (result (ref 0))))
  (type (;72;) (func (param (ref 9)) (result (ref 0))))
  (type (;73;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;74;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;75;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;76;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;77;) (func (param (ref 9)) (result (ref 10))))
  (type (;78;) (func (param (ref 10)) (result i32)))
  (type (;79;) (func (param (ref 10)) (result (ref 8))))
  (type (;80;) (func (param (ref 8)) (result i32)))
  (type (;81;) (func (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;82;) (func (param (ref 9))))
  (type (;83;) (func (param (ref 9) i32) (result i32)))
  (type (;84;) (func (param (ref 9) i32) (result i32)))
  (type (;85;) (func (param (ref 9)) (result i32)))
  (type (;86;) (func (param (ref 9) i32) (result i32)))
  (type (;87;) (func (param (ref 9) i32) (result i32)))
  (type (;88;) (func (param (ref 9) i32) (result i32)))
  (type (;89;) (func (param (ref 9) i32) (result i32)))
  (type (;90;) (func (param (ref 9) i32 i32)))
  (type (;91;) (func (param (ref 9) i32) (result i32)))
  (type (;92;) (func (param (ref 9) i32 i32)))
  (type (;93;) (func (param (ref 9) i32 i32)))
  (type (;94;) (func (param (ref 9) i32 i32)))
  (type (;95;) (func (param (ref 9) i32 i32)))
  (type (;96;) (func (param (ref 9) i32)))
  (type (;97;) (func (param (ref 9) i32 i32)))
  (type (;98;) (func (param (ref 9)) (result i32)))
  (type (;99;) (func (param (ref 9) i32 i32) (result (ref 2))))
  (type (;100;) (func (param (ref 9) i32)))
  (type (;101;) (func (param (ref 9) i32)))
  (type (;102;) (func (param (ref 9) i32) (result (ref 8))))
  (type (;103;) (func (param (ref 9) i32) (result i32)))
  (type (;104;) (func (param (ref 9) i32 i32) (result i32)))
  (type (;105;) (func (param (ref 9) i32) (result i32)))
  (type (;106;) (func (param (ref 9) i32) (result i32)))
  (type (;107;) (func (param (ref 9) i32) (result i32)))
  (type (;108;) (func (param (ref 9) (ref 0) i32) (result i32)))
  (type (;109;) (func (param (ref 9) i32)))
  (type (;110;) (func (param (ref 9) i32)))
  (type (;111;) (struct (field (ref 9))))
  (type (;112;) (func (param eqref) (result (ref 111))))
  (type (;113;) (func (param (ref 111)) (result i32)))
  (type (;114;) (func (param (ref 111)) (result i32)))
  (type (;115;) (func (param (ref 111) eqref eqref) (result i32)))
  (type (;116;) (func (param (ref 111) eqref eqref)))
  (type (;117;) (func (param (ref 111) eqref) (result (ref 0))))
  (type (;118;) (func (param (ref 111) eqref) (result i32)))
  (type (;119;) (func (param (ref 111) eqref) (result i32)))
  (type (;120;) (func (param (ref 111))))
  (type (;121;) (func (param (ref 111)) (result (ref 0))))
  (type (;122;) (func (param (ref 111)) (result (ref 0))))
  (type (;123;) (func (param (ref 111) eqref) (result (ref 0))))
  (type (;124;) (func (param (ref 111) eqref) (result (ref 0))))
  (type (;125;) (func (param (ref 111) eqref) (result (ref 0))))
  (type (;126;) (func (param (ref 111) eqref) (result (ref 0))))
  (type (;127;) (func (param (ref 8)) (result eqref)))
  (type (;128;) (func (param (ref 8)) (result eqref)))
  (type (;129;) (func (param (ref 111)) (result (ref 10))))
  (type (;130;) (func (param (ref 111) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;131;) (func (param (ref 10)) (result i32)))
  (type (;132;) (func (param (ref 10)) (result (ref 8))))
  (type (;133;) (func (param (ref 111) i32) (result (ref 0))))
  (type (;134;) (func (param (ref 8)) (result i32)))
  (type (;135;) (func (param eqref) (result (ref 111))))
  (type (;136;) (func (param (ref 111)) (result i32)))
  (type (;137;) (func (param (ref 111) i32) (result i32)))
  (type (;138;) (func (param (ref 111) i32 i32) (result i32)))
  (type (;139;) (func (param (ref 111) i32 i32)))
  (type (;140;) (func (param (ref 111)) (result i32)))
  (type (;141;) (func (param (ref 111) i32) (result i32)))
  (type (;142;) (func (param (ref 111)) (result (ref 0))))
  (type (;143;) (func (param (ref 111)) (result (ref 0))))
  (type (;144;) (func (param (ref 111) i32) (result (ref 0))))
  (type (;145;) (func (param (ref 111) i32) (result (ref 0))))
  (type (;146;) (func (param (ref 111) i32) (result (ref 0))))
  (type (;147;) (func (param (ref 111) i32) (result (ref 0))))
  (type (;148;) (func (param (ref 111)) (result (ref 10))))
  (type (;149;) (func (param (ref 10)) (result i32)))
  (type (;150;) (func (param (ref 10)) (result (ref 8))))
  (type (;151;) (func (param (ref 8)) (result i32)))
  (type (;152;) (func (param (ref 111) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;153;) (func (param (ref 111))))
  (type (;154;) (func))
  (type (;155;) (func (param (ref 111) i32 i32) (result i32)))
  (type (;156;) (func (param (ref 0) i32) (result i32)))
  (type (;157;) (func))
  (type (;158;) (array (mut v128)))
  (type (;159;) (struct (field (ref 158)) (field i32) (field i32)))
  (type (;160;) (struct (field (ref 158)) (field i32) (field i32)))
  (type (;161;) (struct (field (ref 158)) (field i32) (field i32)))
  (type (;162;) (struct (field (mut (ref 158))) (field (mut i32)) (field (mut i32))))
  (type (;163;) (struct (field (mut (ref 158))) (field (mut i32)) (field (mut i32))))
  (type (;164;) (array (mut i32)))
  (type (;165;) (array (mut i64)))
  (type (;166;) (array (mut f32)))
  (type (;167;) (array (mut f64)))
  (type (;168;) (array (mut v128)))
  (type (;169;) (array (mut eqref)))
  (export "main" (func 78))
  (func (;0;) (type 4) (result (ref 3))
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;1;) (type 6) (param (ref 3) i32 i32) (result (ref 2))
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
  (func (;2;) (type 11))
  (func (;3;) (type 12) (param i32) (result (ref 7))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 164
    i32.const 0
    local.get 3
    struct.new 7
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    local.get 2
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 164
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 164)
          local.get 3
          local.get 2
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 3
          array.get 164
          array.set 164
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 7)
      local.get 4
      struct.set 7 0
      local.get 2
      ref.cast (ref 7)
      local.get 4
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    local.get 5
    array.set 164
    local.get 2
    ref.cast (ref 7)
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 1
    ref.cast (ref 7)
  )
  (func (;4;) (type 13) (param i32) (result (ref 7))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 164
    i32.const 0
    local.get 3
    struct.new 7
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    local.get 2
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 164
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 164)
          local.get 3
          local.get 2
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 3
          array.get 164
          array.set 164
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 7)
      local.get 4
      struct.set 7 0
      local.get 2
      ref.cast (ref 7)
      local.get 4
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    local.get 5
    array.set 164
    local.get 2
    ref.cast (ref 7)
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 1
    ref.cast (ref 7)
  )
  (func (;5;) (type 14) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 63) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 26
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 27
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;7;) (type 64) (param (ref 8)) (result i32)
    local.get 0
    struct.get 8 0
  )
  (func (;8;) (type 65) (param eqref) (result (ref 9))
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const 0
    array.new_default 164
    i32.const 0
    i32.const 0
    struct.new 7
    i32.const -1
    call 3
    i32.const 0
    call 4
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 9
    ref.cast (ref 9)
  )
  (func (;9;) (type 66) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    call 28
    i32.const 0
    i32.eq
  )
  (func (;10;) (type 67) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32 eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 26
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 2
      local.set 3
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 29
      local.set 4
      i32.const -1
      local.set 5
      i32.const -1
      local.set 6
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 30
      i32.const 0
      i32.lt_s
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 31
        local.set 5
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 32
        local.set 6
        local.get 0
        ref.cast (ref 9)
        local.get 2
        local.get 5
        call 33
      else
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 31
        i32.const 0
        i32.lt_s
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 30
          local.set 5
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 32
          local.set 6
          local.get 0
          ref.cast (ref 9)
          local.get 2
          local.get 5
          call 33
        else
          local.get 0
          ref.cast (ref 9)
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 31
          call 34
          local.set 3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 29
          local.set 4
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 31
          local.set 5
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 32
          local.get 2
          i32.eq
          if ;; label = @4
            local.get 3
            local.set 6
            local.get 0
            ref.cast (ref 9)
            local.get 5
            local.get 3
            call 35
          else
            local.get 0
            ref.cast (ref 9)
            local.get 3
            call 32
            local.set 6
            local.get 0
            ref.cast (ref 9)
            local.get 3
            local.get 5
            call 33
            local.get 0
            ref.cast (ref 9)
            local.get 3
            local.get 0
            ref.cast (ref 9)
            local.get 2
            call 31
            call 36
            local.get 0
            ref.cast (ref 9)
            local.get 0
            ref.cast (ref 9)
            local.get 3
            call 31
            local.get 3
            call 35
          end
          local.get 0
          ref.cast (ref 9)
          local.get 2
          local.get 3
          call 33
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 30
          call 37
          local.get 0
          ref.cast (ref 9)
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 30
          local.get 3
          call 35
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 29
          call 38
        end
      end
      local.get 0
      struct.get 9 6
      local.get 2
      call 5
      local.set 8
      i32.const 0
      local.set 10
      local.set 7
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 7
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 8
      local.get 10
      array.set 164
      local.get 0
      ref.cast (ref 9)
      local.get 0
      ref.cast (ref 9)
      call 28
      i32.const 1
      i32.sub
      call 39
      local.get 4
      i32.eqz
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 5
        local.get 6
        call 40
      else
        call 2
      end
      i32.const 1
    end
  )
  (func (;11;) (type 68) (param (ref 9) i32 i32) (result i32)
    (local i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 9)
    call 41
    local.set 4
    i32.const 1
    struct.new 2
    local.set 5
    i32.const 1
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 12
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            i32.const 0
            i32.ge_s
            if ;; label = @5
              local.get 4
              local.set 3
              local.get 0
              ref.cast (ref 9)
              local.get 1
              local.get 4
              call 42
              local.set 5
              local.get 5
              local.set 11
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 11
                        ref.cast (ref 2)
                        struct.get 2 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;)
                      end
                      local.get 0
                      ref.cast (ref 9)
                      local.get 4
                      call 30
                      local.set 4
                      call 2
                      br 3 (;@6;)
                    end
                    local.get 0
                    struct.get 9 1
                    local.get 4
                    call 5
                    local.set 8
                    local.get 2
                    local.set 10
                    local.set 7
                    local.get 8
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 1
                    i32.ge_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 0
                    ref.cast (ref 164)
                    local.get 8
                    local.get 10
                    array.set 164
                    i32.const 0
                    return
                    br 2 (;@6;)
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  call 31
                  local.set 4
                  call 2
                  br 1 (;@6;)
                end
                unreachable
              end
              i32.const 1
              local.set 12
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 2
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 0
    struct.get 9 0
    ref.cast (ref 7)
    struct.get 7 1
    local.set 6
    local.get 0
    struct.get 9 0
    local.get 1
    local.set 13
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 13
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 1
    local.get 2
    local.set 14
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 14
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 2
    local.get 3
    local.set 15
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 15
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 3
    i32.const -1
    local.set 16
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 16
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 4
    i32.const -1
    local.set 17
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 17
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 5
    i32.const 1
    local.set 18
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 18
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 0
    struct.get 9 6
    i32.const 1
    local.set 19
    local.set 7
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 7
    ref.cast (ref 7)
    struct.get 7 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 7)
        struct.get 7 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 7)
      struct.get 7 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 164
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 164)
          local.get 8
          local.get 7
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 164)
          local.get 8
          array.get 164
          array.set 164
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 7)
      local.get 9
      struct.set 7 0
      local.get 7
      ref.cast (ref 7)
      local.get 9
      ref.cast (ref 164)
      array.len
      struct.set 7 2
    end
    local.get 7
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    local.get 19
    array.set 164
    local.get 7
    ref.cast (ref 7)
    local.get 7
    ref.cast (ref 7)
    struct.get 7 1
    i32.const 1
    i32.add
    struct.set 7 1
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 6
      call 43
    else
      local.get 5
      local.set 20
      block ;; label = @2
        local.get 20
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 6
          call 37
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 6
          call 36
          br 1 (;@2;)
        end
        unreachable
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 28
    i32.const 1
    i32.add
    call 39
    local.get 0
    ref.cast (ref 9)
    local.get 6
    call 44
    i32.const 1
  )
  (func (;12;) (type 69) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    call 28
  )
  (func (;13;) (type 70) (param (ref 9) i32) (result i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 26
    i32.const 0
    i32.ge_s
  )
  (func (;14;) (type 71) (param (ref 9)) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 41
    call 34
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 9)
      local.get 1
      call 45
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;15;) (type 72) (param (ref 9)) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 41
    call 46
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 9)
      local.get 1
      call 45
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;16;) (type 73) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 1
    call 47
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 45
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;17;) (type 74) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 0
    call 47
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 45
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;18;) (type 75) (param (ref 9) i32) (result (ref 0))
    (local i32 i32 eqref i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 1
    call 47
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 0
      ref.cast (ref 9)
      call 41
      call 46
    else
      local.get 0
      struct.get 9 14
      ref.cast (ref 3)
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 48
      local.get 1
      call 1
      local.set 4
      block ;; label = @2
        local.get 4
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 2
          local.set 5
          br 1 (;@2;)
        end
        local.get 4
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 4
          ref.cast (ref 2)
          struct.get 2 0
          i32.const 2
          i32.eq
          if (result i32) ;; label = @4
            i32.const 1
          else
            i32.const 0
          end
        end
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 49
          local.set 5
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 5
    end
    local.set 3
    local.get 3
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 45
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;19;) (type 76) (param (ref 9) i32) (result (ref 0))
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 17
    ref.cast (ref 0)
  )
  (func (;20;) (type 77) (param (ref 9)) (result (ref 10))
    local.get 0
    ref.cast (ref 9)
    i32.const 0
    struct.new 0
    i32.const 1
    i32.const 0
    struct.new 0
    i32.const 1
    call 24
    ref.cast (ref 10)
  )
  (func (;21;) (type 78) (param (ref 10)) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 eqref i32)
    local.get 0
    struct.get 10 1
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 4
    array.get 164
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      struct.get 10 2
      local.set 8
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 8
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            i32.const 1
            local.set 9
            br 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 1)
          struct.get 1 1
          local.set 2
          local.get 0
          struct.get 10 0
          struct.get 9 14
          ref.cast (ref 3)
          local.get 0
          struct.get 10 0
          ref.cast (ref 9)
          local.get 1
          call 48
          local.get 2
          call 1
          local.set 6
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    local.get 6
                    ref.cast (ref 2)
                    struct.get 2 0
                    br_table 0 (;@8;) 1 (;@7;) 2 (;@6;) 3 (;@5;)
                  end
                  i32.const 1
                  local.set 7
                  br 3 (;@4;)
                end
                local.get 0
                struct.get 10 3
                local.set 7
                br 2 (;@4;)
              end
              i32.const 0
              local.set 7
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 7
          local.set 9
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 9
    end
  )
  (func (;22;) (type 79) (param (ref 10)) (result (ref 8))
    (local i32 (ref 8) eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 10)
    call 21
    if (result eqref) ;; label = @1
      local.get 0
      struct.get 10 1
      i32.const 0
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      array.get 164
      local.set 1
      local.get 0
      struct.get 10 0
      ref.cast (ref 9)
      local.get 1
      call 45
      local.set 2
      local.get 0
      struct.get 10 1
      i32.const 0
      local.set 4
      local.get 0
      struct.get 10 0
      ref.cast (ref 9)
      local.get 1
      call 50
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      local.get 6
      array.set 164
      local.get 2
    else
      unreachable
    end
    ref.cast (ref 8)
  )
  (func (;23;) (type 80) (param (ref 8)) (result i32)
    local.get 0
    struct.get 8 6
  )
  (func (;24;) (type 81) (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))
    local.get 0
    local.get 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    local.get 2
    call 51
    call 3
    local.get 3
    local.get 4
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;25;) (type 82) (param (ref 9))
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 0
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 1
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 2
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 3
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 4
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 5
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    struct.get 9 6
    local.set 1
    local.get 1
    ref.cast (ref 7)
    i32.const 0
    struct.set 7 1
    local.get 0
    ref.cast (ref 9)
    i32.const -1
    call 43
    local.get 0
    ref.cast (ref 9)
    i32.const 0
    call 39
  )
  (func (;26;) (type 83) (param (ref 9) i32) (result i32)
    (local i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 9)
    call 41
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          i32.const -1
          i32.eq
          if ;; label = @4
            i32.const -1
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 2
            local.get 0
            ref.cast (ref 9)
            local.get 1
            local.get 2
            call 42
            local.set 3
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 3
                      ref.cast (ref 2)
                      struct.get 2 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 30
                    local.set 4
                    br 6 (;@2;)
                    br 3 (;@5;)
                  end
                  local.get 2
                  local.set 5
                  br 6 (;@1;)
                  br 2 (;@5;)
                end
                local.get 0
                ref.cast (ref 9)
                local.get 2
                call 31
                local.set 4
                br 4 (;@2;)
                br 1 (;@5;)
              end
              unreachable
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
  )
  (func (;27;) (type 84) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 1
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 3
    array.get 164
  )
  (func (;28;) (type 85) (param (ref 9)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 8
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 2
    array.get 164
  )
  (func (;29;) (type 86) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      struct.get 9 5
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 3
      array.get 164
    end
  )
  (func (;30;) (type 87) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 9 3
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 3
      array.get 164
    end
  )
  (func (;31;) (type 88) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 9 4
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 3
      array.get 164
    end
  )
  (func (;32;) (type 89) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 9 2
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 3
      array.get 164
    end
  )
  (func (;33;) (type 90) (param (ref 9) i32 i32)
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 32
    local.set 3
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 43
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 30
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 3
        local.get 2
        call 37
      else
        local.get 0
        ref.cast (ref 9)
        local.get 3
        local.get 2
        call 36
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 3
    call 35
  )
  (func (;34;) (type 91) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32)
    local.get 1
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          i32.const -1
          i32.eq
          if ;; label = @4
            i32.const -1
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 2
            local.get 0
            ref.cast (ref 9)
            local.get 2
            call 30
            local.set 3
            local.get 3
            i32.const 0
            i32.lt_s
            if ;; label = @5
              local.get 2
              local.set 5
              br 4 (;@1;)
            else
              local.get 3
              local.set 4
              br 3 (;@2;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
  )
  (func (;35;) (type 92) (param (ref 9) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 9 2
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      local.get 6
      array.set 164
    else
      call 2
    end
  )
  (func (;36;) (type 93) (param (ref 9) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 9 4
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      local.get 6
      array.set 164
    else
      call 2
    end
  )
  (func (;37;) (type 94) (param (ref 9) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 9 3
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      local.get 6
      array.set 164
    else
      call 2
    end
  )
  (func (;38;) (type 95) (param (ref 9) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 9 5
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 7)
      struct.get 7 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 164)
      local.get 4
      local.get 6
      array.set 164
    else
      call 2
    end
  )
  (func (;39;) (type 96) (param (ref 9) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 9 8
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 3
    local.get 5
    array.set 164
  )
  (func (;40;) (type 97) (param (ref 9) i32 i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 1
    local.set 3
    local.get 2
    local.set 4
    i32.const 1
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 8
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 3
            local.get 0
            ref.cast (ref 9)
            call 41
            i32.ne
            if (result i32) ;; label = @5
              local.get 0
              ref.cast (ref 9)
              local.get 3
              call 29
              i32.eqz
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 3
              i32.const 0
              i32.ge_s
              if (result i32) ;; label = @6
                local.get 0
                ref.cast (ref 9)
                local.get 3
                call 32
              else
                local.get 4
              end
              local.set 5
              local.get 5
              i32.const 0
              i32.lt_s
              if ;; label = @6
                local.get 0
                ref.cast (ref 9)
                call 41
                local.set 3
              else
                local.get 3
                local.get 0
                ref.cast (ref 9)
                local.get 5
                call 30
                i32.eq
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  call 31
                  local.set 6
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 29
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 1
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 52
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 31
                    local.set 6
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 30
                  call 29
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 31
                    call 29
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    i32.const 1
                    call 38
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 3
                    call 32
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 31
                    call 29
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 9)
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      call 30
                      i32.const 0
                      call 38
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      i32.const 1
                      call 38
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      call 53
                      local.get 0
                      ref.cast (ref 9)
                      local.get 5
                      call 31
                      local.set 6
                    else
                      call 2
                    end
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 29
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 31
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 52
                    local.get 0
                    ref.cast (ref 9)
                    call 41
                    local.set 3
                    i32.const -1
                    local.set 4
                  end
                else
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  call 30
                  local.set 7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 29
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 1
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 53
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 30
                    local.set 7
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 31
                  call 29
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 30
                    call 29
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    i32.const 1
                    call 38
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 3
                    call 32
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 30
                    call 29
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 9)
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      call 31
                      i32.const 0
                      call 38
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      i32.const 1
                      call 38
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      call 52
                      local.get 0
                      ref.cast (ref 9)
                      local.get 5
                      call 30
                      local.set 7
                    else
                      call 2
                    end
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 29
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 30
                    i32.const 0
                    call 38
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 53
                    local.get 0
                    ref.cast (ref 9)
                    call 41
                    local.set 3
                    i32.const -1
                    local.set 4
                  end
                end
              end
              i32.const 1
              local.set 8
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 2
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    local.get 3
    i32.const 0
    call 38
  )
  (func (;41;) (type 98) (param (ref 9)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 7
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 2
    array.get 164
  )
  (func (;42;) (type 99) (param (ref 9) i32 i32) (result (ref 2))
    local.get 0
    struct.get 9 14
    ref.cast (ref 3)
    local.get 1
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 48
    call 1
    ref.cast (ref 2)
  )
  (func (;43;) (type 100) (param (ref 9) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 9 7
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 3
    local.get 5
    array.set 164
  )
  (func (;44;) (type 101) (param (ref 9) i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 1
    local.set 2
    i32.const 1
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 11
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 0
            ref.cast (ref 9)
            local.get 0
            ref.cast (ref 9)
            local.get 2
            call 32
            call 29
            if ;; label = @5
              local.get 0
              ref.cast (ref 9)
              local.get 2
              call 32
              local.set 3
              local.get 0
              ref.cast (ref 9)
              local.get 3
              call 32
              local.set 4
              local.get 3
              local.get 0
              ref.cast (ref 9)
              local.get 4
              call 30
              i32.eq
              if ;; label = @6
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 31
                local.set 5
                local.get 0
                ref.cast (ref 9)
                local.get 5
                call 29
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  i32.const 1
                  call 38
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  call 31
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 52
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 2
                  call 32
                  local.set 6
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 32
                  local.set 7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  i32.const 1
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 53
                end
              else
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 30
                local.set 8
                local.get 0
                ref.cast (ref 9)
                local.get 8
                call 29
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  i32.const 1
                  call 38
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  call 30
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 53
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 2
                  call 32
                  local.set 9
                  local.get 0
                  ref.cast (ref 9)
                  local.get 9
                  call 32
                  local.set 10
                  local.get 0
                  ref.cast (ref 9)
                  local.get 9
                  i32.const 0
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 10
                  i32.const 1
                  call 38
                  local.get 0
                  ref.cast (ref 9)
                  local.get 10
                  call 52
                end
              end
              i32.const 1
              local.set 11
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 2
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 41
    i32.const 0
    call 38
  )
  (func (;45;) (type 102) (param (ref 9) i32) (result (ref 8))
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 48
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 27
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;46;) (type 103) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32)
    local.get 1
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          i32.const -1
          i32.eq
          if ;; label = @4
            i32.const -1
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 2
            local.get 0
            ref.cast (ref 9)
            local.get 2
            call 31
            local.set 3
            local.get 3
            i32.const 0
            i32.lt_s
            if ;; label = @5
              local.get 2
              local.set 5
              br 4 (;@1;)
            else
              local.get 3
              local.set 4
              br 3 (;@2;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
  )
  (func (;47;) (type 104) (param (ref 9) i32 i32) (result i32)
    (local i32 i32 eqref i32 i32)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 9)
    call 41
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 6
          i32.const -1
          i32.eq
          if ;; label = @4
            local.get 3
            local.set 7
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 4
            local.get 0
            ref.cast (ref 9)
            local.get 1
            local.get 4
            call 42
            local.set 5
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 5
                      ref.cast (ref 2)
                      struct.get 2 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 4
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 4
                    call 30
                    local.set 6
                    br 6 (;@2;)
                    br 3 (;@5;)
                  end
                  local.get 2
                  if ;; label = @8
                    local.get 4
                    local.set 7
                    br 7 (;@1;)
                  else
                    local.get 0
                    ref.cast (ref 9)
                    local.get 4
                    call 31
                    local.set 6
                    br 6 (;@2;)
                  end
                  br 2 (;@5;)
                end
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 31
                local.set 6
                br 4 (;@2;)
                br 1 (;@5;)
              end
              unreachable
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 7
  )
  (func (;48;) (type 105) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 0
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 7)
    struct.get 7 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 164)
    local.get 3
    array.get 164
  )
  (func (;49;) (type 106) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 30
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 46
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 32
      local.set 4
      i32.const 1
      local.set 5
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 5
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 4
              i32.const 0
              i32.ge_s
              if (result i32) ;; label = @6
                local.get 3
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 30
                i32.eq
              else
                i32.const 0
              end
              if ;; label = @6
                local.get 4
                local.set 3
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 32
                local.set 4
                i32.const 1
                local.set 5
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              local.get 4
              local.set 6
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 6
    end
  )
  (func (;50;) (type 107) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 31
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 34
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 32
      local.set 4
      i32.const 1
      local.set 5
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 5
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 4
              i32.const 0
              i32.ge_s
              if (result i32) ;; label = @6
                local.get 3
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 31
                i32.eq
              else
                i32.const 0
              end
              if ;; label = @6
                local.get 4
                local.set 3
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 32
                local.set 4
                i32.const 1
                local.set 5
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              local.get 4
              local.set 6
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 6
    end
  )
  (func (;51;) (type 108) (param (ref 9) (ref 0) i32) (result i32)
    (local i32 eqref i32)
    local.get 1
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 0
          ref.cast (ref 9)
          local.get 0
          ref.cast (ref 9)
          call 41
          call 34
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 1)
        struct.get 1 1
        local.set 3
        local.get 0
        ref.cast (ref 9)
        local.get 3
        local.get 2
        call 47
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;52;) (type 109) (param (ref 9) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 31
    local.set 2
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 30
    local.set 3
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 3
    call 36
    local.get 0
    ref.cast (ref 9)
    local.get 3
    local.get 1
    call 35
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 32
    local.set 4
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 4
    call 35
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 43
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 4
      call 30
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 37
      else
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 36
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 1
    call 37
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 35
  )
  (func (;53;) (type 110) (param (ref 9) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 30
    local.set 2
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 31
    local.set 3
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 3
    call 37
    local.get 0
    ref.cast (ref 9)
    local.get 3
    local.get 1
    call 35
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 32
    local.set 4
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 4
    call 35
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 43
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 4
      call 31
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 36
      else
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 37
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 1
    call 36
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 35
  )
  (func (;54;) (type 133) (param (ref 111) i32) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 6
    ref.cast (ref 0)
  )
  (func (;55;) (type 134) (param (ref 8)) (result i32)
    local.get 0
    ref.cast (ref 8)
    call 7
  )
  (func (;56;) (type 135) (param eqref) (result (ref 111))
    local.get 0
    call 8
    struct.new 111
    ref.cast (ref 111)
  )
  (func (;57;) (type 136) (param (ref 111)) (result i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 9
  )
  (func (;58;) (type 137) (param (ref 111) i32) (result i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 10
  )
  (func (;59;) (type 138) (param (ref 111) i32 i32) (result i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 11
  )
  (func (;60;) (type 139) (param (ref 111) i32 i32)
    (local i32 i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 11
    local.set 3
    local.get 3
    local.set 4
  )
  (func (;61;) (type 140) (param (ref 111)) (result i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 12
  )
  (func (;62;) (type 141) (param (ref 111) i32) (result i32)
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 13
  )
  (func (;63;) (type 142) (param (ref 111)) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 14
    ref.cast (ref 0)
  )
  (func (;64;) (type 143) (param (ref 111)) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 15
    ref.cast (ref 0)
  )
  (func (;65;) (type 144) (param (ref 111) i32) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 16
    ref.cast (ref 0)
  )
  (func (;66;) (type 145) (param (ref 111) i32) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 17
    ref.cast (ref 0)
  )
  (func (;67;) (type 146) (param (ref 111) i32) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 18
    ref.cast (ref 0)
  )
  (func (;68;) (type 147) (param (ref 111) i32) (result (ref 0))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    call 19
    ref.cast (ref 0)
  )
  (func (;69;) (type 148) (param (ref 111)) (result (ref 10))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 20
    ref.cast (ref 10)
  )
  (func (;70;) (type 149) (param (ref 10)) (result i32)
    local.get 0
    ref.cast (ref 10)
    call 21
  )
  (func (;71;) (type 150) (param (ref 10)) (result (ref 8))
    local.get 0
    ref.cast (ref 10)
    call 22
    ref.cast (ref 8)
  )
  (func (;72;) (type 151) (param (ref 8)) (result i32)
    local.get 0
    ref.cast (ref 8)
    call 23
  )
  (func (;73;) (type 152) (param (ref 111) (ref 0) i32 (ref 0) i32) (result (ref 10))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    local.get 2
    local.get 3
    ref.cast (ref 0)
    local.get 4
    call 24
    ref.cast (ref 10)
  )
  (func (;74;) (type 153) (param (ref 111))
    local.get 0
    struct.get 111 0
    ref.cast (ref 9)
    call 25
  )
  (func (;75;) (type 154))
  (func (;76;) (type 155) (param (ref 111) i32 i32) (result i32)
    (local i32 eqref i32)
    local.get 0
    ref.cast (ref 111)
    local.get 1
    call 54
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 1)
        struct.get 1 1
        local.set 3
        local.get 3
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;77;) (type 156) (param (ref 0) i32) (result i32)
    (local eqref eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 1)
        struct.get 1 6
        local.set 2
        local.get 2
        ref.cast (ref 8)
        call 55
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;78;) (type 157)
    (local eqref eqref eqref i32 i32 eqref eqref i32 eqref i32 i32 i32)
    call 0
    call 56
    local.set 0
    local.get 0
    ref.cast (ref 111)
    call 57
    v128.const i32x4 0x2077656e 0x2070616d 0x74706d65 0x00000079
    array.new_fixed 158 1
    i32.const 0
    i32.const 13
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 1
    call 54
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 0)
      struct.get 0 0
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
    v128.const i32x4 0x74706d65 0x65672079 0x00000074 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 9
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 1
    call 58
    i32.eqz
    v128.const i32x4 0x74706d65 0x65722079 0x65766f6d 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 12
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 4
    i32.const 40
    call 59
    v128.const i32x4 0x65736e69 0x66207472 0x0072756f 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 11
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 1
    i32.const 10
    call 59
    v128.const i32x4 0x65736e69 0x6f207472 0x0000656e 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 10
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    i32.const 30
    call 59
    v128.const i32x4 0x65736e69 0x74207472 0x65657268 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 12
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 2
    i32.const 20
    call 59
    v128.const i32x4 0x65736e69 0x74207472 0x00006f77 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 10
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    i32.const 300
    call 59
    i32.eqz
    v128.const i32x4 0x6c706572 0x20656361 0x6f706572 0x20737472
    v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
    array.new_fixed 158 2
    i32.const 0
    i32.const 21
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    i32.const -1
    call 76
    i32.const 300
    i32.eq
    v128.const i32x4 0x6c706572 0x20656361 0x756c6176 0x00000065
    array.new_fixed 158 1
    i32.const 0
    i32.const 13
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 2
    i32.const 200
    call 60
    local.get 0
    ref.cast (ref 111)
    i32.const 2
    i32.const -1
    call 76
    i32.const 200
    i32.eq
    v128.const i32x4 0x20746573 0x756c6176 0x00000065 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 9
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 111)
    i32.const 5
    i32.const 50
    call 60
    local.get 0
    ref.cast (ref 111)
    call 61
    i32.const 5
    i32.eq
    v128.const i32x4 0x61696c61 0x756d2073 0x69746174 0x00006e6f
    array.new_fixed 158 1
    i32.const 0
    i32.const 14
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 5
    call 62
    v128.const i32x4 0x746e6f63 0x736e6961 0x79656b20 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 12
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    call 63
    i32.const -1
    call 77
    i32.const 1
    i32.eq
    v128.const i32x4 0x696e696d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 7
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    call 64
    i32.const -1
    call 77
    i32.const 5
    i32.eq
    v128.const i32x4 0x6978616d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 7
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 65
    i32.const -1
    call 77
    i32.const 3
    i32.eq
    v128.const i32x4 0x65776f6c 0x6f622072 0x00646e75 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 11
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 66
    i32.const -1
    call 77
    i32.const 4
    i32.eq
    v128.const i32x4 0x65707075 0x6f622072 0x00646e75 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 11
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 67
    i32.const -1
    call 77
    i32.const 2
    i32.eq
    v128.const i32x4 0x64657270 0x73656365 0x00726f73 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 11
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 68
    i32.const -1
    call 77
    i32.const 4
    i32.eq
    v128.const i32x4 0x63637573 0x6f737365 0x00000072 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 9
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    call 69
    local.set 2
    i32.const 1
    local.set 3
    i32.const 0
    local.set 4
    i32.const 1
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 10
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 2
            ref.cast (ref 10)
            call 70
            if ;; label = @5
              local.get 2
              ref.cast (ref 10)
              call 71
              local.set 5
              local.get 5
              ref.cast (ref 8)
              call 55
              local.get 3
              i32.eq
              v128.const i32x4 0x2070616d 0x6564726f 0x00000072 0x00000000
              array.new_fixed 158 1
              i32.const 0
              i32.const 9
              struct.new 159
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 4
              local.get 5
              ref.cast (ref 8)
              call 72
              i32.add
              local.set 4
              local.get 3
              i32.const 1
              i32.add
              local.set 3
              i32.const 1
              local.set 10
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 75
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
    i32.const 6
    i32.eq
    v128.const i32x4 0x2070616d 0x72657469 0x726f7461 0x756f6320
    v128.const i32x4 0x0000746e 0x00000000 0x00000000 0x00000000
    array.new_fixed 158 2
    i32.const 0
    i32.const 18
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    i32.const 600
    i32.eq
    v128.const i32x4 0x2070616d 0x72657469 0x726f7461 0x6c617620
    v128.const i32x4 0x00736575 0x00000000 0x00000000 0x00000000
    array.new_fixed 158 2
    i32.const 0
    i32.const 19
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 1
    i32.const 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    i32.const 0
    i32.const 1
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    i32.const 0
    call 73
    local.set 6
    i32.const 3
    local.set 7
    i32.const 1
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 11
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 6
            ref.cast (ref 10)
            call 70
            if ;; label = @5
              local.get 6
              ref.cast (ref 10)
              call 71
              call 55
              local.get 7
              i32.eq
              v128.const i32x4 0x2070616d 0x676e6172 0x00000065 0x00000000
              array.new_fixed 158 1
              i32.const 0
              i32.const 9
              struct.new 159
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 7
              i32.const 1
              i32.add
              local.set 7
              i32.const 1
              local.set 11
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 75
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 7
    i32.const 5
    i32.eq
    v128.const i32x4 0x2070616d 0x676e6172 0x6f622065 0x61646e75
    v128.const i32x4 0x73656972 0x00000000 0x00000000 0x00000000
    array.new_fixed 158 2
    i32.const 0
    i32.const 20
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 58
    v128.const i32x4 0x6f6d6572 0x65206576 0x74736978 0x00676e69
    array.new_fixed 158 1
    i32.const 0
    i32.const 15
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 62
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x65736261 0x0000746e
    array.new_fixed 158 1
    i32.const 0
    i32.const 14
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    i32.const 3
    call 58
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x69206576 0x706d6564 0x6e65746f
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 158 2
    i32.const 0
    i32.const 17
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 111)
    call 74
    local.get 0
    ref.cast (ref 111)
    call 57
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 158 1
    i32.const 0
    i32.const 11
    struct.new 159
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
