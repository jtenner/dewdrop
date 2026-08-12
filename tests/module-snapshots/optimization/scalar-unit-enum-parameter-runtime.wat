(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 10
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 20
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 30
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;1;) (type 1)
    i32.const 1
    call 0
    i32.const 20
    i32.eq
    v128.const i32x4 0x6c616373 0x65207261 0x206d756e 0x61726170
    v128.const i32x4 0x6574656d 0x69642072 0x74636572 0x00000000
    array.new_fixed 2 2
    i32.const 0
    i32.const 28
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
    call 0
    i32.const 10
    i32.eq
    v128.const i32x4 0x6c616373 0x65207261 0x206d756e 0x61726170
    v128.const i32x4 0x6574656d 0x72622072 0x68636e61 0x00000000
    array.new_fixed 2 2
    i32.const 0
    i32.const 28
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
    call 0
    i32.const 30
    i32.eq
    v128.const i32x4 0x6c616373 0x65207261 0x206d756e 0x61726170
    v128.const i32x4 0x6574656d 0x6c612072 0x6e726574 0x76697461
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 33
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
