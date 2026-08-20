(module
  (type (;0;) (func (param eqref)))
  (type (;1;) (func (param eqref)))
  (type (;2;) (struct (field i32)))
  (type (;3;) (func (param (ref 2))))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 1) (param eqref)
    local.get 0
    ref.cast (ref 2)
    call 1
  )
  (func (;1;) (type 3) (param (ref 2))
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x6c707865 0x74696369 0x73696420 0x65736f70
    v128.const i32x4 0x73696420 0x63746170 0x00000068 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 25
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 4)
    i32.const 7
    struct.new 2
    call 0
  )
)
