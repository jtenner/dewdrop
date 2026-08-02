(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param (ref 0)) (result i32)))
  (type (;3;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 2) (param (ref 0)) (result i32)
    (local i32 i32 eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 3
        ref.cast (ref 1)
        struct.get 1 2
        local.set 2
        local.get 1
        local.get 2
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;1;) (type 3) (result i32)
    i32.const 1
    i32.const 20
    i32.const 22
    struct.new 1
    call 0
  )
)
