(module
  (type (;0;) (func (param eqref eqref eqref)))
  (type (;1;) (func (param i32 i32 eqref)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 1) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.eq
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 2)
    i32.const 1
    i32.const 2
    v128.const i32x4 0x74736574 0x20676e69 0x6d73696d 0x68637461
    array.new_fixed 3 1
    i32.const 0
    i32.const 16
    struct.new 4
    call 0
  )
)
