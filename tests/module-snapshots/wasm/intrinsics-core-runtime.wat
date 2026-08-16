(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 8) (result i32)
    (local v128)
    i32.const 7
    i32x4.splat
    local.set 0
    local.get 0
    i32.const 7
    i32x4.splat
    v128.xor
    local.set 0
    i32.const 19
    i32.const 23
    i32.add
    i32.const 42
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
      i32.const 2
      i32.lt_s
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i64.const 4294967297
      i32.wrap_i64
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1.44p+6 (;=81;)
      f32.sqrt
      f32.const 0x1.2p+3 (;=9;)
      f32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      v128.any_true
      i32.eqz
    else
      i32.const 0
    end
  )
)
