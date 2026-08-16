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
  (type (;10;) (sub (struct (field i32))))
  (type (;11;) (struct))
  (type (;12;) (func (result (ref 11))))
  (type (;13;) (func (param (ref 11) eqref eqref) (result (ref 10))))
  (type (;14;) (func (param (ref 11) i32 i32) (result (ref 10))))
  (type (;15;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;16;) (sub (struct (field funcref))))
  (type (;17;) (func (param eqref) (result eqref)))
  (type (;18;) (func (param eqref i32) (result eqref)))
  (type (;19;) (func (param eqref) (result (ref 15))))
  (type (;20;) (func (param eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref)))
  (type (;22;) (func (param eqref i32)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result eqref)))
  (type (;26;) (func (param eqref eqref) (result (ref 15))))
  (type (;27;) (func (param eqref eqref eqref) (result eqref)))
  (type (;28;) (func (param eqref eqref)))
  (type (;29;) (func (param eqref eqref i32)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param eqref eqref i32) (result i32)))
  (type (;32;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;33;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;34;) (struct (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field (ref 15)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;35;) (struct (field (ref 34)) (field (ref 15)) (field (ref 8)) (field i32)))
  (type (;36;) (func))
  (type (;37;) (func (param i32) (result (ref 15))))
  (type (;38;) (func (param i32) (result (ref 15))))
  (type (;39;) (func (param i32) (result i32)))
  (type (;40;) (func (param (ref 34)) (result i32)))
  (type (;41;) (func (param (ref 34) i32)))
  (type (;42;) (func (param (ref 34)) (result i32)))
  (type (;43;) (func (param (ref 34) i32)))
  (type (;44;) (func (param (ref 34) i32) (result i32)))
  (type (;45;) (func (param (ref 34) i32) (result i32)))
  (type (;46;) (func (param (ref 34) i32) (result i32)))
  (type (;47;) (func (param (ref 34) i32) (result i32)))
  (type (;48;) (func (param (ref 34) i32 i32)))
  (type (;49;) (func (param (ref 34) i32 i32)))
  (type (;50;) (func (param (ref 34) i32 i32)))
  (type (;51;) (func (param (ref 34) i32 i32)))
  (type (;52;) (func (param (ref 34) i32) (result eqref)))
  (type (;53;) (func (param (ref 34) i32) (result eqref)))
  (type (;54;) (func (param (ref 34) i32) (result (ref 33))))
  (type (;55;) (func (param eqref) (result (ref 34))))
  (type (;56;) (func (param (ref 34)) (result i32)))
  (type (;57;) (func (param (ref 34)) (result i32)))
  (type (;58;) (func (param (ref 34) eqref i32) (result (ref 10))))
  (type (;59;) (func (param (ref 34) eqref) (result i32)))
  (type (;60;) (func (param (ref 34) i32) (result i32)))
  (type (;61;) (func (param (ref 34) i32) (result i32)))
  (type (;62;) (func (param (ref 34) i32) (result i32)))
  (type (;63;) (func (param (ref 34) i32) (result i32)))
  (type (;64;) (func (param (ref 34) i32)))
  (type (;65;) (func (param (ref 34) i32)))
  (type (;66;) (func (param (ref 34) i32)))
  (type (;67;) (func (param (ref 34) eqref eqref) (result i32)))
  (type (;68;) (func (param (ref 34) eqref) (result i32)))
  (type (;69;) (func (param (ref 34) i32 i32)))
  (type (;70;) (func (param (ref 34) i32 i32)))
  (type (;71;) (func (param (ref 34) eqref) (result i32)))
  (type (;72;) (func (param (ref 34)) (result (ref 8))))
  (type (;73;) (func (param (ref 34)) (result (ref 8))))
  (type (;74;) (func (param (ref 34) eqref i32) (result i32)))
  (type (;75;) (func (param (ref 34) eqref) (result (ref 8))))
  (type (;76;) (func (param (ref 34) eqref) (result (ref 8))))
  (type (;77;) (func (param (ref 34) eqref) (result (ref 8))))
  (type (;78;) (func (param (ref 34) eqref) (result (ref 8))))
  (type (;79;) (func (param (ref 33)) (result eqref)))
  (type (;80;) (func (param (ref 34))))
  (type (;81;) (func (param (ref 34) (ref 8) i32) (result i32)))
  (type (;82;) (func (param (ref 34) (ref 8) i32 (ref 8) i32) (result (ref 35))))
  (type (;83;) (func (param (ref 34)) (result (ref 35))))
  (type (;84;) (func (param (ref 35)) (result i32)))
  (type (;85;) (func (param (ref 35)) (result (ref 33))))
  (type (;86;) (func (param eqref) (result (ref 34))))
  (type (;87;) (func (param (ref 34)) (result i32)))
  (type (;88;) (func (param (ref 34)) (result (ref 8))))
  (type (;89;) (func (param (ref 34) i32) (result i32)))
  (type (;90;) (func (param (ref 34) i32 i32) (result i32)))
  (type (;91;) (func (param (ref 34)) (result i32)))
  (type (;92;) (func (param (ref 34) i32) (result i32)))
  (type (;93;) (func (param (ref 34)) (result (ref 8))))
  (type (;94;) (func (param (ref 34) i32) (result (ref 8))))
  (type (;95;) (func (param (ref 34) i32) (result (ref 8))))
  (type (;96;) (func (param (ref 34) i32) (result (ref 8))))
  (type (;97;) (func (param (ref 34) i32) (result (ref 8))))
  (type (;98;) (func (param (ref 34)) (result (ref 35))))
  (type (;99;) (func (param (ref 35)) (result i32)))
  (type (;100;) (func (param (ref 35)) (result (ref 33))))
  (type (;101;) (func (param (ref 33)) (result i32)))
  (type (;102;) (func (param (ref 34) (ref 8) i32 (ref 8) i32) (result (ref 35))))
  (type (;103;) (func (param (ref 34))))
  (type (;104;) (func (param (ref 34)) (result i32)))
  (type (;105;) (func (param (ref 34)) (result i32)))
  (type (;106;) (func (param (ref 34) i32) (result i32)))
  (type (;107;) (func (param (ref 34) i32) (result (ref 33))))
  (type (;108;) (func (param (ref 34) i32) (result i32)))
  (type (;109;) (func (param (ref 34) i32) (result i32)))
  (type (;110;) (func (param (ref 34) i32) (result i32)))
  (type (;111;) (func (param (ref 34) i32) (result i32)))
  (type (;112;) (func (param (ref 34) i32) (result i32)))
  (type (;113;) (func (param (ref 34) i32 i32)))
  (type (;114;) (func (param (ref 34) i32 i32)))
  (type (;115;) (func (param (ref 34) i32 i32)))
  (type (;116;) (func (param (ref 34) i32 i32)))
  (type (;117;) (func (param (ref 34) i32 i32)))
  (type (;118;) (func (param (ref 34) i32)))
  (type (;119;) (func (param (ref 34) i32 i32)))
  (type (;120;) (func (param (ref 34) i32 i32) (result (ref 10))))
  (type (;121;) (func (param (ref 34) i32)))
  (type (;122;) (func (param (ref 34) i32)))
  (type (;123;) (func (param (ref 34) i32) (result i32)))
  (type (;124;) (func (param (ref 34) i32 i32) (result i32)))
  (type (;125;) (func (param (ref 34) i32) (result i32)))
  (type (;126;) (func (param (ref 34) i32) (result i32)))
  (type (;127;) (func (param (ref 34) i32) (result i32)))
  (type (;128;) (func (param (ref 34) (ref 8) i32) (result i32)))
  (type (;129;) (func (param (ref 34) i32) (result i32)))
  (type (;130;) (func (param (ref 34) i32)))
  (type (;131;) (func (param (ref 34) i32)))
  (type (;132;) (struct (field (ref 34))))
  (type (;133;) (struct (field (ref 35))))
  (type (;134;) (func (param eqref) (result (ref 132))))
  (type (;135;) (func (param (ref 132)) (result i32)))
  (type (;136;) (func (param (ref 132)) (result i32)))
  (type (;137;) (func (param (ref 132) eqref) (result i32)))
  (type (;138;) (func (param (ref 132) eqref) (result i32)))
  (type (;139;) (func (param (ref 132) eqref) (result i32)))
  (type (;140;) (func (param (ref 132))))
  (type (;141;) (func (param (ref 8)) (result (ref 8))))
  (type (;142;) (func (param (ref 132)) (result (ref 8))))
  (type (;143;) (func (param (ref 132)) (result (ref 8))))
  (type (;144;) (func (param (ref 132) eqref) (result (ref 8))))
  (type (;145;) (func (param (ref 132) eqref) (result (ref 8))))
  (type (;146;) (func (param (ref 132) eqref) (result (ref 8))))
  (type (;147;) (func (param (ref 132) eqref) (result (ref 8))))
  (type (;148;) (func (param (ref 132)) (result (ref 133))))
  (type (;149;) (func (param (ref 132) (ref 8) i32 (ref 8) i32) (result (ref 133))))
  (type (;150;) (func (param (ref 133)) (result i32)))
  (type (;151;) (func (param (ref 133)) (result eqref)))
  (type (;152;) (func (param eqref) (result (ref 132))))
  (type (;153;) (func (param (ref 132)) (result i32)))
  (type (;154;) (func (param (ref 132)) (result (ref 8))))
  (type (;155;) (func (param (ref 132) i32) (result i32)))
  (type (;156;) (func (param (ref 132) i32) (result i32)))
  (type (;157;) (func (param (ref 132)) (result i32)))
  (type (;158;) (func (param (ref 132) i32) (result i32)))
  (type (;159;) (func (param (ref 132)) (result (ref 8))))
  (type (;160;) (func (param (ref 132) i32) (result (ref 8))))
  (type (;161;) (func (param (ref 132) i32) (result (ref 8))))
  (type (;162;) (func (param (ref 132) i32) (result (ref 8))))
  (type (;163;) (func (param (ref 132) i32) (result (ref 8))))
  (type (;164;) (func (param (ref 132)) (result (ref 133))))
  (type (;165;) (func (param (ref 133)) (result i32)))
  (type (;166;) (func (param (ref 133)) (result i32)))
  (type (;167;) (func (param (ref 132) (ref 8) i32 (ref 8) i32) (result (ref 133))))
  (type (;168;) (func (param (ref 132))))
  (type (;169;) (func (param (ref 8)) (result (ref 8))))
  (type (;170;) (func))
  (type (;171;) (func (param (ref 8) i32) (result i32)))
  (type (;172;) (func))
  (type (;173;) (array (mut v128)))
  (type (;174;) (struct (field (ref 173)) (field i32) (field i32)))
  (type (;175;) (struct (field (ref 173)) (field i32) (field i32)))
  (type (;176;) (struct (field (ref 173)) (field i32) (field i32)))
  (type (;177;) (struct (field (mut (ref 173))) (field (mut i32)) (field (mut i32))))
  (type (;178;) (struct (field (mut (ref 173))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 72))
  (func (;0;) (type 12) (result (ref 11))
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;1;) (type 14) (param (ref 11) i32 i32) (result (ref 10))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 10
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 10
      else
        i32.const 2
        struct.new 10
      end
    end
    ref.cast (ref 10)
  )
  (func (;2;) (type 36))
  (func (;3;) (type 37) (param i32) (result (ref 15))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 0
    i32.const 0
    local.get 3
    struct.new 15
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    local.get 2
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 2
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
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 15)
      local.get 4
      struct.set 15 0
      local.get 2
      ref.cast (ref 15)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 15)
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 1
    ref.cast (ref 15)
  )
  (func (;4;) (type 38) (param i32) (result (ref 15))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 0
    i32.const 0
    local.get 3
    struct.new 15
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    local.get 2
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 2
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
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 15)
      local.get 4
      struct.set 15 0
      local.get 2
      ref.cast (ref 15)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 15)
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 1
    ref.cast (ref 15)
  )
  (func (;5;) (type 39) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 86) (param eqref) (result (ref 34))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 15
    ref.cast (ref 15)
    i32.const -1
    call 3
    ref.cast (ref 15)
    i32.const 0
    call 4
    ref.cast (ref 15)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 34
    ref.cast (ref 34)
  )
  (func (;7;) (type 87) (param (ref 34)) (result i32)
    local.get 0
    ref.cast (ref 34)
    call 24
    i32.const 0
    i32.eq
  )
  (func (;8;) (type 88) (param (ref 34)) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 34)
    local.get 0
    ref.cast (ref 34)
    call 25
    call 26
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 34)
      local.get 1
      call 27
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;9;) (type 89) (param (ref 34) i32) (result i32)
    (local i32 i32 i32 i32 i32 eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 28
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
      ref.cast (ref 34)
      local.get 3
      call 29
      local.set 4
      i32.const -1
      local.set 5
      i32.const -1
      local.set 6
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 30
      i32.const 0
      i32.lt_s
      if ;; label = @2
        local.get 0
        ref.cast (ref 34)
        local.get 2
        call 31
        local.set 5
        local.get 0
        ref.cast (ref 34)
        local.get 2
        call 32
        local.set 6
        local.get 0
        ref.cast (ref 34)
        local.get 2
        local.get 5
        call 33
      else
        local.get 0
        ref.cast (ref 34)
        local.get 2
        call 31
        i32.const 0
        i32.lt_s
        if ;; label = @3
          local.get 0
          ref.cast (ref 34)
          local.get 2
          call 30
          local.set 5
          local.get 0
          ref.cast (ref 34)
          local.get 2
          call 32
          local.set 6
          local.get 0
          ref.cast (ref 34)
          local.get 2
          local.get 5
          call 33
        else
          local.get 0
          ref.cast (ref 34)
          local.get 0
          ref.cast (ref 34)
          local.get 2
          call 31
          call 26
          local.set 3
          local.get 0
          ref.cast (ref 34)
          local.get 3
          call 29
          local.set 4
          local.get 0
          ref.cast (ref 34)
          local.get 3
          call 31
          local.set 5
          local.get 0
          ref.cast (ref 34)
          local.get 3
          call 32
          local.get 2
          i32.eq
          if ;; label = @4
            local.get 3
            local.set 6
            local.get 0
            ref.cast (ref 34)
            local.get 5
            local.get 3
            call 34
          else
            local.get 0
            ref.cast (ref 34)
            local.get 3
            call 32
            local.set 6
            local.get 0
            ref.cast (ref 34)
            local.get 3
            local.get 5
            call 33
            local.get 0
            ref.cast (ref 34)
            local.get 3
            local.get 0
            ref.cast (ref 34)
            local.get 2
            call 31
            call 35
            local.get 0
            ref.cast (ref 34)
            local.get 0
            ref.cast (ref 34)
            local.get 3
            call 31
            local.get 3
            call 34
          end
          local.get 0
          ref.cast (ref 34)
          local.get 2
          local.get 3
          call 33
          local.get 0
          ref.cast (ref 34)
          local.get 3
          local.get 0
          ref.cast (ref 34)
          local.get 2
          call 30
          call 36
          local.get 0
          ref.cast (ref 34)
          local.get 0
          ref.cast (ref 34)
          local.get 3
          call 30
          local.get 3
          call 34
          local.get 0
          ref.cast (ref 34)
          local.get 3
          local.get 0
          ref.cast (ref 34)
          local.get 2
          call 29
          call 37
        end
      end
      local.get 0
      struct.get 34 6
      local.get 2
      call 5
      local.set 8
      i32.const 0
      local.set 10
      local.set 7
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 8
      local.get 10
      array.set 0
      local.get 0
      ref.cast (ref 34)
      local.get 0
      ref.cast (ref 34)
      call 24
      i32.const 1
      i32.sub
      call 38
      local.get 4
      i32.eqz
      if ;; label = @2
        local.get 0
        ref.cast (ref 34)
        local.get 5
        local.get 6
        call 39
      else
        call 2
      end
      i32.const 1
    end
  )
  (func (;10;) (type 90) (param (ref 34) i32 i32) (result i32)
    (local i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 34)
    call 25
    local.set 4
    i32.const 1
    struct.new 10
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
              ref.cast (ref 34)
              local.get 1
              local.get 4
              call 40
              local.set 5
              local.get 5
              local.set 11
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 11
                        ref.cast (ref 10)
                        struct.get 10 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;)
                      end
                      local.get 0
                      ref.cast (ref 34)
                      local.get 4
                      call 30
                      local.set 4
                      call 2
                      br 3 (;@6;)
                    end
                    local.get 0
                    struct.get 34 1
                    local.get 4
                    call 5
                    local.set 8
                    local.get 2
                    local.set 10
                    local.set 7
                    local.get 8
                    local.get 7
                    ref.cast (ref 15)
                    struct.get 15 1
                    i32.ge_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 7
                    ref.cast (ref 15)
                    struct.get 15 0
                    ref.cast (ref 0)
                    local.get 8
                    local.get 10
                    array.set 0
                    i32.const 0
                    return
                    br 2 (;@6;)
                  end
                  local.get 0
                  ref.cast (ref 34)
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
    struct.get 34 0
    ref.cast (ref 15)
    struct.get 15 1
    local.set 6
    local.get 0
    struct.get 34 0
    local.get 1
    local.set 13
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 13
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 1
    local.get 2
    local.set 14
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 14
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 2
    local.get 3
    local.set 15
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 15
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 3
    i32.const -1
    local.set 16
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 16
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 4
    i32.const -1
    local.set 17
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 17
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 5
    i32.const 1
    local.set 18
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 18
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 0
    struct.get 34 6
    i32.const 1
    local.set 19
    local.set 7
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 7
    ref.cast (ref 15)
    struct.get 15 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 15)
        struct.get 15 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 15)
      struct.get 15 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 0
      local.set 9
      local.get 9
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      i32.const 0
      local.get 7
      ref.cast (ref 15)
      struct.get 15 1
      array.copy 0 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      struct.set 15 0
      local.get 7
      ref.cast (ref 15)
      local.get 9
      ref.cast (ref 0)
      array.len
      struct.set 15 2
    end
    local.get 7
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    local.get 19
    array.set 0
    local.get 7
    ref.cast (ref 15)
    local.get 7
    ref.cast (ref 15)
    struct.get 15 1
    i32.const 1
    i32.add
    struct.set 15 1
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 6
      call 41
    else
      local.get 5
      local.set 20
      block ;; label = @2
        local.get 20
        ref.cast (ref 10)
        struct.get 10 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 0
          ref.cast (ref 34)
          local.get 3
          local.get 6
          call 36
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          local.get 0
          ref.cast (ref 34)
          local.get 3
          local.get 6
          call 35
          br 1 (;@2;)
        end
        unreachable
      end
    end
    local.get 0
    ref.cast (ref 34)
    local.get 0
    ref.cast (ref 34)
    call 24
    i32.const 1
    i32.add
    call 38
    local.get 0
    ref.cast (ref 34)
    local.get 6
    call 42
    i32.const 1
  )
  (func (;11;) (type 91) (param (ref 34)) (result i32)
    local.get 0
    ref.cast (ref 34)
    call 24
  )
  (func (;12;) (type 92) (param (ref 34) i32) (result i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 28
    i32.const 0
    i32.ge_s
  )
  (func (;13;) (type 93) (param (ref 34)) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 34)
    local.get 0
    ref.cast (ref 34)
    call 25
    call 43
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 34)
      local.get 1
      call 27
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;14;) (type 94) (param (ref 34) i32) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    i32.const 1
    call 44
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 27
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;15;) (type 95) (param (ref 34) i32) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    i32.const 0
    call 44
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 27
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;16;) (type 96) (param (ref 34) i32) (result (ref 8))
    (local i32 i32 eqref i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    i32.const 1
    call 44
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 0
      ref.cast (ref 34)
      call 25
      call 43
    else
      local.get 0
      struct.get 34 14
      ref.cast (ref 11)
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 45
      local.get 1
      call 1
      local.set 4
      block ;; label = @2
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 2
          local.set 5
          br 1 (;@2;)
        end
        local.get 4
        ref.cast (ref 10)
        struct.get 10 0
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
          ref.cast (ref 10)
          struct.get 10 0
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
          ref.cast (ref 34)
          local.get 2
          call 46
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
      struct.new 8
    else
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      ref.cast (ref 34)
      local.get 3
      call 27
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;17;) (type 97) (param (ref 34) i32) (result (ref 8))
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 15
    ref.cast (ref 8)
  )
  (func (;18;) (type 98) (param (ref 34)) (result (ref 35))
    local.get 0
    ref.cast (ref 34)
    i32.const 0
    struct.new 8
    i32.const 1
    i32.const 0
    struct.new 8
    i32.const 1
    call 22
    ref.cast (ref 35)
  )
  (func (;19;) (type 99) (param (ref 35)) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 eqref i32)
    local.get 0
    struct.get 35 1
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    local.set 1
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      struct.get 35 2
      local.set 8
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 8
              ref.cast (ref 8)
              struct.get 8 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            i32.const 1
            local.set 9
            br 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 9)
          struct.get 9 1
          local.set 2
          local.get 0
          struct.get 35 0
          struct.get 34 14
          ref.cast (ref 11)
          local.get 0
          struct.get 35 0
          ref.cast (ref 34)
          local.get 1
          call 45
          local.get 2
          call 1
          local.set 6
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    local.get 6
                    ref.cast (ref 10)
                    struct.get 10 0
                    br_table 0 (;@8;) 1 (;@7;) 2 (;@6;) 3 (;@5;)
                  end
                  i32.const 1
                  local.set 7
                  br 3 (;@4;)
                end
                local.get 0
                struct.get 35 3
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
  (func (;20;) (type 100) (param (ref 35)) (result (ref 33))
    (local i32 (ref 33) eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 35)
    call 19
    if (result eqref) ;; label = @1
      local.get 0
      struct.get 35 1
      i32.const 0
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 1
      local.get 0
      struct.get 35 0
      ref.cast (ref 34)
      local.get 1
      call 27
      local.set 2
      local.get 0
      struct.get 35 1
      i32.const 0
      local.set 4
      local.get 0
      struct.get 35 0
      ref.cast (ref 34)
      local.get 1
      call 47
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      local.get 6
      array.set 0
      local.get 2
    else
      unreachable
    end
    ref.cast (ref 33)
  )
  (func (;21;) (type 101) (param (ref 33)) (result i32)
    local.get 0
    struct.get 33 0
  )
  (func (;22;) (type 102) (param (ref 34) (ref 8) i32 (ref 8) i32) (result (ref 35))
    local.get 0
    ref.cast (ref 34)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    ref.cast (ref 8)
    local.get 2
    call 48
    call 3
    ref.cast (ref 15)
    local.get 3
    ref.cast (ref 8)
    local.get 4
    struct.new 35
    ref.cast (ref 35)
  )
  (func (;23;) (type 103) (param (ref 34))
    (local eqref i32 eqref)
    local.get 0
    struct.get 34 0
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 1
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 2
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 3
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 4
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 5
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    struct.get 34 6
    local.set 1
    local.get 1
    ref.cast (ref 15)
    i32.const 0
    struct.set 15 1
    local.get 0
    ref.cast (ref 34)
    i32.const -1
    call 41
    local.get 0
    ref.cast (ref 34)
    i32.const 0
    call 38
  )
  (func (;24;) (type 104) (param (ref 34)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 34 8
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
  )
  (func (;25;) (type 105) (param (ref 34)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 34 7
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
  )
  (func (;26;) (type 106) (param (ref 34) i32) (result i32)
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
            ref.cast (ref 34)
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
  (func (;27;) (type 107) (param (ref 34) i32) (result (ref 33))
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 45
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 49
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 33
    ref.cast (ref 33)
  )
  (func (;28;) (type 108) (param (ref 34) i32) (result i32)
    (local i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 34)
    call 25
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
            ref.cast (ref 34)
            local.get 1
            local.get 2
            call 40
            local.set 3
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 3
                      ref.cast (ref 10)
                      struct.get 10 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 0
                    ref.cast (ref 34)
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
                ref.cast (ref 34)
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
  (func (;29;) (type 109) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      struct.get 34 5
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 3
      array.get 0
    end
  )
  (func (;30;) (type 110) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 34 3
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 3
      array.get 0
    end
  )
  (func (;31;) (type 111) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 34 4
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 3
      array.get 0
    end
  )
  (func (;32;) (type 112) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const -1
    else
      local.get 0
      struct.get 34 2
      local.get 1
      call 5
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 3
      array.get 0
    end
  )
  (func (;33;) (type 113) (param (ref 34) i32 i32)
    (local i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 32
    local.set 3
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 41
    else
      local.get 1
      local.get 0
      ref.cast (ref 34)
      local.get 3
      call 30
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 34)
        local.get 3
        local.get 2
        call 36
      else
        local.get 0
        ref.cast (ref 34)
        local.get 3
        local.get 2
        call 35
      end
    end
    local.get 0
    ref.cast (ref 34)
    local.get 2
    local.get 3
    call 34
  )
  (func (;34;) (type 114) (param (ref 34) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 34 2
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      local.get 6
      array.set 0
    else
      call 2
    end
  )
  (func (;35;) (type 115) (param (ref 34) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 34 4
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      local.get 6
      array.set 0
    else
      call 2
    end
  )
  (func (;36;) (type 116) (param (ref 34) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 34 3
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      local.get 6
      array.set 0
    else
      call 2
    end
  )
  (func (;37;) (type 117) (param (ref 34) i32 i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const 0
    i32.ge_s
    if ;; label = @1
      local.get 0
      struct.get 34 5
      local.get 1
      call 5
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 15)
      struct.get 15 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 15)
      struct.get 15 0
      ref.cast (ref 0)
      local.get 4
      local.get 6
      array.set 0
    else
      call 2
    end
  )
  (func (;38;) (type 118) (param (ref 34) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 34 8
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 3
    local.get 5
    array.set 0
  )
  (func (;39;) (type 119) (param (ref 34) i32 i32)
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
            ref.cast (ref 34)
            call 25
            i32.ne
            if (result i32) ;; label = @5
              local.get 0
              ref.cast (ref 34)
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
                ref.cast (ref 34)
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
                ref.cast (ref 34)
                call 25
                local.set 3
              else
                local.get 3
                local.get 0
                ref.cast (ref 34)
                local.get 5
                call 30
                i32.eq
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 34)
                  local.get 5
                  call 31
                  local.set 6
                  local.get 0
                  ref.cast (ref 34)
                  local.get 6
                  call 29
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    i32.const 1
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 50
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 31
                    local.set 6
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 34)
                  local.get 0
                  ref.cast (ref 34)
                  local.get 6
                  call 30
                  call 29
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    call 31
                    call 29
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    i32.const 1
                    call 37
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 34)
                    local.get 3
                    call 32
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    call 31
                    call 29
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 34)
                      local.get 0
                      ref.cast (ref 34)
                      local.get 6
                      call 30
                      i32.const 0
                      call 37
                      local.get 0
                      ref.cast (ref 34)
                      local.get 6
                      i32.const 1
                      call 37
                      local.get 0
                      ref.cast (ref 34)
                      local.get 6
                      call 51
                      local.get 0
                      ref.cast (ref 34)
                      local.get 5
                      call 31
                      local.set 6
                    else
                      call 2
                    end
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 29
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 6
                    call 31
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 50
                    local.get 0
                    ref.cast (ref 34)
                    call 25
                    local.set 3
                    i32.const -1
                    local.set 4
                  end
                else
                  local.get 0
                  ref.cast (ref 34)
                  local.get 5
                  call 30
                  local.set 7
                  local.get 0
                  ref.cast (ref 34)
                  local.get 7
                  call 29
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    i32.const 1
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 51
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 30
                    local.set 7
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 34)
                  local.get 0
                  ref.cast (ref 34)
                  local.get 7
                  call 31
                  call 29
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    call 30
                    call 29
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    i32.const 1
                    call 37
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 34)
                    local.get 3
                    call 32
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    call 30
                    call 29
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 34)
                      local.get 0
                      ref.cast (ref 34)
                      local.get 7
                      call 31
                      i32.const 0
                      call 37
                      local.get 0
                      ref.cast (ref 34)
                      local.get 7
                      i32.const 1
                      call 37
                      local.get 0
                      ref.cast (ref 34)
                      local.get 7
                      call 50
                      local.get 0
                      ref.cast (ref 34)
                      local.get 5
                      call 30
                      local.set 7
                    else
                      call 2
                    end
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 29
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 0
                    ref.cast (ref 34)
                    local.get 7
                    call 30
                    i32.const 0
                    call 37
                    local.get 0
                    ref.cast (ref 34)
                    local.get 5
                    call 51
                    local.get 0
                    ref.cast (ref 34)
                    call 25
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
    ref.cast (ref 34)
    local.get 3
    i32.const 0
    call 37
  )
  (func (;40;) (type 120) (param (ref 34) i32 i32) (result (ref 10))
    local.get 0
    struct.get 34 14
    ref.cast (ref 11)
    local.get 1
    local.get 0
    ref.cast (ref 34)
    local.get 2
    call 45
    call 1
    ref.cast (ref 10)
  )
  (func (;41;) (type 121) (param (ref 34) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 34 7
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 3
    local.get 5
    array.set 0
  )
  (func (;42;) (type 122) (param (ref 34) i32)
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
            ref.cast (ref 34)
            local.get 0
            ref.cast (ref 34)
            local.get 2
            call 32
            call 29
            if ;; label = @5
              local.get 0
              ref.cast (ref 34)
              local.get 2
              call 32
              local.set 3
              local.get 0
              ref.cast (ref 34)
              local.get 3
              call 32
              local.set 4
              local.get 3
              local.get 0
              ref.cast (ref 34)
              local.get 4
              call 30
              i32.eq
              if ;; label = @6
                local.get 0
                ref.cast (ref 34)
                local.get 4
                call 31
                local.set 5
                local.get 0
                ref.cast (ref 34)
                local.get 5
                call 29
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 34)
                  local.get 3
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 5
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 4
                  i32.const 1
                  call 37
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 34)
                  local.get 3
                  call 31
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 34)
                    local.get 2
                    call 50
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 34)
                  local.get 2
                  call 32
                  local.set 6
                  local.get 0
                  ref.cast (ref 34)
                  local.get 6
                  call 32
                  local.set 7
                  local.get 0
                  ref.cast (ref 34)
                  local.get 6
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 7
                  i32.const 1
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 7
                  call 51
                end
              else
                local.get 0
                ref.cast (ref 34)
                local.get 4
                call 30
                local.set 8
                local.get 0
                ref.cast (ref 34)
                local.get 8
                call 29
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 34)
                  local.get 3
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 8
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 4
                  i32.const 1
                  call 37
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 34)
                  local.get 3
                  call 30
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 34)
                    local.get 2
                    call 51
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 34)
                  local.get 2
                  call 32
                  local.set 9
                  local.get 0
                  ref.cast (ref 34)
                  local.get 9
                  call 32
                  local.set 10
                  local.get 0
                  ref.cast (ref 34)
                  local.get 9
                  i32.const 0
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 10
                  i32.const 1
                  call 37
                  local.get 0
                  ref.cast (ref 34)
                  local.get 10
                  call 50
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
    ref.cast (ref 34)
    local.get 0
    ref.cast (ref 34)
    call 25
    i32.const 0
    call 37
  )
  (func (;43;) (type 123) (param (ref 34) i32) (result i32)
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
            ref.cast (ref 34)
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
  (func (;44;) (type 124) (param (ref 34) i32 i32) (result i32)
    (local i32 i32 eqref i32 i32)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 34)
    call 25
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
            ref.cast (ref 34)
            local.get 1
            local.get 4
            call 40
            local.set 5
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 5
                      ref.cast (ref 10)
                      struct.get 10 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 4
                    local.set 3
                    local.get 0
                    ref.cast (ref 34)
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
                    ref.cast (ref 34)
                    local.get 4
                    call 31
                    local.set 6
                    br 6 (;@2;)
                  end
                  br 2 (;@5;)
                end
                local.get 0
                ref.cast (ref 34)
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
  (func (;45;) (type 125) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 34 0
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
  )
  (func (;46;) (type 126) (param (ref 34) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 30
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 43
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 34)
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
                ref.cast (ref 34)
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
                ref.cast (ref 34)
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
  (func (;47;) (type 127) (param (ref 34) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 31
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 26
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 34)
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
                ref.cast (ref 34)
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
                ref.cast (ref 34)
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
  (func (;48;) (type 128) (param (ref 34) (ref 8) i32) (result i32)
    (local i32 eqref i32)
    local.get 1
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 0
          ref.cast (ref 34)
          local.get 0
          ref.cast (ref 34)
          call 25
          call 26
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        local.set 3
        local.get 0
        ref.cast (ref 34)
        local.get 3
        local.get 2
        call 44
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;49;) (type 129) (param (ref 34) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 34 1
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 15)
    struct.get 15 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 15)
    struct.get 15 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
  )
  (func (;50;) (type 130) (param (ref 34) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 31
    local.set 2
    local.get 0
    ref.cast (ref 34)
    local.get 2
    call 30
    local.set 3
    local.get 0
    ref.cast (ref 34)
    local.get 1
    local.get 3
    call 35
    local.get 0
    ref.cast (ref 34)
    local.get 3
    local.get 1
    call 34
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 32
    local.set 4
    local.get 0
    ref.cast (ref 34)
    local.get 2
    local.get 4
    call 34
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 41
    else
      local.get 1
      local.get 0
      ref.cast (ref 34)
      local.get 4
      call 30
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 34)
        local.get 4
        local.get 2
        call 36
      else
        local.get 0
        ref.cast (ref 34)
        local.get 4
        local.get 2
        call 35
      end
    end
    local.get 0
    ref.cast (ref 34)
    local.get 2
    local.get 1
    call 36
    local.get 0
    ref.cast (ref 34)
    local.get 1
    local.get 2
    call 34
  )
  (func (;51;) (type 131) (param (ref 34) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 30
    local.set 2
    local.get 0
    ref.cast (ref 34)
    local.get 2
    call 31
    local.set 3
    local.get 0
    ref.cast (ref 34)
    local.get 1
    local.get 3
    call 36
    local.get 0
    ref.cast (ref 34)
    local.get 3
    local.get 1
    call 34
    local.get 0
    ref.cast (ref 34)
    local.get 1
    call 32
    local.set 4
    local.get 0
    ref.cast (ref 34)
    local.get 2
    local.get 4
    call 34
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 34)
      local.get 2
      call 41
    else
      local.get 1
      local.get 0
      ref.cast (ref 34)
      local.get 4
      call 31
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 34)
        local.get 4
        local.get 2
        call 35
      else
        local.get 0
        ref.cast (ref 34)
        local.get 4
        local.get 2
        call 36
      end
    end
    local.get 0
    ref.cast (ref 34)
    local.get 2
    local.get 1
    call 35
    local.get 0
    ref.cast (ref 34)
    local.get 1
    local.get 2
    call 34
  )
  (func (;52;) (type 152) (param eqref) (result (ref 132))
    local.get 0
    call 6
    ref.cast (ref 34)
    struct.new 132
    ref.cast (ref 132)
  )
  (func (;53;) (type 153) (param (ref 132)) (result i32)
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 7
  )
  (func (;54;) (type 154) (param (ref 132)) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 8
    call 69
    ref.cast (ref 8)
  )
  (func (;55;) (type 155) (param (ref 132) i32) (result i32)
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 9
  )
  (func (;56;) (type 156) (param (ref 132) i32) (result i32)
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    i32.const 1
    call 10
  )
  (func (;57;) (type 157) (param (ref 132)) (result i32)
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 11
  )
  (func (;58;) (type 158) (param (ref 132) i32) (result i32)
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 12
  )
  (func (;59;) (type 159) (param (ref 132)) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 13
    call 69
    ref.cast (ref 8)
  )
  (func (;60;) (type 160) (param (ref 132) i32) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 14
    call 69
    ref.cast (ref 8)
  )
  (func (;61;) (type 161) (param (ref 132) i32) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 15
    call 69
    ref.cast (ref 8)
  )
  (func (;62;) (type 162) (param (ref 132) i32) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 16
    call 69
    ref.cast (ref 8)
  )
  (func (;63;) (type 163) (param (ref 132) i32) (result (ref 8))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    call 17
    call 69
    ref.cast (ref 8)
  )
  (func (;64;) (type 164) (param (ref 132)) (result (ref 133))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 18
    ref.cast (ref 35)
    struct.new 133
    ref.cast (ref 133)
  )
  (func (;65;) (type 165) (param (ref 133)) (result i32)
    local.get 0
    struct.get 133 0
    ref.cast (ref 35)
    call 19
  )
  (func (;66;) (type 166) (param (ref 133)) (result i32)
    local.get 0
    struct.get 133 0
    ref.cast (ref 35)
    call 20
    call 21
  )
  (func (;67;) (type 167) (param (ref 132) (ref 8) i32 (ref 8) i32) (result (ref 133))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    local.get 1
    ref.cast (ref 8)
    local.get 2
    local.get 3
    ref.cast (ref 8)
    local.get 4
    call 22
    ref.cast (ref 35)
    struct.new 133
    ref.cast (ref 133)
  )
  (func (;68;) (type 168) (param (ref 132))
    local.get 0
    struct.get 132 0
    ref.cast (ref 34)
    call 23
  )
  (func (;69;) (type 169) (param (ref 8)) (result (ref 8))
    (local eqref eqref eqref)
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
          i32.const 0
          struct.new 8
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 6
        local.set 1
        i32.const 1
        local.get 1
        ref.cast (ref 33)
        call 21
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 9
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    ref.cast (ref 8)
  )
  (func (;70;) (type 170))
  (func (;71;) (type 171) (param (ref 8) i32) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 9)
        struct.get 9 1
        local.set 2
        local.get 2
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;72;) (type 172)
    (local eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32)
    call 0
    call 52
    local.set 0
    local.get 0
    ref.cast (ref 132)
    call 53
    v128.const i32x4 0x2077656e 0x20746573 0x74706d65 0x00000079
    array.new_fixed 173 1
    i32.const 0
    i32.const 13
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 54
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 7
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    v128.const i32x4 0x74706d65 0x696d2079 0x756d696e 0x0000006d
    array.new_fixed 173 1
    i32.const 0
    i32.const 13
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 1
    call 55
    i32.eqz
    v128.const i32x4 0x74706d65 0x65722079 0x65766f6d 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 12
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 4
    call 56
    v128.const i32x4 0x65736e69 0x66207472 0x0072756f 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 11
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 1
    call 56
    v128.const i32x4 0x65736e69 0x6f207472 0x0000656e 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 10
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 56
    v128.const i32x4 0x65736e69 0x74207472 0x65657268 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 12
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 2
    call 56
    v128.const i32x4 0x65736e69 0x74207472 0x00006f77 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 10
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 56
    i32.eqz
    v128.const i32x4 0x6c707564 0x74616369 0x64692065 0x6f706d65
    v128.const i32x4 0x746e6574 0x00000000 0x00000000 0x00000000
    array.new_fixed 173 2
    i32.const 0
    i32.const 20
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 132)
    i32.const 5
    call 56
    v128.const i32x4 0x61696c61 0x6e692073 0x74726573 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 12
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 57
    i32.const 5
    i32.eq
    v128.const i32x4 0x61696c61 0x656c2073 0x6874676e 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 12
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 58
    v128.const i32x4 0x746e6f63 0x736e6961 0x00000000 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 8
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 9
    call 58
    i32.eqz
    v128.const i32x4 0x7373696d 0x20676e69 0x746e6f63 0x736e6961
    array.new_fixed 173 1
    i32.const 0
    i32.const 16
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 54
    i32.const -1
    call 71
    i32.const 1
    i32.eq
    v128.const i32x4 0x696e696d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 7
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 59
    i32.const -1
    call 71
    i32.const 5
    i32.eq
    v128.const i32x4 0x6978616d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 7
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 60
    i32.const -1
    call 71
    i32.const 3
    i32.eq
    v128.const i32x4 0x65776f6c 0x6f622072 0x00646e75 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 11
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 61
    i32.const -1
    call 71
    i32.const 4
    i32.eq
    v128.const i32x4 0x65707075 0x6f622072 0x00646e75 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 11
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 62
    i32.const -1
    call 71
    i32.const 2
    i32.eq
    v128.const i32x4 0x64657270 0x73656365 0x00726f73 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 11
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 63
    i32.const -1
    call 71
    i32.const 4
    i32.eq
    v128.const i32x4 0x63637573 0x6f737365 0x00000072 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 9
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 1
    call 62
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 8)
      struct.get 8 0
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
    v128.const i32x4 0x70206f6e 0x65646572 0x73736563 0x0000726f
    array.new_fixed 173 1
    i32.const 0
    i32.const 14
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 5
    call 63
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
    v128.const i32x4 0x73206f6e 0x65636375 0x726f7373 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 12
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 64
    local.set 2
    i32.const 1
    local.set 3
    i32.const 1
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 12
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 2
            ref.cast (ref 133)
            call 65
            if ;; label = @5
              local.get 2
              ref.cast (ref 133)
              call 66
              local.get 3
              i32.eq
              v128.const i32x4 0x20746573 0x6564726f 0x00000072 0x00000000
              array.new_fixed 173 1
              i32.const 0
              i32.const 9
              struct.new 174
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 3
              i32.const 1
              i32.add
              local.set 3
              i32.const 1
              local.set 12
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 70
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
    v128.const i32x4 0x20746573 0x72657469 0x726f7461 0x756f6320
    v128.const i32x4 0x0000746e 0x00000000 0x00000000 0x00000000
    array.new_fixed 173 2
    i32.const 0
    i32.const 18
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 1
    i32.const 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 9
    i32.const 1
    i32.const 1
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 9
    i32.const 0
    call 67
    local.set 4
    i32.const 2
    local.set 5
    i32.const 1
    local.set 13
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 13
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 133)
            call 65
            if ;; label = @5
              local.get 4
              ref.cast (ref 133)
              call 66
              local.get 5
              i32.eq
              v128.const i32x4 0x20746573 0x676e6172 0x00000065 0x00000000
              array.new_fixed 173 1
              i32.const 0
              i32.const 9
              struct.new 174
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 5
              i32.const 1
              i32.add
              local.set 5
              i32.const 1
              local.set 13
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 70
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
    i32.const 5
    i32.eq
    v128.const i32x4 0x20746573 0x676e6172 0x6f622065 0x61646e75
    v128.const i32x4 0x73656972 0x00000000 0x00000000 0x00000000
    array.new_fixed 173 2
    i32.const 0
    i32.const 20
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 55
    v128.const i32x4 0x6f6d6572 0x65206576 0x74736978 0x00676e69
    array.new_fixed 173 1
    i32.const 0
    i32.const 15
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 58
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x65736261 0x0000746e
    array.new_fixed 173 1
    i32.const 0
    i32.const 14
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    i32.const 3
    call 55
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x69206576 0x706d6564 0x6e65746f
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 173 2
    i32.const 0
    i32.const 17
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 132)
    call 68
    local.get 0
    ref.cast (ref 132)
    call 53
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 173 1
    i32.const 0
    i32.const 11
    struct.new 174
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
