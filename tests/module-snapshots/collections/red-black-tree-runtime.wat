(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (struct))
  (type (;5;) (func (result (ref 4))))
  (type (;6;) (func (param (ref 4) eqref eqref) (result (ref 3))))
  (type (;7;) (func (param (ref 4) i32 i32) (result (ref 3))))
  (type (;8;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;9;) (struct (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field (ref 2)) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;10;) (struct (field (ref 9)) (field (ref 2)) (field (ref 0)) (field i32)))
  (type (;11;) (func))
  (type (;12;) (func (result (ref 0))))
  (type (;13;) (func (param i32) (result (ref 2))))
  (type (;14;) (func (param i32) (result (ref 2))))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (param (ref 9)) (result i32)))
  (type (;17;) (func (param (ref 9) i32)))
  (type (;18;) (func (param (ref 9)) (result i32)))
  (type (;19;) (func (param (ref 9) i32)))
  (type (;20;) (func (param (ref 9) i32) (result i32)))
  (type (;21;) (func (param (ref 9) i32) (result i32)))
  (type (;22;) (func (param (ref 9) i32) (result i32)))
  (type (;23;) (func (param (ref 9) i32) (result i32)))
  (type (;24;) (func (param (ref 9) i32 i32)))
  (type (;25;) (func (param (ref 9) i32 i32)))
  (type (;26;) (func (param (ref 9) i32 i32)))
  (type (;27;) (func (param (ref 9) i32 i32)))
  (type (;28;) (func (param (ref 9) i32) (result eqref)))
  (type (;29;) (func (param (ref 9) i32) (result eqref)))
  (type (;30;) (func (param (ref 9) i32) (result (ref 8))))
  (type (;31;) (func (param eqref) (result (ref 9))))
  (type (;32;) (func (param (ref 9)) (result i32)))
  (type (;33;) (func (param (ref 9)) (result i32)))
  (type (;34;) (func (param (ref 9) eqref i32) (result (ref 3))))
  (type (;35;) (func (param (ref 9) eqref) (result i32)))
  (type (;36;) (func (param (ref 9) i32) (result i32)))
  (type (;37;) (func (param (ref 9) i32) (result i32)))
  (type (;38;) (func (param (ref 9) i32) (result i32)))
  (type (;39;) (func (param (ref 9) i32) (result i32)))
  (type (;40;) (func (param (ref 9) i32)))
  (type (;41;) (func (param (ref 9) i32)))
  (type (;42;) (func (param (ref 9) i32)))
  (type (;43;) (func (param (ref 9) eqref eqref) (result i32)))
  (type (;44;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;45;) (func (param (ref 9) eqref) (result i32)))
  (type (;46;) (func (param (ref 9) i32 i32)))
  (type (;47;) (func (param (ref 9) i32 i32)))
  (type (;48;) (func (param (ref 9) eqref) (result i32)))
  (type (;49;) (func (param (ref 9)) (result (ref 0))))
  (type (;50;) (func (param (ref 9)) (result (ref 0))))
  (type (;51;) (func (param (ref 9) eqref i32) (result i32)))
  (type (;52;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;53;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;54;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;55;) (func (param (ref 9) eqref) (result (ref 0))))
  (type (;56;) (func (param (ref 8)) (result eqref)))
  (type (;57;) (func (param (ref 8)) (result eqref)))
  (type (;58;) (func (param (ref 9))))
  (type (;59;) (func (param (ref 9) (ref 0) i32) (result i32)))
  (type (;60;) (func (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;61;) (func (param (ref 9)) (result (ref 10))))
  (type (;62;) (func (param (ref 10)) (result i32)))
  (type (;63;) (func (param (ref 10)) (result (ref 8))))
  (type (;64;) (func (param (ref 9)) (result i32)))
  (type (;65;) (func (param (ref 8)) (result i32)))
  (type (;66;) (func (param (ref 8)) (result i32)))
  (type (;67;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;68;) (func (param eqref) (result (ref 9))))
  (type (;69;) (func (param (ref 9)) (result i32)))
  (type (;70;) (func (param (ref 9)) (result i32)))
  (type (;71;) (func (param (ref 9)) (result (ref 0))))
  (type (;72;) (func (param (ref 9)) (result (ref 0))))
  (type (;73;) (func (param (ref 9) i32) (result i32)))
  (type (;74;) (func (param (ref 9) i32 i32) (result i32)))
  (type (;75;) (func (param (ref 9)) (result i32)))
  (type (;76;) (func (param (ref 9) i32) (result i32)))
  (type (;77;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;78;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;79;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;80;) (func (param (ref 9) i32) (result (ref 0))))
  (type (;81;) (func (param (ref 9)) (result (ref 10))))
  (type (;82;) (func (param (ref 10)) (result i32)))
  (type (;83;) (func (param (ref 10)) (result (ref 8))))
  (type (;84;) (func (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))))
  (type (;85;) (func (param (ref 9))))
  (type (;86;) (func (param (ref 9) i32) (result i32)))
  (type (;87;) (func (param (ref 9) i32) (result i32)))
  (type (;88;) (func (param (ref 9)) (result i32)))
  (type (;89;) (func (param (ref 9)) (result i32)))
  (type (;90;) (func (param (ref 9) i32) (result i32)))
  (type (;91;) (func (param (ref 9) i32) (result i32)))
  (type (;92;) (func (param (ref 9) i32) (result i32)))
  (type (;93;) (func (param (ref 9) i32) (result i32)))
  (type (;94;) (func (result (ref 0))))
  (type (;95;) (func (param (ref 9) i32) (result i32)))
  (type (;96;) (func (param (ref 9) i32) (result (ref 8))))
  (type (;97;) (func (param (ref 9) i32) (result i32)))
  (type (;98;) (func (param (ref 9) i32 i32)))
  (type (;99;) (func (param (ref 9) i32 i32)))
  (type (;100;) (func (param (ref 9) i32 i32)))
  (type (;101;) (func (param (ref 9) i32 i32)))
  (type (;102;) (func (param (ref 9) i32 i32)))
  (type (;103;) (func (param (ref 9) i32)))
  (type (;104;) (func (param (ref 9) i32 i32)))
  (type (;105;) (func (param (ref 9) i32 i32) (result (ref 3))))
  (type (;106;) (func (param (ref 9) i32)))
  (type (;107;) (func (param (ref 9) i32)))
  (type (;108;) (func (param (ref 9) i32 i32) (result i32)))
  (type (;109;) (func (param (ref 9) i32) (result i32)))
  (type (;110;) (func (param (ref 9) i32) (result i32)))
  (type (;111;) (func (param (ref 9) i32) (result i32)))
  (type (;112;) (func (param (ref 9) (ref 0) i32) (result i32)))
  (type (;113;) (func (param (ref 9) i32)))
  (type (;114;) (func (param (ref 9) i32)))
  (type (;115;) (func))
  (type (;116;) (func (param (ref 0) i32) (result i32)))
  (type (;117;) (func (param (ref 0) i32) (result i32)))
  (type (;118;) (func (param (ref 9) i32 i32) (result i32)))
  (type (;119;) (func))
  (type (;120;) (array (mut v128)))
  (type (;121;) (struct (field (ref 120)) (field i32) (field i32)))
  (type (;122;) (struct (field (ref 120)) (field i32) (field i32)))
  (type (;123;) (struct (field (ref 120)) (field i32) (field i32)))
  (type (;124;) (struct (field (mut (ref 120))) (field (mut i32)) (field (mut i32))))
  (type (;125;) (struct (field (mut (ref 120))) (field (mut i32)) (field (mut i32))))
  (type (;126;) (array (mut i32)))
  (type (;127;) (array (mut i64)))
  (type (;128;) (array (mut f32)))
  (type (;129;) (array (mut f64)))
  (type (;130;) (array (mut v128)))
  (type (;131;) (array (mut eqref)))
  (export "main" (func 60))
  (func (;0;) (type 5) (result (ref 4))
    struct.new 4
    ref.cast (ref 4)
  )
  (func (;1;) (type 7) (param (ref 4) i32 i32) (result (ref 3))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 3
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 3
      else
        i32.const 2
        struct.new 3
      end
    end
    ref.cast (ref 3)
  )
  (func (;2;) (type 11))
  (func (;3;) (type 13) (param i32) (result (ref 2))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 126
    i32.const 0
    local.get 3
    struct.new 2
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 2
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 126
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 126)
          local.get 3
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 3
          array.get 126
          array.set 126
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 2)
      local.get 4
      struct.set 2 0
      local.get 2
      ref.cast (ref 2)
      local.get 4
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 5
    array.set 126
    local.get 2
    ref.cast (ref 2)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    ref.cast (ref 2)
  )
  (func (;4;) (type 14) (param i32) (result (ref 2))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 3
    local.get 3
    array.new_default 126
    i32.const 0
    local.get 3
    struct.new 2
    local.set 1
    local.get 1
    local.get 0
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 2
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 126
      local.set 4
      i32.const 0
      local.set 3
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          local.get 2
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 4
          ref.cast (ref 126)
          local.get 3
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 3
          array.get 126
          array.set 126
          local.get 3
          i32.const 1
          i32.add
          local.set 3
          br 0 (;@3;)
        end
      end
      local.get 2
      ref.cast (ref 2)
      local.get 4
      struct.set 2 0
      local.get 2
      ref.cast (ref 2)
      local.get 4
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 5
    array.set 126
    local.get 2
    ref.cast (ref 2)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    ref.cast (ref 2)
  )
  (func (;5;) (type 15) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 65) (param (ref 8)) (result i32)
    local.get 0
    struct.get 8 0
  )
  (func (;7;) (type 66) (param (ref 8)) (result i32)
    local.get 0
    struct.get 8 6
  )
  (func (;8;) (type 67) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 27
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
      call 28
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;9;) (type 68) (param eqref) (result (ref 9))
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
    i32.const -1
    call 3
    ref.cast (ref 2)
    i32.const 0
    call 4
    ref.cast (ref 2)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 9
    ref.cast (ref 9)
  )
  (func (;10;) (type 69) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    call 29
    i32.const 0
    i32.eq
  )
  (func (;11;) (type 70) (param (ref 9)) (result i32)
    (local i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 (ref 10) eqref (ref 8) i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 eqref eqref i32)
    local.get 0
    ref.cast (ref 9)
    call 30
    local.set 1
    local.get 1
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 1
      call 31
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      array.new_default 126
      i32.const 0
      i32.const 0
      struct.new 2
      local.set 2
      i32.const 0
      array.new_default 126
      i32.const 0
      i32.const 0
      struct.new 2
      local.set 3
      local.get 2
      local.get 1
      local.set 20
      local.set 17
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      local.get 17
      ref.cast (ref 2)
      struct.get 2 2
      i32.eq
      if ;; label = @2
        local.get 17
        ref.cast (ref 2)
        struct.get 2 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 17
          ref.cast (ref 2)
          struct.get 2 2
          i32.const 2
          i32.mul
        end
        local.set 18
        local.get 18
        local.get 17
        ref.cast (ref 2)
        struct.get 2 2
        i32.le_u
        if ;; label = @3
          unreachable
        end
        local.get 18
        array.new_default 126
        local.set 19
        i32.const 0
        local.set 18
        block ;; label = @3
          loop ;; label = @4
            local.get 18
            local.get 17
            ref.cast (ref 2)
            struct.get 2 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 19
            ref.cast (ref 126)
            local.get 18
            local.get 17
            ref.cast (ref 2)
            struct.get 2 0
            ref.cast (ref 126)
            local.get 18
            array.get 126
            array.set 126
            local.get 18
            i32.const 1
            i32.add
            local.set 18
            br 0 (;@4;)
          end
        end
        local.get 17
        ref.cast (ref 2)
        local.get 19
        struct.set 2 0
        local.get 17
        ref.cast (ref 2)
        local.get 19
        ref.cast (ref 126)
        array.len
        struct.set 2 2
      end
      local.get 17
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      local.get 20
      array.set 126
      local.get 17
      ref.cast (ref 2)
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.add
      struct.set 2 1
      local.get 3
      i32.const 0
      local.set 21
      local.set 17
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      local.get 17
      ref.cast (ref 2)
      struct.get 2 2
      i32.eq
      if ;; label = @2
        local.get 17
        ref.cast (ref 2)
        struct.get 2 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 17
          ref.cast (ref 2)
          struct.get 2 2
          i32.const 2
          i32.mul
        end
        local.set 18
        local.get 18
        local.get 17
        ref.cast (ref 2)
        struct.get 2 2
        i32.le_u
        if ;; label = @3
          unreachable
        end
        local.get 18
        array.new_default 126
        local.set 19
        i32.const 0
        local.set 18
        block ;; label = @3
          loop ;; label = @4
            local.get 18
            local.get 17
            ref.cast (ref 2)
            struct.get 2 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 19
            ref.cast (ref 126)
            local.get 18
            local.get 17
            ref.cast (ref 2)
            struct.get 2 0
            ref.cast (ref 126)
            local.get 18
            array.get 126
            array.set 126
            local.get 18
            i32.const 1
            i32.add
            local.set 18
            br 0 (;@4;)
          end
        end
        local.get 17
        ref.cast (ref 2)
        local.get 19
        struct.set 2 0
        local.get 17
        ref.cast (ref 2)
        local.get 19
        ref.cast (ref 126)
        array.len
        struct.set 2 2
      end
      local.get 17
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      local.get 21
      array.set 126
      local.get 17
      ref.cast (ref 2)
      local.get 17
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.add
      struct.set 2 1
      i32.const 0
      local.set 4
      i32.const -1
      local.set 5
      i32.const 0
      local.set 6
      i32.const 1
      local.set 7
      i32.const 1
      local.set 26
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 26
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 4
              local.get 2
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if ;; label = @6
                local.get 2
                local.get 4
                local.set 18
                local.set 17
                local.get 18
                local.get 17
                ref.cast (ref 2)
                struct.get 2 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 17
                ref.cast (ref 2)
                struct.get 2 0
                ref.cast (ref 126)
                local.get 18
                array.get 126
                local.set 8
                local.get 3
                local.get 4
                local.set 18
                local.set 17
                local.get 18
                local.get 17
                ref.cast (ref 2)
                struct.get 2 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 17
                ref.cast (ref 2)
                struct.get 2 0
                ref.cast (ref 126)
                local.get 18
                array.get 126
                local.set 9
                local.get 4
                i32.const 1
                i32.add
                local.set 4
                local.get 8
                i32.const 0
                i32.lt_s
                if ;; label = @7
                  local.get 5
                  i32.const -1
                  i32.eq
                  if ;; label = @8
                    local.get 9
                    local.set 5
                  else
                    local.get 5
                    local.get 9
                    i32.ne
                    if ;; label = @9
                      i32.const 0
                      local.set 7
                    else
                      call 2
                    end
                  end
                else
                  local.get 6
                  i32.const 1
                  i32.add
                  local.set 6
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  call 32
                  local.set 10
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  call 33
                  local.set 11
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  call 31
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 10
                    call 31
                    if (result i32) ;; label = @9
                      i32.const 1
                    else
                      local.get 0
                      ref.cast (ref 9)
                      local.get 11
                      call 31
                    end
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    i32.const 0
                    local.set 7
                  else
                    call 2
                  end
                  local.get 10
                  i32.const 0
                  i32.ge_s
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 10
                    call 34
                    local.get 8
                    i32.ne
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    i32.const 0
                    local.set 7
                  else
                    call 2
                  end
                  local.get 11
                  i32.const 0
                  i32.ge_s
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 11
                    call 34
                    local.get 8
                    i32.ne
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    i32.const 0
                    local.set 7
                  else
                    call 2
                  end
                  local.get 9
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  call 31
                  if (result i32) ;; label = @8
                    i32.const 0
                  else
                    i32.const 1
                  end
                  i32.add
                  local.set 12
                  local.get 2
                  local.get 10
                  local.set 22
                  local.set 17
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 2
                  i32.eq
                  if ;; label = @8
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.eqz
                    if (result i32) ;; label = @9
                      i32.const 4
                    else
                      local.get 17
                      ref.cast (ref 2)
                      struct.get 2 2
                      i32.const 2
                      i32.mul
                    end
                    local.set 18
                    local.get 18
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.le_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 18
                    array.new_default 126
                    local.set 19
                    i32.const 0
                    local.set 18
                    block ;; label = @9
                      loop ;; label = @10
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 1
                        i32.ge_u
                        br_if 1 (;@9;)
                        local.get 19
                        ref.cast (ref 126)
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 0
                        ref.cast (ref 126)
                        local.get 18
                        array.get 126
                        array.set 126
                        local.get 18
                        i32.const 1
                        i32.add
                        local.set 18
                        br 0 (;@10;)
                      end
                    end
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    struct.set 2 0
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    ref.cast (ref 126)
                    array.len
                    struct.set 2 2
                  end
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 126)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 22
                  array.set 126
                  local.get 17
                  ref.cast (ref 2)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.const 1
                  i32.add
                  struct.set 2 1
                  local.get 3
                  local.get 12
                  local.set 23
                  local.set 17
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 2
                  i32.eq
                  if ;; label = @8
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.eqz
                    if (result i32) ;; label = @9
                      i32.const 4
                    else
                      local.get 17
                      ref.cast (ref 2)
                      struct.get 2 2
                      i32.const 2
                      i32.mul
                    end
                    local.set 18
                    local.get 18
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.le_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 18
                    array.new_default 126
                    local.set 19
                    i32.const 0
                    local.set 18
                    block ;; label = @9
                      loop ;; label = @10
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 1
                        i32.ge_u
                        br_if 1 (;@9;)
                        local.get 19
                        ref.cast (ref 126)
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 0
                        ref.cast (ref 126)
                        local.get 18
                        array.get 126
                        array.set 126
                        local.get 18
                        i32.const 1
                        i32.add
                        local.set 18
                        br 0 (;@10;)
                      end
                    end
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    struct.set 2 0
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    ref.cast (ref 126)
                    array.len
                    struct.set 2 2
                  end
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 126)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 23
                  array.set 126
                  local.get 17
                  ref.cast (ref 2)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.const 1
                  i32.add
                  struct.set 2 1
                  local.get 2
                  local.get 11
                  local.set 24
                  local.set 17
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 2
                  i32.eq
                  if ;; label = @8
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.eqz
                    if (result i32) ;; label = @9
                      i32.const 4
                    else
                      local.get 17
                      ref.cast (ref 2)
                      struct.get 2 2
                      i32.const 2
                      i32.mul
                    end
                    local.set 18
                    local.get 18
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.le_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 18
                    array.new_default 126
                    local.set 19
                    i32.const 0
                    local.set 18
                    block ;; label = @9
                      loop ;; label = @10
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 1
                        i32.ge_u
                        br_if 1 (;@9;)
                        local.get 19
                        ref.cast (ref 126)
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 0
                        ref.cast (ref 126)
                        local.get 18
                        array.get 126
                        array.set 126
                        local.get 18
                        i32.const 1
                        i32.add
                        local.set 18
                        br 0 (;@10;)
                      end
                    end
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    struct.set 2 0
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    ref.cast (ref 126)
                    array.len
                    struct.set 2 2
                  end
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 126)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 24
                  array.set 126
                  local.get 17
                  ref.cast (ref 2)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.const 1
                  i32.add
                  struct.set 2 1
                  local.get 3
                  local.get 12
                  local.set 25
                  local.set 17
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 2
                  i32.eq
                  if ;; label = @8
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.eqz
                    if (result i32) ;; label = @9
                      i32.const 4
                    else
                      local.get 17
                      ref.cast (ref 2)
                      struct.get 2 2
                      i32.const 2
                      i32.mul
                    end
                    local.set 18
                    local.get 18
                    local.get 17
                    ref.cast (ref 2)
                    struct.get 2 2
                    i32.le_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 18
                    array.new_default 126
                    local.set 19
                    i32.const 0
                    local.set 18
                    block ;; label = @9
                      loop ;; label = @10
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 1
                        i32.ge_u
                        br_if 1 (;@9;)
                        local.get 19
                        ref.cast (ref 126)
                        local.get 18
                        local.get 17
                        ref.cast (ref 2)
                        struct.get 2 0
                        ref.cast (ref 126)
                        local.get 18
                        array.get 126
                        array.set 126
                        local.get 18
                        i32.const 1
                        i32.add
                        local.set 18
                        br 0 (;@10;)
                      end
                    end
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    struct.set 2 0
                    local.get 17
                    ref.cast (ref 2)
                    local.get 19
                    ref.cast (ref 126)
                    array.len
                    struct.set 2 2
                  end
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 126)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.get 25
                  array.set 126
                  local.get 17
                  ref.cast (ref 2)
                  local.get 17
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.const 1
                  i32.add
                  struct.set 2 1
                end
                i32.const 1
                local.set 26
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 2
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
      local.get 0
      ref.cast (ref 9)
      call 29
      i32.ne
      if ;; label = @2
        i32.const 0
        local.set 7
      else
        call 2
      end
      local.get 0
      ref.cast (ref 9)
      call 22
      local.set 13
      call 35
      local.set 14
      i32.const 1
      local.set 29
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 29
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 13
              ref.cast (ref 10)
              call 23
              if ;; label = @6
                local.get 13
                ref.cast (ref 10)
                call 24
                local.set 15
                local.get 14
                local.set 28
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 28
                        ref.cast (ref 0)
                        struct.get 0 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;)
                      end
                      call 2
                      br 2 (;@7;)
                    end
                    local.get 28
                    ref.cast (ref 1)
                    struct.get 1 1
                    local.set 16
                    local.get 0
                    struct.get 9 14
                    ref.cast (ref 4)
                    local.get 16
                    local.get 15
                    struct.get 8 0
                    call 1
                    local.set 27
                    block ;; label = @9
                      local.get 27
                      ref.cast (ref 3)
                      struct.get 3 0
                      i32.const 0
                      i32.eq
                      if ;; label = @10
                        call 2
                        br 1 (;@9;)
                      end
                      local.get 27
                      ref.cast (ref 3)
                      struct.get 3 0
                      i32.const 1
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        i32.const 0
                      end
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 27
                        ref.cast (ref 3)
                        struct.get 3 0
                        i32.const 2
                        i32.eq
                        if (result i32) ;; label = @11
                          i32.const 1
                        else
                          i32.const 0
                        end
                      end
                      if ;; label = @10
                        i32.const 0
                        local.set 7
                        call 2
                        br 1 (;@9;)
                      end
                      unreachable
                    end
                    br 1 (;@7;)
                  end
                  unreachable
                end
                i32.const 1
                local.get 15
                struct.get 8 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                ref.null eq
                struct.new 1
                local.set 14
                i32.const 1
                local.set 29
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 2
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 7
    end
  )
  (func (;12;) (type 71) (param (ref 9)) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 30
    call 36
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
      call 37
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;13;) (type 72) (param (ref 9)) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 30
    call 38
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
      call 37
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;14;) (type 73) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32 eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 27
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
      call 31
      local.set 4
      i32.const -1
      local.set 5
      i32.const -1
      local.set 6
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 32
      i32.const 0
      i32.lt_s
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 33
        local.set 5
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 34
        local.set 6
        local.get 0
        ref.cast (ref 9)
        local.get 2
        local.get 5
        call 39
      else
        local.get 0
        ref.cast (ref 9)
        local.get 2
        call 33
        i32.const 0
        i32.lt_s
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 32
          local.set 5
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 34
          local.set 6
          local.get 0
          ref.cast (ref 9)
          local.get 2
          local.get 5
          call 39
        else
          local.get 0
          ref.cast (ref 9)
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 33
          call 36
          local.set 3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 31
          local.set 4
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 33
          local.set 5
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 34
          local.get 2
          i32.eq
          if ;; label = @4
            local.get 3
            local.set 6
            local.get 0
            ref.cast (ref 9)
            local.get 5
            local.get 3
            call 40
          else
            local.get 0
            ref.cast (ref 9)
            local.get 3
            call 34
            local.set 6
            local.get 0
            ref.cast (ref 9)
            local.get 3
            local.get 5
            call 39
            local.get 0
            ref.cast (ref 9)
            local.get 3
            local.get 0
            ref.cast (ref 9)
            local.get 2
            call 33
            call 41
            local.get 0
            ref.cast (ref 9)
            local.get 0
            ref.cast (ref 9)
            local.get 3
            call 33
            local.get 3
            call 40
          end
          local.get 0
          ref.cast (ref 9)
          local.get 2
          local.get 3
          call 39
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 32
          call 42
          local.get 0
          ref.cast (ref 9)
          local.get 0
          ref.cast (ref 9)
          local.get 3
          call 32
          local.get 3
          call 40
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 0
          ref.cast (ref 9)
          local.get 2
          call 31
          call 43
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 7
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 8
      local.get 10
      array.set 126
      local.get 0
      ref.cast (ref 9)
      local.get 0
      ref.cast (ref 9)
      call 29
      i32.const 1
      i32.sub
      call 44
      local.get 4
      i32.eqz
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 5
        local.get 6
        call 45
      else
        call 2
      end
      i32.const 1
    end
  )
  (func (;15;) (type 74) (param (ref 9) i32 i32) (result i32)
    (local i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 9)
    call 30
    local.set 4
    i32.const 1
    struct.new 3
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
              call 46
              local.set 5
              local.get 5
              local.set 11
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 11
                        ref.cast (ref 3)
                        struct.get 3 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;)
                      end
                      local.get 0
                      ref.cast (ref 9)
                      local.get 4
                      call 32
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
                    ref.cast (ref 2)
                    struct.get 2 1
                    i32.ge_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 7
                    ref.cast (ref 2)
                    struct.get 2 0
                    ref.cast (ref 126)
                    local.get 8
                    local.get 10
                    array.set 126
                    i32.const 0
                    return
                    br 2 (;@6;)
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  call 33
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
    ref.cast (ref 2)
    struct.get 2 1
    local.set 6
    local.get 0
    struct.get 9 0
    local.get 1
    local.set 13
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 13
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 1
    local.get 2
    local.set 14
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 14
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 2
    local.get 3
    local.set 15
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 15
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 3
    i32.const -1
    local.set 16
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 4
    i32.const -1
    local.set 17
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 17
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 5
    i32.const 1
    local.set 18
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 18
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    struct.get 9 6
    i32.const 1
    local.set 19
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 7
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 8
      local.get 8
      local.get 7
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 8
      array.new_default 126
      local.set 9
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 9
          ref.cast (ref 126)
          local.get 8
          local.get 7
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 8
          array.get 126
          array.set 126
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 7
      ref.cast (ref 2)
      local.get 9
      struct.set 2 0
      local.get 7
      ref.cast (ref 2)
      local.get 9
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    local.get 19
    array.set 126
    local.get 7
    ref.cast (ref 2)
    local.get 7
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 6
      call 47
    else
      local.get 5
      local.set 20
      block ;; label = @2
        local.get 20
        ref.cast (ref 3)
        struct.get 3 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 6
          call 42
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          local.get 0
          ref.cast (ref 9)
          local.get 3
          local.get 6
          call 41
          br 1 (;@2;)
        end
        unreachable
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    call 29
    i32.const 1
    i32.add
    call 44
    local.get 0
    ref.cast (ref 9)
    local.get 6
    call 48
    i32.const 1
  )
  (func (;16;) (type 75) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    call 29
  )
  (func (;17;) (type 76) (param (ref 9) i32) (result i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 27
    i32.const 0
    i32.ge_s
  )
  (func (;18;) (type 77) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 1
    call 49
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
      call 37
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;19;) (type 78) (param (ref 9) i32) (result (ref 0))
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 0
    call 49
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
      call 37
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;20;) (type 79) (param (ref 9) i32) (result (ref 0))
    (local i32 i32 eqref i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    i32.const 1
    call 49
    local.set 2
    local.get 2
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 0
      ref.cast (ref 9)
      call 30
      call 38
    else
      local.get 0
      struct.get 9 14
      ref.cast (ref 4)
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 50
      local.get 1
      call 1
      local.set 4
      block ;; label = @2
        local.get 4
        ref.cast (ref 3)
        struct.get 3 0
        i32.const 0
        i32.eq
        if ;; label = @3
          local.get 2
          local.set 5
          br 1 (;@2;)
        end
        local.get 4
        ref.cast (ref 3)
        struct.get 3 0
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
          ref.cast (ref 3)
          struct.get 3 0
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
          call 51
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
      call 37
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;21;) (type 80) (param (ref 9) i32) (result (ref 0))
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 19
    ref.cast (ref 0)
  )
  (func (;22;) (type 81) (param (ref 9)) (result (ref 10))
    local.get 0
    ref.cast (ref 9)
    i32.const 0
    struct.new 0
    i32.const 1
    i32.const 0
    struct.new 0
    i32.const 1
    call 25
    ref.cast (ref 10)
  )
  (func (;23;) (type 82) (param (ref 10)) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 eqref i32)
    local.get 0
    struct.get 10 1
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 4
    array.get 126
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
          ref.cast (ref 4)
          local.get 0
          struct.get 10 0
          ref.cast (ref 9)
          local.get 1
          call 50
          local.get 2
          call 1
          local.set 6
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    local.get 6
                    ref.cast (ref 3)
                    struct.get 3 0
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
  (func (;24;) (type 83) (param (ref 10)) (result (ref 8))
    (local i32 (ref 8) eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 10)
    call 23
    if (result eqref) ;; label = @1
      local.get 0
      struct.get 10 1
      i32.const 0
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      array.get 126
      local.set 1
      local.get 0
      struct.get 10 0
      ref.cast (ref 9)
      local.get 1
      call 37
      local.set 2
      local.get 0
      struct.get 10 1
      i32.const 0
      local.set 4
      local.get 0
      struct.get 10 0
      ref.cast (ref 9)
      local.get 1
      call 52
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      local.get 6
      array.set 126
      local.get 2
    else
      unreachable
    end
    ref.cast (ref 8)
  )
  (func (;25;) (type 84) (param (ref 9) (ref 0) i32 (ref 0) i32) (result (ref 10))
    local.get 0
    ref.cast (ref 9)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    local.get 2
    call 53
    call 3
    ref.cast (ref 2)
    local.get 3
    ref.cast (ref 0)
    local.get 4
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;26;) (type 85) (param (ref 9))
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 0
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 1
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 2
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 3
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 4
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 5
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    struct.get 9 6
    local.set 1
    local.get 1
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    ref.cast (ref 9)
    i32.const -1
    call 47
    local.get 0
    ref.cast (ref 9)
    i32.const 0
    call 44
  )
  (func (;27;) (type 86) (param (ref 9) i32) (result i32)
    (local i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 9)
    call 30
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
            call 46
            local.set 3
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 3
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 32
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
                call 33
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
  (func (;28;) (type 87) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 1
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 3
    array.get 126
  )
  (func (;29;) (type 88) (param (ref 9)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 8
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 2
    array.get 126
  )
  (func (;30;) (type 89) (param (ref 9)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 7
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 2
    array.get 126
  )
  (func (;31;) (type 90) (param (ref 9) i32) (result i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 3
      array.get 126
    end
  )
  (func (;32;) (type 91) (param (ref 9) i32) (result i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 3
      array.get 126
    end
  )
  (func (;33;) (type 92) (param (ref 9) i32) (result i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 3
      array.get 126
    end
  )
  (func (;34;) (type 93) (param (ref 9) i32) (result i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 3
      array.get 126
    end
  )
  (func (;35;) (type 94) (result (ref 0))
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;36;) (type 95) (param (ref 9) i32) (result i32)
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
            call 32
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
  (func (;37;) (type 96) (param (ref 9) i32) (result (ref 8))
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 50
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 28
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;38;) (type 97) (param (ref 9) i32) (result i32)
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
            call 33
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
  (func (;39;) (type 98) (param (ref 9) i32 i32)
    (local i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 34
    local.set 3
    local.get 3
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 47
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 32
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 3
        local.get 2
        call 42
      else
        local.get 0
        ref.cast (ref 9)
        local.get 3
        local.get 2
        call 41
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 3
    call 40
  )
  (func (;40;) (type 99) (param (ref 9) i32 i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      local.get 6
      array.set 126
    else
      call 2
    end
  )
  (func (;41;) (type 100) (param (ref 9) i32 i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      local.get 6
      array.set 126
    else
      call 2
    end
  )
  (func (;42;) (type 101) (param (ref 9) i32 i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      local.get 6
      array.set 126
    else
      call 2
    end
  )
  (func (;43;) (type 102) (param (ref 9) i32 i32)
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
      ref.cast (ref 2)
      struct.get 2 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 126)
      local.get 4
      local.get 6
      array.set 126
    else
      call 2
    end
  )
  (func (;44;) (type 103) (param (ref 9) i32)
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
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 3
    local.get 5
    array.set 126
  )
  (func (;45;) (type 104) (param (ref 9) i32 i32)
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
            call 30
            i32.ne
            if (result i32) ;; label = @5
              local.get 0
              ref.cast (ref 9)
              local.get 3
              call 31
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
                call 34
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
                call 30
                local.set 3
              else
                local.get 3
                local.get 0
                ref.cast (ref 9)
                local.get 5
                call 32
                i32.eq
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  call 33
                  local.set 6
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 31
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 1
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 54
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 33
                    local.set 6
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 32
                  call 31
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 33
                    call 31
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    i32.const 1
                    call 43
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 3
                    call 34
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 33
                    call 31
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 9)
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      call 32
                      i32.const 0
                      call 43
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      i32.const 1
                      call 43
                      local.get 0
                      ref.cast (ref 9)
                      local.get 6
                      call 55
                      local.get 0
                      ref.cast (ref 9)
                      local.get 5
                      call 33
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
                    call 31
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 6
                    call 33
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 54
                    local.get 0
                    ref.cast (ref 9)
                    call 30
                    local.set 3
                    i32.const -1
                    local.set 4
                  end
                else
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  call 32
                  local.set 7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 31
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 1
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 55
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 32
                    local.set 7
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 33
                  call 31
                  i32.eqz
                  if (result i32) ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 32
                    call 31
                    i32.eqz
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    i32.const 1
                    call 43
                    local.get 5
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 3
                    call 34
                    local.set 4
                  else
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 32
                    call 31
                    i32.eqz
                    if ;; label = @9
                      local.get 0
                      ref.cast (ref 9)
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      call 33
                      i32.const 0
                      call 43
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      i32.const 1
                      call 43
                      local.get 0
                      ref.cast (ref 9)
                      local.get 7
                      call 54
                      local.get 0
                      ref.cast (ref 9)
                      local.get 5
                      call 32
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
                    call 31
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 0
                    ref.cast (ref 9)
                    local.get 7
                    call 32
                    i32.const 0
                    call 43
                    local.get 0
                    ref.cast (ref 9)
                    local.get 5
                    call 55
                    local.get 0
                    ref.cast (ref 9)
                    call 30
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
    call 43
  )
  (func (;46;) (type 105) (param (ref 9) i32 i32) (result (ref 3))
    local.get 0
    struct.get 9 14
    ref.cast (ref 4)
    local.get 1
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 50
    call 1
    ref.cast (ref 3)
  )
  (func (;47;) (type 106) (param (ref 9) i32)
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
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 3
    local.get 5
    array.set 126
  )
  (func (;48;) (type 107) (param (ref 9) i32)
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
            call 34
            call 31
            if ;; label = @5
              local.get 0
              ref.cast (ref 9)
              local.get 2
              call 34
              local.set 3
              local.get 0
              ref.cast (ref 9)
              local.get 3
              call 34
              local.set 4
              local.get 3
              local.get 0
              ref.cast (ref 9)
              local.get 4
              call 32
              i32.eq
              if ;; label = @6
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 33
                local.set 5
                local.get 0
                ref.cast (ref 9)
                local.get 5
                call 31
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 5
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  i32.const 1
                  call 43
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  call 33
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 54
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 2
                  call 34
                  local.set 6
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  call 34
                  local.set 7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 6
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  i32.const 1
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 7
                  call 55
                end
              else
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 32
                local.set 8
                local.get 0
                ref.cast (ref 9)
                local.get 8
                call 31
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 8
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 4
                  i32.const 1
                  call 43
                  local.get 4
                  local.set 2
                else
                  local.get 2
                  local.get 0
                  ref.cast (ref 9)
                  local.get 3
                  call 32
                  i32.eq
                  if ;; label = @8
                    local.get 3
                    local.set 2
                    local.get 0
                    ref.cast (ref 9)
                    local.get 2
                    call 55
                  else
                    call 2
                  end
                  local.get 0
                  ref.cast (ref 9)
                  local.get 2
                  call 34
                  local.set 9
                  local.get 0
                  ref.cast (ref 9)
                  local.get 9
                  call 34
                  local.set 10
                  local.get 0
                  ref.cast (ref 9)
                  local.get 9
                  i32.const 0
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 10
                  i32.const 1
                  call 43
                  local.get 0
                  ref.cast (ref 9)
                  local.get 10
                  call 54
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
    call 30
    i32.const 0
    call 43
  )
  (func (;49;) (type 108) (param (ref 9) i32 i32) (result i32)
    (local i32 i32 eqref i32 i32)
    i32.const -1
    local.set 3
    local.get 0
    ref.cast (ref 9)
    call 30
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
            call 46
            local.set 5
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 5
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;) 3 (;@6;)
                    end
                    local.get 4
                    local.set 3
                    local.get 0
                    ref.cast (ref 9)
                    local.get 4
                    call 32
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
                    call 33
                    local.set 6
                    br 6 (;@2;)
                  end
                  br 2 (;@5;)
                end
                local.get 0
                ref.cast (ref 9)
                local.get 4
                call 33
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
  (func (;50;) (type 109) (param (ref 9) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 9 0
    local.get 1
    call 5
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 3
    array.get 126
  )
  (func (;51;) (type 110) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 32
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 38
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 34
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
                call 32
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
                call 34
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
  (func (;52;) (type 111) (param (ref 9) i32) (result i32)
    (local i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 33
    local.set 2
    local.get 2
    i32.const 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 36
    else
      local.get 1
      local.set 3
      local.get 0
      ref.cast (ref 9)
      local.get 3
      call 34
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
                call 33
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
                call 34
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
  (func (;53;) (type 112) (param (ref 9) (ref 0) i32) (result i32)
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
          call 30
          call 36
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
        call 49
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;54;) (type 113) (param (ref 9) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 33
    local.set 2
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 32
    local.set 3
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 3
    call 41
    local.get 0
    ref.cast (ref 9)
    local.get 3
    local.get 1
    call 40
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 34
    local.set 4
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 4
    call 40
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 47
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 4
      call 32
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 42
      else
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 41
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 1
    call 42
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 40
  )
  (func (;55;) (type 114) (param (ref 9) i32)
    (local i32 i32 i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 32
    local.set 2
    local.get 0
    ref.cast (ref 9)
    local.get 2
    call 33
    local.set 3
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 3
    call 42
    local.get 0
    ref.cast (ref 9)
    local.get 3
    local.get 1
    call 40
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 34
    local.set 4
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 4
    call 40
    local.get 4
    i32.const 0
    i32.lt_s
    if ;; label = @1
      local.get 0
      ref.cast (ref 9)
      local.get 2
      call 47
    else
      local.get 1
      local.get 0
      ref.cast (ref 9)
      local.get 4
      call 33
      i32.eq
      if ;; label = @2
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 41
      else
        local.get 0
        ref.cast (ref 9)
        local.get 4
        local.get 2
        call 42
      end
    end
    local.get 0
    ref.cast (ref 9)
    local.get 2
    local.get 1
    call 41
    local.get 0
    ref.cast (ref 9)
    local.get 1
    local.get 2
    call 40
  )
  (func (;56;) (type 115))
  (func (;57;) (type 116) (param (ref 0) i32) (result i32)
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
        call 6
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;58;) (type 117) (param (ref 0) i32) (result i32)
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
        call 7
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;59;) (type 118) (param (ref 9) i32 i32) (result i32)
    (local i32 eqref i32)
    local.get 0
    ref.cast (ref 9)
    local.get 1
    call 8
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
  (func (;60;) (type 119)
    (local eqref eqref i32 i32 eqref i32 eqref eqref i32 eqref i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    call 0
    call 9
    local.set 0
    local.get 0
    ref.cast (ref 9)
    call 10
    v128.const i32x4 0x2077656e 0x65657274 0x706d6520 0x00007974
    array.new_fixed 120 1
    i32.const 0
    i32.const 14
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 11
    v128.const i32x4 0x74706d65 0x6e692079 0x69726176 0x00746e61
    array.new_fixed 120 1
    i32.const 0
    i32.const 15
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 12
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
    v128.const i32x4 0x74706d65 0x696d2079 0x756d696e 0x0000006d
    array.new_fixed 120 1
    i32.const 0
    i32.const 13
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 13
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
    v128.const i32x4 0x74706d65 0x616d2079 0x756d6978 0x0000006d
    array.new_fixed 120 1
    i32.const 0
    i32.const 13
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 1
    call 14
    i32.eqz
    v128.const i32x4 0x7373696d 0x20676e69 0x6f6d6572 0x00006576
    array.new_fixed 120 1
    i32.const 0
    i32.const 14
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    local.set 1
    local.get 1
    i32.const 11
    local.set 19
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 19
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 2
    local.set 20
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 20
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 14
    local.set 21
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 21
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 1
    local.set 22
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 22
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 7
    local.set 23
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 23
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 15
    local.set 24
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 24
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 5
    local.set 25
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 25
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 8
    local.set 26
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 26
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 4
    local.set 27
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 27
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 13
    local.set 28
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 28
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 12
    local.set 29
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 29
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 3
    local.set 30
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 30
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 6
    local.set 31
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 31
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 9
    local.set 32
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 32
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    i32.const 10
    local.set 33
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 33
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    i32.const 0
    local.set 34
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 34
            local.set 2
            local.get 2
            local.get 1
            ref.cast (ref 2)
            struct.get 2 1
            i32.lt_u
            if ;; label = @5
              local.get 1
              local.get 2
              local.set 17
              local.set 16
              local.get 17
              local.get 16
              ref.cast (ref 2)
              struct.get 2 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 16
              ref.cast (ref 2)
              struct.get 2 0
              ref.cast (ref 126)
              local.get 17
              array.get 126
              local.set 3
              local.get 0
              ref.cast (ref 9)
              local.get 3
              local.get 3
              i32.const 10
              i32.mul
              call 15
              v128.const i32x4 0x2077656e 0x65736e69 0x00007472 0x00000000
              array.new_fixed 120 1
              i32.const 0
              i32.const 10
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 0
              ref.cast (ref 9)
              call 11
              v128.const i32x4 0x65736e69 0x69207472 0x7261766e 0x746e6169
              array.new_fixed 120 1
              i32.const 0
              i32.const 16
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 2
              i32.const 1
              i32.add
              local.set 34
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 56
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
    call 16
    i32.const 15
    i32.eq
    v128.const i32x4 0x65736e69 0x6c207472 0x74676e65 0x00000068
    array.new_fixed 120 1
    i32.const 0
    i32.const 13
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    i32.const 701
    call 15
    i32.eqz
    v128.const i32x4 0x6c706572 0x6d656361 0x20746e65 0x6f706572
    v128.const i32x4 0x20737472 0x736c6166 0x00000065 0x00000000
    array.new_fixed 120 2
    i32.const 0
    i32.const 25
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 16
    i32.const 15
    i32.eq
    v128.const i32x4 0x6c706572 0x6d656361 0x20746e65 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 120 2
    i32.const 0
    i32.const 18
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    i32.const -1
    call 59
    i32.const 701
    i32.eq
    v128.const i32x4 0x6c706572 0x6d656361 0x20746e65 0x756c6176
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 120 2
    i32.const 0
    i32.const 17
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 12
    call 17
    v128.const i32x4 0x746e6f63 0x736e6961 0x00000000 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 8
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 99
    call 17
    i32.eqz
    v128.const i32x4 0x7373696d 0x20676e69 0x746e6f63 0x736e6961
    array.new_fixed 120 1
    i32.const 0
    i32.const 16
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 12
    i32.const -1
    call 57
    i32.const 1
    i32.eq
    v128.const i32x4 0x696e696d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 7
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 13
    i32.const -1
    call 57
    i32.const 15
    i32.eq
    v128.const i32x4 0x6978616d 0x006d756d 0x00000000 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 7
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    call 18
    i32.const -1
    call 57
    i32.const 7
    i32.eq
    v128.const i32x4 0x65776f6c 0x78652072 0x00746361 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 11
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 0
    call 18
    i32.const -1
    call 57
    i32.const 1
    i32.eq
    v128.const i32x4 0x65776f6c 0x65622072 0x65726f66 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 12
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    call 19
    i32.const -1
    call 57
    i32.const 8
    i32.eq
    v128.const i32x4 0x65707075 0x78652072 0x00746361 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 11
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    call 20
    i32.const -1
    call 57
    i32.const 6
    i32.eq
    v128.const i32x4 0x64657270 0x73656365 0x00726f73 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 11
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 7
    call 21
    i32.const -1
    call 57
    i32.const 8
    i32.eq
    v128.const i32x4 0x63637573 0x6f737365 0x00000072 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 9
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 1
    call 20
    local.set 35
    block ;; label = @1
      local.get 35
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 36
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 36
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 36
    v128.const i32x4 0x70206f6e 0x65646572 0x73736563 0x0000726f
    array.new_fixed 120 1
    i32.const 0
    i32.const 14
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 15
    call 21
    local.set 37
    block ;; label = @1
      local.get 37
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 38
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 38
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 38
    v128.const i32x4 0x73206f6e 0x65636375 0x726f7373 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 12
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 22
    local.set 4
    i32.const 1
    local.set 5
    i32.const 1
    local.set 39
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 39
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 10)
            call 23
            if ;; label = @5
              local.get 4
              ref.cast (ref 10)
              call 24
              local.set 6
              local.get 6
              ref.cast (ref 8)
              call 6
              local.get 5
              i32.eq
              v128.const i32x4 0x6f2d6e69 0x72656472 0x61727420 0x73726576
              v128.const i32x4 0x00006c61 0x00000000 0x00000000 0x00000000
              array.new_fixed 120 2
              i32.const 0
              i32.const 18
              struct.new 121
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
              local.set 39
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 56
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
    i32.const 16
    i32.eq
    v128.const i32x4 0x72657469 0x726f7461 0x756f6320 0x0000746e
    array.new_fixed 120 1
    i32.const 0
    i32.const 14
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 1
    i32.const 4
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    i32.const 0
    i32.const 1
    i32.const 9
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    i32.const 1
    call 25
    local.set 7
    i32.const 5
    local.set 8
    i32.const 1
    local.set 40
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 40
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 7
            ref.cast (ref 10)
            call 23
            if ;; label = @5
              local.get 7
              ref.cast (ref 10)
              call 24
              call 6
              local.get 8
              i32.eq
              v128.const i32x4 0x676e6172 0x726f2065 0x00726564 0x00000000
              array.new_fixed 120 1
              i32.const 0
              i32.const 11
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 8
              i32.const 1
              i32.add
              local.set 8
              i32.const 1
              local.set 40
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 56
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
    i32.const 10
    i32.eq
    v128.const i32x4 0x676e6172 0x6f622065 0x61646e75 0x73656972
    array.new_fixed 120 1
    i32.const 0
    i32.const 16
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    array.new_default 126
    i32.const 0
    i32.const 0
    struct.new 2
    local.set 9
    local.get 9
    i32.const 1
    local.set 41
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 41
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 14
    local.set 42
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 42
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 7
    local.set 43
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 43
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 11
    local.set 44
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 44
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 4
    local.set 45
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 45
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 8
    local.set 46
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 46
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 15
    local.set 47
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 47
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 2
    local.set 48
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 48
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 5
    local.set 49
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 49
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 3
    local.set 50
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 50
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 6
    local.set 51
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 51
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 9
    local.set 52
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 52
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 10
    local.set 53
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 53
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 12
    local.set 54
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 54
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    i32.const 13
    local.set 55
    local.set 16
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 16
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 17
      local.get 17
      local.get 16
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 17
      array.new_default 126
      local.set 18
      i32.const 0
      local.set 17
      block ;; label = @2
        loop ;; label = @3
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 18
          ref.cast (ref 126)
          local.get 17
          local.get 16
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 126)
          local.get 17
          array.get 126
          array.set 126
          local.get 17
          i32.const 1
          i32.add
          local.set 17
          br 0 (;@3;)
        end
      end
      local.get 16
      ref.cast (ref 2)
      local.get 18
      struct.set 2 0
      local.get 16
      ref.cast (ref 2)
      local.get 18
      ref.cast (ref 126)
      array.len
      struct.set 2 2
    end
    local.get 16
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 126)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    local.get 55
    array.set 126
    local.get 16
    ref.cast (ref 2)
    local.get 16
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    i32.const 0
    local.set 56
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 56
            local.set 10
            local.get 10
            local.get 9
            ref.cast (ref 2)
            struct.get 2 1
            i32.lt_u
            if ;; label = @5
              local.get 9
              local.get 10
              local.set 17
              local.set 16
              local.get 17
              local.get 16
              ref.cast (ref 2)
              struct.get 2 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 16
              ref.cast (ref 2)
              struct.get 2 0
              ref.cast (ref 126)
              local.get 17
              array.get 126
              local.set 11
              local.get 0
              ref.cast (ref 9)
              local.get 11
              call 14
              v128.const i32x4 0x6f6d6572 0x65206576 0x74736978 0x00676e69
              array.new_fixed 120 1
              i32.const 0
              i32.const 15
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 0
              ref.cast (ref 9)
              local.get 11
              call 17
              i32.eqz
              v128.const i32x4 0x6f6d6572 0x20646576 0x65736261 0x0000746e
              array.new_fixed 120 1
              i32.const 0
              i32.const 14
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 0
              ref.cast (ref 9)
              call 11
              v128.const i32x4 0x6f6d6572 0x69206576 0x7261766e 0x746e6169
              array.new_fixed 120 1
              i32.const 0
              i32.const 16
              struct.new 121
              drop
              i32.eqz
              if ;; label = @6
                unreachable
              end
              local.get 10
              i32.const 1
              i32.add
              local.set 56
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 56
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
    call 10
    v128.const i32x4 0x69617264 0x2064656e 0x65657274 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 12
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 16
    i32.const 0
    i32.eq
    v128.const i32x4 0x69617264 0x2064656e 0x676e656c 0x00006874
    array.new_fixed 120 1
    i32.const 0
    i32.const 14
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    i32.const 2
    i32.const 20
    call 15
    drop
    local.get 0
    ref.cast (ref 9)
    i32.const 1
    i32.const 10
    call 15
    drop
    local.get 0
    ref.cast (ref 9)
    i32.const 3
    i32.const 30
    call 15
    drop
    local.get 0
    ref.cast (ref 9)
    call 26
    local.get 0
    ref.cast (ref 9)
    call 10
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 120 1
    i32.const 0
    i32.const 11
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 9)
    call 11
    v128.const i32x4 0x61656c63 0x6e692072 0x69726176 0x00746e61
    array.new_fixed 120 1
    i32.const 0
    i32.const 15
    struct.new 121
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
