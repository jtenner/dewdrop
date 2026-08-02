(module
  (type $chunks (array (mut v128)))
  (type $string
    (struct
      (field (ref $chunks))
      (field i32)
      (field i32)))

  (func (export "run") (param $seed i32) (result i32)
    v128.const i8x16 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
    array.new_fixed $chunks 1
    i32.const 0
    i32.const 16
    struct.new $string
    drop
    local.get $seed))
