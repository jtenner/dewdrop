(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (param (ref 0)) (result i32)))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    local.get 0
    struct.get 0 0
    local.get 0
    struct.get 0 0
    i32.add
  )
  (func (;1;) (type 2) (param (ref 0)) (result i32)
    (local i32)
    local.get 0
    struct.get 0 0
    local.set 1
    local.get 1
    local.get 1
    i32.add
  )
  (func (;2;) (type 3)
    (local (ref 0))
    i32.const 21
    struct.new 0
    local.set 0
    local.get 0
    call 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x616a6461 0x746e6563 0x65696620 0x4320646c
    v128.const i32x4 0x00004553 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 18
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x61706573 0x65746172 0x69662064 0x20646c65
    v128.const i32x4 0x00455343 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 19
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
