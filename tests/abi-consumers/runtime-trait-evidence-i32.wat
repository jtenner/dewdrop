(module
  (type $value-method (func (param eqref) (result i32)))
  (type $vtable (struct (field (ref null $value-method))))
  (type $object (struct (field eqref) (field (ref $vtable))))
  (type $item (struct (field i32)))
  (type $closure (sub (struct (field funcref))))
  (type $callback-type (func (param eqref eqref) (result i32)))
  (type $choose-type (func (param i32 eqref eqref) (result eqref)))
  (type $read-type (func (param eqref eqref) (result i32)))
  (type $erase-type (func (param eqref eqref) (result eqref)))
  (type $erase-pair-type (func (param eqref eqref eqref) (result eqref)))
  (type $reader-type (func (param eqref) (result eqref)))
  (type $run-type (func (result i32)))

  (import "dew" "choose" (func $choose (type $choose-type)))
  (import "dew" "read" (func $read (type $read-type)))
  (import "dew" "boxed_read" (func $boxed-read (type $read-type)))
  (import "dew" "nested_read" (func $nested-read (type $read-type)))
  (import "dew" "reader" (func $reader (type $reader-type)))
  (import "dew" "erased_nested" (func $erased-nested (type $erase-type)))
  (import "dew" "erased_pair" (func $erased-pair (type $erase-pair-type)))
  (elem declare func $item-value $item-other)

  (func $item-value (type $value-method) (param eqref) (result i32)
    local.get 0
    ref.cast (ref $item)
    struct.get $item 0)

  (func $item-other (type $value-method) (param eqref) (result i32)
    i32.const 1)

  (func (export "run") (type $run-type) (result i32)
    (local (ref $object) (ref $vtable) (ref $item) i32 i32 i32 (ref $closure) i32 (ref $object) i32 (ref $vtable) (ref $object) i32)
    i32.const 42
    struct.new $item
    local.set 2
    ref.func $item-value
    struct.new $vtable
    local.set 1
    ref.func $item-other
    struct.new $vtable
    local.set 10
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
    local.get 1
    call $reader
    ref.cast (ref $closure)
    local.set 6
    local.get 6
    local.get 2
    local.get 6
    struct.get $closure 0
    ref.cast (ref $callback-type)
    call_ref $callback-type
    local.set 7
    local.get 2
    local.get 1
    call $erased-nested
    ref.cast (ref $object)
    local.set 8
    local.get 8
    struct.get $object 0
    local.get 8
    struct.get $object 1
    struct.get $vtable 0
    call_ref $value-method
    local.set 9
    local.get 2
    local.get 1
    local.get 10
    call $erased-pair
    ref.cast (ref $object)
    local.set 11
    local.get 11
    struct.get $object 0
    local.get 11
    struct.get $object 1
    struct.get $vtable 0
    call_ref $value-method
    local.set 12
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
    i32.add
    local.get 7
    i32.add
    local.get 9
    i32.add
    local.get 12
    i32.add)
)
