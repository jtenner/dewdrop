(module
  (type (;0;) (struct (field funcref) (field eqref)))
  (type (;1;) (struct (field i32)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (elem (;0;) declare func 1)
  (func (;0;) (type 4)
    (local i32 eqref eqref)
    i32.const 1
    local.set 0
    ref.func 1
    local.get 0
    struct.new 1
    struct.new 0
    local.set 1
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    ref.is_null
    if (result i32) ;; label = @1
      i32.const 41
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 41
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x74706163 0x6e697275 0x616c2067 0x6164626d
    array.new_fixed 5 1
    i32.const 0
    i32.const 16
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 3) (param eqref i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    i32.add
  )
)
