(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\02\01\81\81\90\02\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\00\00\00\00\01\02\01\02\02\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\9d\01\00\00\00\00\00\01\02\02\00\04\08\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\9d\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (result i32)))
  (type (;11;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 9) (result i32)
    unreachable
  )
  (func (;1;) (type 10) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 11) (result i32)
    (local i32 eqref i32)
    i32.const 0
    struct.new 8
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 8)
            struct.get 8 0
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
