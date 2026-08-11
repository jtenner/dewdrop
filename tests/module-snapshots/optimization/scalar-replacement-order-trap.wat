(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 0) (result i32)
    i32.const 0
    v128.const i32x4 0x73726966 0x69662074 0x00646c65 0x00000000
    array.new_fixed 3 1
    i32.const 0
    i32.const 11
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 2) (result i32)
    call 0
    drop
    call 1
  )
)
