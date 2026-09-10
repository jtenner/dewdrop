(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\01\01\01\01\02\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\9c\01\00\00\00\00\00\01\01\02\00\04\08\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\9c\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (func (param (ref 8)) (result i32)))
  (type (;10;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 9) (param (ref 8)) (result i32)
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
                ref.cast (ref 8)
                struct.get 8 0
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
  (func (;1;) (type 10) (result i32)
    i32.const 2
    struct.new 8
    call 0
  )
)
