(module
  (type (;0;) (struct (field i32) (field i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field (ref 0)))))
  (type (;3;) (func (param (ref 1)) (result (ref 1))))
  (type (;4;) (func (param i32 i32) (result i32)))
  (type (;5;) (func))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 3) (param (ref 1)) (result (ref 1))
    local.get 0
    ref.cast (ref 1)
  )
  (func (;1;) (type 4) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    i32.const 0
    local.get 0
    local.get 1
    struct.new 0
    ref.cast (ref 0)
    struct.new 2
    call 0
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 2)
        struct.get 2 1
        ref.cast (ref 0)
        struct.get 0 0
        local.set 2
        i32.const 1
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 2)
          struct.get 2 1
          ref.cast (ref 0)
          struct.get 0 1
          local.set 3
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 3
          i32.const 1
          i32.add
        else
          local.get 3
        end
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;2;) (type 5)
    i32.const 1
    i32.const 20
    call 1
    i32.const 21
    i32.eq
    v128.const i32x4 0x7473656e 0x67206465 0x64726175 0x70206465
    v128.const i32x4 0x6f6c7961 0x00006461 0x00000000 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 22
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 22
    call 1
    i32.const 22
    i32.eq
    v128.const i32x4 0x7473656e 0x66206465 0x626c6c61 0x206b6361
    v128.const i32x4 0x6c796170 0x0064616f 0x00000000 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 23
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
