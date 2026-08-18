(module
  (type (;0 Pair;) (struct (field (;left;) i32) (field (;right;) i32)))
  (type (;1 sum_type;) (func (param (;value;) (ref 0)) (result i32)))
  (type (;2 main_type;) (func (result i32)))
  (export "main" (func 1))
  (func (;0 sum;) (type 1) (param (;value;) (ref 0)) (result i32)
    local.get 0
    struct.get 0 0 (;Pair.left;)
    local.get 0
    struct.get 0 1 (;Pair.right;)
    i32.add
  )
  (func (;1 main;) (type 2) (result i32)
    i32.const 20 (;Pair.left;)
    i32.const 22 (;Pair.right;)
    struct.new 0 (;Pair;)
    call 0 (;sum;)
  )
)
