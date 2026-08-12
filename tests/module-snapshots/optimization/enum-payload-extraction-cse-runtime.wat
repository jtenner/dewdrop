(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param (ref 0)) (result (ref 0))))
  (type (;3;) (func (param i32 i32) (result i32)))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 2) (param (ref 0)) (result (ref 0))
    local.get 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    i32.const 0
    local.get 0
    local.get 1
    struct.new 1
    call 0
    local.set 6
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 6
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 6
          ref.cast (ref 1)
          struct.get 1 1
          local.set 2
          local.get 6
          ref.cast (ref 1)
          struct.get 1 2
          local.set 3
          local.get 2
          i32.const 0
          i32.gt_s
          if (result i32) ;; label = @4
            local.get 3
            i32.const 1
            i32.add
          else
            local.get 3
          end
          local.set 7
          br 2 (;@1;)
        end
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;2;) (type 4)
    i32.const 1
    i32.const 20
    call 1
    i32.const 21
    i32.eq
    v128.const i32x4 0x72617567 0x20646564 0x6c796170 0x0064616f
    array.new_fixed 5 1
    i32.const 0
    i32.const 15
    struct.new 6
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
    v128.const i32x4 0x6c6c6166 0x6b636162 0x79617020 0x64616f6c
    array.new_fixed 5 1
    i32.const 0
    i32.const 16
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
