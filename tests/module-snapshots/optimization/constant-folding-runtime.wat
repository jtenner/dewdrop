(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 0) (result i32)
    i32.const -7
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
  )
  (func (;2;) (type 2) (result i32)
    i32.const 1
  )
  (func (;3;) (type 3)
    call 0
    i32.const -7
    i32.eq
    v128.const i32x4 0x646c6f66 0x61206465 0x68746972 0x6974656d
    v128.const i32x4 0x00000063 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 17
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    v128.const i32x4 0x646c6f66 0x63206465 0x61706d6f 0x6f736972
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 17
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x646c6f66 0x77206465 0x70706172 0x00676e69
    array.new_fixed 4 1
    i32.const 0
    i32.const 15
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
