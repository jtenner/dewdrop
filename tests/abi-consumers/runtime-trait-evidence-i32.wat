(module
  (type $value-method (func (param eqref) (result i32)))
  (type $vtable (struct (field (ref null $value-method))))
  (type $object (struct (field eqref) (field (ref $vtable))))
  (type $item (struct (field i32)))
  (type $choose-type (func (param i32 eqref eqref) (result eqref)))
  (type $read-type (func (param eqref eqref) (result i32)))
  (type $run-type (func (result i32)))

  (import "dew" "choose" (func $choose (type $choose-type)))
  (import "dew" "read" (func $read (type $read-type)))
  (import "dew" "boxed_read" (func $boxed-read (type $read-type)))
  (import "dew" "nested_read" (func $nested-read (type $read-type)))
  (elem declare func $item-value)

  (func $item-value (type $value-method) (param eqref) (result i32)
    local.get 0
    ref.cast (ref $item)
    struct.get $item 0)

  (func (export "run") (type $run-type) (result i32)
    (local (ref $object) (ref $vtable) (ref $item) i32 i32 i32)
    i32.const 42
    struct.new $item
    local.set 2
    ref.func $item-value
    struct.new $vtable
    local.set 1
    local.get 2
    local.get 1
    call $read
    local.set 3
    local.get 2
    local.get 1
    call $boxed-read
    local.set 4
    local.get 2
    local.get 1
    call $nested-read
    local.set 5
    i32.const 1
    local.get 2
    local.get 1
    call $choose
    ref.cast (ref $object)
    local.set 0
    local.get 0
    struct.get $object 0
    local.get 0
    struct.get $object 1
    struct.get $vtable 0
    call_ref $value-method
    local.get 3
    i32.add
    local.get 4
    i32.add
    local.get 5
    i32.add)
)
