(module
  (type $item (struct (field i32)))
  (type $identity-type (func (param eqref) (result eqref)))
  (type $run-type (func (result i32)))

  (import "dew" "identity" (func $identity (type $identity-type)))

  (func (export "run") (type $run-type) (result i32)
    i32.const 42
    struct.new $item
    call $identity
    ref.cast (ref $item)
    struct.get $item 0)
)
