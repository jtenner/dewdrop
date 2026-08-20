(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (func (param eqref) (result i32)))
  (type (;3;) (struct (field (ref null 2))))
  (type (;4;) (struct (field eqref) (field (ref 3))))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (param (ref 0)) (result i32)))
  (type (;8;) (func (result i32)))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (func (param eqref i32) (result i32)))
  (type (;14;) (func (param eqref i32) (result i32)))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (result i32)))
  (type (;17;) (array (mut v128)))
  (type (;18;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;21;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 9))
  (func (;0;) (type 7) (param (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
  )
  (func (;1;) (type 8) (result i32)
    i32.const 1
  )
  (func (;2;) (type 9) (result i32)
    i32.const 1
  )
  (func (;3;) (type 10) (param eqref) (result i32)
    (local eqref eqref)
    i32.const 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    local.set 1
    local.get 1
    local.tee 2
    ref.cast (ref 4)
    struct.get 4 0
    local.get 2
    ref.cast (ref 4)
    struct.get 4 1
    struct.get 3 0
    call_ref 2
  )
  (func (;4;) (type 11) (result i32)
    i32.const 0
  )
  (func (;5;) (type 12) (result i32)
    i32.const 0
  )
  (func (;6;) (type 13) (param eqref i32) (result i32)
    (local i32)
    i32.const 0
    local.set 2
    local.get 0
    local.get 1
    call 7
  )
  (func (;7;) (type 14) (param eqref i32) (result i32)
    (local eqref eqref)
    local.get 0
    local.set 2
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 1
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 3
      local.get 1
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 6)
      call_ref 6
    end
  )
  (func (;8;) (type 15) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;9;) (type 16) (result i32)
    (local i32 i32)
    i32.const 41
    struct.new 0
    call 0
    local.set 0
    i32.const 0
    call 8
    local.set 1
    local.get 0
    local.get 1
    i32.add
    i32.const 42
    i32.eq
    v128.const i32x4 0x6c627570 0x65206369 0x63656666 0x75732074
    v128.const i32x4 0x72616d6d 0x65722079 0x746c7573 0x00000000
    array.new_fixed 17 2
    i32.const 0
    i32.const 28
    struct.new 18
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
  )
)
