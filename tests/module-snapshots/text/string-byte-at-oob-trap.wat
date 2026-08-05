(module
  (type (;0;) (func (param eqref i32) (result i32)))
  (type (;1;) (func (param eqref i32) (result i32)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 0) (param eqref i32) (result i32)
    (local (ref 4) (ref 3) i32)
    local.get 0
    ref.cast (ref 4)
    local.set 2
    local.get 1
    local.get 2
    struct.get 4 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 4 0
    local.set 3
    local.get 2
    struct.get 4 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 3
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;1;) (type 1) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;2;) (type 2)
    (local eqref i32)
    v128.const i32x4 0x00636261 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 1
    i32.const 0
    i32.const 3
    struct.new 4
    local.set 0
    local.get 0
    i32.const 3
    call 1
    local.set 1
  )
)
