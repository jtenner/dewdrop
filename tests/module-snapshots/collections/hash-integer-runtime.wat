(module
  (type (;0;) (func (param i64) (result i64)))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i64) (result i64)
    local.get 0
  )
  (func (;1;) (type 1)
    i32.const 7
    i64.extend_i32_s
    i64.const 7
    i64.eq
    v128.const i32x4 0x68203849 0x00687361 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 7
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i64.extend_i32_s
    i64.const 7
    i64.eq
    v128.const i32x4 0x20363149 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i64.extend_i32_s
    i64.const 7
    i64.eq
    v128.const i32x4 0x20323349 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    i64.const 7
    i64.eq
    v128.const i32x4 0x20343649 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i64.extend_i32_u
    i64.const 7
    i64.eq
    v128.const i32x4 0x68203855 0x00687361 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 7
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i64.extend_i32_u
    i64.const 7
    i64.eq
    v128.const i32x4 0x20363155 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i64.extend_i32_u
    i64.const 7
    i64.eq
    v128.const i32x4 0x20323355 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    call 0
    i64.const 7
    i64.eq
    v128.const i32x4 0x20343655 0x68736168 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x65203849 0x6c617571 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x75203849 0x7571656e 0x00006c61 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 10
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x20363149 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x20363149 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x20323349 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x20323349 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    i64.const 7
    i64.eq
    v128.const i32x4 0x20343649 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    i64.const 8
    i64.eq
    i32.eqz
    v128.const i32x4 0x20343649 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x65203855 0x6c617571 0x00000000 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 8
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x75203855 0x7571656e 0x00006c61 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 10
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x20363155 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x20363155 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    i32.eq
    v128.const i32x4 0x20323355 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 8
    i32.eq
    i32.eqz
    v128.const i32x4 0x20323355 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    i64.const 7
    i64.eq
    v128.const i32x4 0x20343655 0x61757165 0x0000006c 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 7
    i64.const 8
    i64.eq
    i32.eqz
    v128.const i32x4 0x20343655 0x71656e75 0x006c6175 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 11
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
