(module
  (type (;0;) (func (param i64) (result i32)))
  (type (;1;) (func (param i32 i32) (result i64)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i64) (result i32)
    (local i32 i64 i32)
    local.get 0
    local.set 2
    block ;; label = @1
      local.get 2
      i32.wrap_i64
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.wrap_i64
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 2
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;1;) (type 1) (param i32 i32) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.const 1
      i64.or
    else
      i64.const 0
    end
  )
  (func (;2;) (type 2)
    (local i32 i32 i64 i32 i64 i32)
    i32.const 41
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.const 1
    i64.or
    call 0
    i32.const 41
    i32.eq
    v128.const i32x4 0x6b636170 0x65206465 0x206d756e 0x61726170
    v128.const i32x4 0x6574656d 0x00000072 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 21
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const -1
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.const 1
    i64.or
    call 0
    i32.const -1
    i32.eq
    v128.const i32x4 0x6b636170 0x65206465 0x206d756e 0x6e676973
    v128.const i32x4 0x70206465 0x6f6c7961 0x62206461 0x00737469
    array.new_fixed 3 2
    i32.const 0
    i32.const 31
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 0
    call 0
    i32.const 0
    i32.eq
    v128.const i32x4 0x6b636170 0x65206465 0x206d756e 0x74696e75
    v128.const i32x4 0x72617020 0x74656d61 0x00007265 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 26
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 42
    call 1
    local.set 2
    block ;; label = @1
      local.get 2
      i32.wrap_i64
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.wrap_i64
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 2
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        local.set 0
        local.get 0
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x6b636170 0x65206465 0x206d756e 0x75736572
    v128.const i32x4 0x0000746c 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 18
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 43
    call 1
    local.set 4
    block ;; label = @1
      local.get 4
      i32.wrap_i64
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 7
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.wrap_i64
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 4
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        local.set 1
        local.get 1
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    i32.const 7
    i32.eq
    v128.const i32x4 0x6b636170 0x65206465 0x206d756e 0x74696e75
    v128.const i32x4 0x73657220 0x00746c75 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 23
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
