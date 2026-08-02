(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 1
                ref.cast (ref 0)
                struct.get 0 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              i32.const 1
              local.set 2
              br 4 (;@1;)
            end
            i32.const 2
            local.set 2
            br 3 (;@1;)
          end
          i32.const 3
          local.set 2
          br 2 (;@1;)
        end
        i32.const 4
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;1;) (type 2) (result i32)
    i32.const 2
    struct.new 0
    call 0
  )
)
