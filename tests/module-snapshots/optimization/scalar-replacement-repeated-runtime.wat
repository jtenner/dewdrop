(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    (local i32)
    local.get 0
    drop
    local.get 1
    local.set 2
    local.get 2
    local.get 2
    i32.add
    local.get 2
    i32.add
  )
  (func (;1;) (type 1)
    i32.const 1
    i32.const 2
    call 0
    i32.const 6
    i32.eq
    v128.const i32x4 0x65706572 0x64657461 0x65696620 0x0000646c
    array.new_fixed 2 1
    i32.const 0
    i32.const 14
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
