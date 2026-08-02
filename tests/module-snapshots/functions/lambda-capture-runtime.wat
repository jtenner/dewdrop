(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (func (;0;) (type 2)
    (local i32 (ref null 0))
    i32.const 1
    local.set 0
    local.get 0
    i32.const 41
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x74706163 0x6e697275 0x616c2067 0x6164626d
    array.new_fixed 3 1
    i32.const 0
    i32.const 16
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 1) (param i32 i32) (result i32)
    local.get 1
    local.get 0
    i32.add
  )
)
