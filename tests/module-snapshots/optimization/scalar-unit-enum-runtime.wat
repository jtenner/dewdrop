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
    (local i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
    local.set 1
    local.get 1
    local.set 4
    block ;; label = @1
      local.get 4
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 10
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 20
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 30
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    local.set 2
    local.get 1
    local.set 6
    block ;; label = @1
      local.get 6
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 2
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 3
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    local.set 3
    local.get 2
    local.get 3
    i32.add
  )
  (func (;1;) (type 1)
    i32.const 1
    call 0
    i32.const 11
    i32.eq
    v128.const i32x4 0x6c616373 0x75207261 0x2074696e 0x6d756e65
    v128.const i32x4 0x66656c20 0x00000074 0x00000000 0x00000000
    array.new_fixed 2 2
    i32.const 0
    i32.const 21
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 0
    i32.const 33
    i32.eq
    v128.const i32x4 0x6c616373 0x75207261 0x2074696e 0x6d756e65
    v128.const i32x4 0x67697220 0x00007468 0x00000000 0x00000000
    array.new_fixed 2 2
    i32.const 0
    i32.const 22
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
