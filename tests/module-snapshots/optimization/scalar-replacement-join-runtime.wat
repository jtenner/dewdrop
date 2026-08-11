(module
  (type (;0;) (func (param i32 i32 i32) (result i32)))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32 i32) (result i32)
    (local i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
      drop
      local.get 2
    else
      local.get 2
      drop
      local.get 1
    end
    local.set 3
    local.get 3
  )
  (func (;1;) (type 1)
    i32.const 1
    i32.const 20
    i32.const 22
    call 0
    i32.const 22
    i32.eq
    v128.const i32x4 0x6e656874 0x696f6a20 0x0000006e 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 20
    i32.const 22
    call 0
    i32.const 20
    i32.eq
    v128.const i32x4 0x65736c65 0x696f6a20 0x0000006e 0x00000000
    array.new_fixed 2 1
    i32.const 0
    i32.const 9
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
