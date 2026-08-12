(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (func (param (ref 0) i32 i32) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0) i32 i32) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          drop
          local.get 2
          local.set 5
          br 2 (;@1;)
        end
        local.get 2
        drop
        local.get 1
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    local.set 3
    local.get 3
  )
  (func (;1;) (type 2) (result i32)
    i32.const 0
    struct.new 0
    i32.const 10
    i32.const 12
    call 0
    i32.const 1
    struct.new 0
    i32.const 20
    i32.const 22
    call 0
    i32.add
  )
)
