(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 1) (result i32)
    unreachable
  )
  (func (;1;) (type 2) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 3) (result i32)
    (local i32 eqref i32)
    i32.const 0
    struct.new 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          call 0
          drop
          call 1
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        drop
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
    local.set 0
    local.get 0
  )
)
