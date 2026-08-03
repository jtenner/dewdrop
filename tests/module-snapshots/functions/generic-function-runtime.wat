(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param eqref) (result eqref)))
  (type (;2;) (func (param eqref eqref) (result eqref)))
  (type (;3;) (func (param eqref) (result eqref)))
  (type (;4;) (func (param eqref eqref) (result eqref)))
  (type (;5;) (func (param eqref eqref) (result eqref)))
  (type (;6;) (func (param eqref eqref) (result eqref)))
  (type (;7;) (func))
  (type (;8;) (array (mut v128)))
  (type (;9;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;12;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (type (;13;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 4))
  (func (;0;) (type 3) (param eqref) (result eqref)
    local.get 0
  )
  (func (;1;) (type 4) (param eqref eqref) (result eqref)
    local.get 0
  )
  (func (;2;) (type 5) (param eqref eqref) (result eqref)
    local.get 1
  )
  (func (;3;) (type 6) (param eqref eqref) (result eqref)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result eqref) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    end
  )
  (func (;4;) (type 7)
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20323369 0x6e656469
    v128.const i32x4 0x79746974 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 20
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 42
    i64.const 42
    i64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20343669 0x6e656469
    v128.const i32x4 0x79746974 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 20
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f64.const 0x1.54p+5 (;=42.5;)
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20343666 0x6e656469
    v128.const i32x4 0x79746974 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 20
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    i32.const 7
    drop
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20323369 0x73726966
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 17
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    drop
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20323369 0x6f636573
    v128.const i32x4 0x0000646e 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 18
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x6c6c6163 0x6b636162
    v128.const i32x4 0x61727720 0x72657070 0x00000000 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 24
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
